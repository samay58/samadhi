public enum AdaptationStatus: Sendable, Equatable {
    case acquiring
    case adjusting
    case matched
    case musicSteady
}

public struct AdaptationState: Sendable, Equatable {
    public var targetRate: Double?
    public var baseTempoBPM: Double?
    public var lastReliableCadenceSPM: Double?
    public var secondsSinceTargetUpdate: Double
    public var confidenceLostSeconds: Double?
    public var confidenceLossStartRate: Double?
    public var matchedSeconds: Double
    public var hasMatched: Bool
    public var requestedBPM: Double?
    public var derivedTargetRate: Double?
    public var isAtLimit: Bool

    public init(
        targetRate: Double? = nil,
        baseTempoBPM: Double? = nil,
        lastReliableCadenceSPM: Double? = nil,
        secondsSinceTargetUpdate: Double = 0,
        confidenceLostSeconds: Double? = nil,
        confidenceLossStartRate: Double? = nil,
        matchedSeconds: Double = 0,
        hasMatched: Bool = false,
        requestedBPM: Double? = nil,
        derivedTargetRate: Double? = nil,
        isAtLimit: Bool = false
    ) {
        self.targetRate = targetRate
        self.baseTempoBPM = baseTempoBPM
        self.lastReliableCadenceSPM = lastReliableCadenceSPM
        self.secondsSinceTargetUpdate = max(secondsSinceTargetUpdate, 0)
        self.confidenceLostSeconds = confidenceLostSeconds
        self.confidenceLossStartRate = confidenceLossStartRate
        self.matchedSeconds = max(matchedSeconds, 0)
        self.hasMatched = hasMatched
        self.requestedBPM = requestedBPM
        self.derivedTargetRate = derivedTargetRate
        self.isAtLimit = isAtLimit
    }

    public static let initial = AdaptationState()
}

public struct AdaptationInput: Sendable, Equatable {
    public let cadenceSPM: Double?
    public let cadenceReliable: Bool
    public let baseTempoBPM: Double
    public let analysisConfidence: Double
    public let appliedRate: Double
    public let deltaSeconds: Double
    public let rhythmControl: RhythmControlState
    public let forceTargetUpdate: Bool

    public init(
        cadenceSPM: Double?,
        cadenceReliable: Bool,
        baseTempoBPM: Double,
        analysisConfidence: Double,
        appliedRate: Double,
        deltaSeconds: Double,
        rhythmControl: RhythmControlState = .initial,
        forceTargetUpdate: Bool = false
    ) {
        self.cadenceSPM = cadenceSPM
        self.cadenceReliable = cadenceReliable
        self.baseTempoBPM = baseTempoBPM
        self.analysisConfidence = analysisConfidence
        self.appliedRate = appliedRate
        self.deltaSeconds = max(deltaSeconds, 0)
        self.rhythmControl = rhythmControl
        self.forceTargetUpdate = forceTargetUpdate
    }
}

public struct AdaptationDecision: Sendable, Equatable {
    public let commandedRate: Double
    public let targetRate: Double?
    public let isTrackCompatible: Bool
    public let status: AdaptationStatus
    public let nextState: AdaptationState
    public let requestedBPM: Double?
    public let derivedTargetRate: Double?
    public let isAtLimit: Bool
}

public struct AdaptationPolicy: Sendable {
    public let minimumRate: Double
    public let maximumRate: Double

    public init(minimumRate: Double = 0.94, maximumRate: Double = 1.06) {
        self.minimumRate = minimumRate
        self.maximumRate = maximumRate
    }

    public func update(state: AdaptationState, input: AdaptationInput) -> AdaptationDecision {
        guard input.analysisConfidence >= TempoAnalysis.readyConfidence,
            input.baseTempoBPM > 0
        else {
            return musicSteady(state: state, input: input)
        }

        let requestedBPM: Double
        switch input.rhythmControl.mode {
        case .automatic:
            guard input.cadenceReliable,
                let cadence = input.cadenceSPM,
                (120...210).contains(cadence),
                let requested = input.rhythmControl.requestedBPM(cadenceSPM: cadence)
            else {
                return confidenceLost(state: state, input: input)
            }
            requestedBPM = requested
        case .manual:
            guard let requested = input.rhythmControl.requestedBPM(cadenceSPM: input.cadenceSPM) else {
                return musicSteady(state: state, input: input)
            }
            requestedBPM = requested
        }

        var next = state
        if input.rhythmControl.mode == .manual, !input.cadenceReliable {
            next.confidenceLostSeconds = (state.confidenceLostSeconds ?? 0) + input.deltaSeconds
            next.confidenceLossStartRate = nil
            if (next.confidenceLostSeconds ?? 0) >= 10 {
                next.lastReliableCadenceSPM = nil
            }
        } else {
            next.confidenceLostSeconds = nil
            next.confidenceLossStartRate = nil
        }
        next.secondsSinceTargetUpdate += input.deltaSeconds
        next.requestedBPM = requestedBPM

        let requestedMovement = state.requestedBPM.map { abs(requestedBPM - $0) }
        let requestedChanged = requestedMovement.map { $0 > 2 } ?? true
        let trackChanged = state.baseTempoBPM != input.baseTempoBPM
        let canUpdateTarget =
            state.targetRate == nil || trackChanged || input.forceTargetUpdate
            || (requestedChanged && next.secondsSinceTargetUpdate >= 2)

        if canUpdateTarget {
            if trackChanged {
                next.hasMatched = false
                next.matchedSeconds = 0
            }
            guard let target = targetRate(requestedBPM: requestedBPM, baseTempo: input.baseTempoBPM) else {
                return musicSteady(state: next, input: input)
            }
            next.derivedTargetRate = target
            next.isAtLimit = !(minimumRate...maximumRate).contains(target)
            guard !next.isAtLimit else {
                return musicSteady(
                    state: next,
                    input: input,
                    requestedBPM: requestedBPM,
                    derivedTargetRate: target,
                    isAtLimit: true
                )
            }
            next.targetRate = target
            next.baseTempoBPM = input.baseTempoBPM
            if input.cadenceReliable { next.lastReliableCadenceSPM = input.cadenceSPM }
            next.secondsSinceTargetUpdate = 0
        }

        guard let target = next.targetRate else {
            return musicSteady(state: next, input: input)
        }

        let rampPerSecond = next.hasMatched ? 0.005 : 0.02
        let commandedRate = move(
            input.appliedRate,
            toward: target,
            maximumChange: rampPerSecond * input.deltaSeconds
        )

        if abs(input.appliedRate - target) <= 0.005 {
            next.matchedSeconds += input.deltaSeconds
        } else {
            next.matchedSeconds = 0
        }

        let status: AdaptationStatus
        if next.matchedSeconds >= 1 {
            next.hasMatched = true
            status = .matched
        } else {
            status = .adjusting
        }

        return AdaptationDecision(
            commandedRate: commandedRate,
            targetRate: target,
            isTrackCompatible: true,
            status: status,
            nextState: next,
            requestedBPM: requestedBPM,
            derivedTargetRate: next.derivedTargetRate,
            isAtLimit: false
        )
    }

    private func targetRate(requestedBPM: Double, baseTempo: Double) -> Double? {
        let candidates = [baseTempo / 2, baseTempo, baseTempo * 2]
            .filter { (120...210).contains($0) }
        return
            candidates
            .map { requestedBPM / $0 }
            .min { abs($0 - 1) < abs($1 - 1) }
    }

    private func confidenceLost(state: AdaptationState, input: AdaptationInput) -> AdaptationDecision {
        var next = state
        let startRate = state.confidenceLossStartRate ?? input.appliedRate
        let lostSeconds = (state.confidenceLostSeconds ?? 0) + input.deltaSeconds
        next.confidenceLossStartRate = startRate
        next.confidenceLostSeconds = lostSeconds
        next.matchedSeconds = 0

        let commandedRate: Double
        if lostSeconds <= 6 {
            commandedRate = startRate
        } else {
            let returnProgress = min((lostSeconds - 6) / 4, 1)
            commandedRate = startRate + ((1 - startRate) * returnProgress)
        }
        if lostSeconds >= 10 {
            next.targetRate = nil
            next.lastReliableCadenceSPM = nil
            next.hasMatched = false
        }

        return AdaptationDecision(
            commandedRate: commandedRate,
            targetRate: next.targetRate,
            isTrackCompatible: true,
            status: .acquiring,
            nextState: next,
            requestedBPM: next.requestedBPM,
            derivedTargetRate: next.derivedTargetRate,
            isAtLimit: next.isAtLimit
        )
    }

    private func musicSteady(
        state: AdaptationState,
        input: AdaptationInput,
        requestedBPM: Double? = nil,
        derivedTargetRate: Double? = nil,
        isAtLimit: Bool = false
    ) -> AdaptationDecision {
        var next = state
        next.targetRate = nil
        next.baseTempoBPM = input.baseTempoBPM
        next.matchedSeconds = 0
        next.hasMatched = false
        next.confidenceLostSeconds = nil
        next.confidenceLossStartRate = nil
        next.requestedBPM = requestedBPM
        next.derivedTargetRate = derivedTargetRate
        next.isAtLimit = isAtLimit
        return AdaptationDecision(
            commandedRate: move(input.appliedRate, toward: 1, maximumChange: 0.02 * input.deltaSeconds),
            targetRate: nil,
            isTrackCompatible: false,
            status: .musicSteady,
            nextState: next,
            requestedBPM: requestedBPM,
            derivedTargetRate: derivedTargetRate,
            isAtLimit: isAtLimit
        )
    }

    private func move(_ value: Double, toward target: Double, maximumChange: Double) -> Double {
        if value < target { return min(value + maximumChange, target) }
        return max(value - maximumChange, target)
    }
}

public enum TempoMatchEvaluator {
    public static func measure(
        cadenceSPM: Double?,
        cadenceReliable: Bool,
        baseTempoBPM: Double?,
        appliedRate: Double?,
        playbackActive: Bool
    ) -> Bool? {
        guard playbackActive,
            cadenceReliable,
            let cadenceSPM,
            let baseTempoBPM,
            let appliedRate
        else { return nil }

        let closestEffectiveTempo = [baseTempoBPM / 2, baseTempoBPM, baseTempoBPM * 2]
            .map { $0 * appliedRate }
            .min { abs($0 - cadenceSPM) < abs($1 - cadenceSPM) }
        guard let closestEffectiveTempo else { return nil }
        return abs(closestEffectiveTempo - cadenceSPM) <= 3
    }
}
