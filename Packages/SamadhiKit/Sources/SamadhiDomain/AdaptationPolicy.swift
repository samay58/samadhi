public enum AdaptationStatus: Sendable, Equatable {
    case acquiring
    case adjusting
    case matched
    case musicSteady
}

public enum TempoCommandStatus: String, Sendable, Equatable, Codable {
    case idle
    case applying
    case applied
    case unreachable
    case rejected
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
    public var commandStatus: TempoCommandStatus
    public var achievableBPM: Double?
    public var commandedRate: Double?
    public var appliedRateReadback: Double?
    public var commandLatencySeconds: Double?

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
        isAtLimit: Bool = false,
        commandStatus: TempoCommandStatus = .idle,
        achievableBPM: Double? = nil,
        commandedRate: Double? = nil,
        appliedRateReadback: Double? = nil,
        commandLatencySeconds: Double? = nil
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
        self.commandStatus = commandStatus
        self.achievableBPM = achievableBPM
        self.commandedRate = commandedRate
        self.appliedRateReadback = appliedRateReadback
        self.commandLatencySeconds = commandLatencySeconds
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

    public init(minimumRate: Double = 0.90, maximumRate: Double = 1.10) {
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
            next.achievableBPM = requestedBPM
            next.baseTempoBPM = input.baseTempoBPM
            if input.cadenceReliable { next.lastReliableCadenceSPM = input.cadenceSPM }
            next.secondsSinceTargetUpdate = 0
        }

        if !canUpdateTarget, state.isAtLimit {
            return musicSteady(
                state: next,
                input: input,
                requestedBPM: requestedBPM,
                derivedTargetRate: state.derivedTargetRate,
                isAtLimit: true
            )
        }

        guard let target = next.targetRate else {
            return musicSteady(state: next, input: input)
        }

        let commandedRate =
            input.rhythmControl.mode == .manual && input.forceTargetUpdate
            ? target
            : move(
                input.appliedRate,
                toward: target,
                maximumChange: 0.02 * input.deltaSeconds
            )
        next.commandedRate = commandedRate
        next.commandStatus = .applying
        next.isAtLimit = false

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
        guard (120...210).contains(baseTempo) else { return nil }
        return requestedBPM / baseTempo
    }

    private func confidenceLost(state: AdaptationState, input: AdaptationInput) -> AdaptationDecision {
        var next = state
        let startRate = state.confidenceLossStartRate ?? input.appliedRate
        let lostSeconds = (state.confidenceLostSeconds ?? 0) + input.deltaSeconds
        next.confidenceLossStartRate = startRate
        next.confidenceLostSeconds = lostSeconds
        next.matchedSeconds = 0
        next.commandStatus = input.rhythmControl.mode == .manual ? state.commandStatus : .idle

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
        let boundaryRate = derivedTargetRate.map { min(max($0, minimumRate), maximumRate) }
        let commandedRate: Double
        if isAtLimit, let boundaryRate {
            commandedRate =
                input.rhythmControl.mode == .manual && input.forceTargetUpdate
                ? boundaryRate
                : move(
                    input.appliedRate,
                    toward: boundaryRate,
                    maximumChange: 0.02 * input.deltaSeconds
                )
        } else {
            commandedRate = input.appliedRate
        }
        next.targetRate = isAtLimit ? boundaryRate : nil
        next.baseTempoBPM = input.baseTempoBPM
        next.matchedSeconds = 0
        next.hasMatched = false
        next.confidenceLostSeconds = nil
        next.confidenceLossStartRate = nil
        next.requestedBPM = requestedBPM
        next.derivedTargetRate = derivedTargetRate
        next.isAtLimit = isAtLimit
        next.achievableBPM = boundaryRate.map { input.baseTempoBPM * $0 }
        next.commandedRate = isAtLimit ? commandedRate : nil
        next.commandStatus =
            isAtLimit
            ? (abs(commandedRate - input.appliedRate) <= 0.000_1 ? .applied : .applying)
            : .idle
        return AdaptationDecision(
            commandedRate: commandedRate,
            targetRate: next.targetRate,
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
        referenceBPM: Double?,
        referenceReliable: Bool,
        baseTempoBPM: Double?,
        appliedRate: Double?,
        playbackActive: Bool,
        commandVerified: Bool = true
    ) -> Bool? {
        guard playbackActive,
            referenceReliable,
            commandVerified,
            let referenceBPM,
            let baseTempoBPM,
            let appliedRate
        else { return nil }

        guard (120...210).contains(baseTempoBPM) else { return nil }
        return abs((baseTempoBPM * appliedRate) - referenceBPM) <= 3
    }
}
