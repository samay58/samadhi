public enum AutoTargetStatus: String, Sendable, Equatable, Codable {
    case acquiring
    case settled
    case considering
    case holding
}

public struct AutoTargetState: Sendable, Equatable {
    public var observedCadenceSPM: Double?
    public var settledTargetSPM: Double?
    public var candidateTargetSPM: Double?
    public var candidateDurationSeconds: Double
    public var secondsSinceCommit: Double
    public var uncertaintySeconds: Double
    public var status: AutoTargetStatus

    public init(
        observedCadenceSPM: Double? = nil,
        settledTargetSPM: Double? = nil,
        candidateTargetSPM: Double? = nil,
        candidateDurationSeconds: Double = 0,
        secondsSinceCommit: Double = 0,
        uncertaintySeconds: Double = 0,
        status: AutoTargetStatus = .acquiring
    ) {
        self.observedCadenceSPM = observedCadenceSPM
        self.settledTargetSPM = settledTargetSPM
        self.candidateTargetSPM = candidateTargetSPM
        self.candidateDurationSeconds = max(candidateDurationSeconds, 0)
        self.secondsSinceCommit = max(secondsSinceCommit, 0)
        self.uncertaintySeconds = max(uncertaintySeconds, 0)
        self.status = status
    }

    public static let initial = AutoTargetState()
}

public struct AutoTargetPolicy: Sendable {
    // Running can settle as soon as the sensor filter has three agreeing readings. Walking overlaps
    // more with ordinary gym movement, so it needs five seconds of reliable filtered cadence before
    // it can own the music. Later changes use the same five-second evidence in either range.
    private let runningAcquisitionDurationSeconds = 1.0
    private let walkingAcquisitionDurationSeconds = 5.0
    private let changeSustainSeconds = 5.0
    private let minimumCommitIntervalSeconds = 8.0
    private let targetDeadbandSPM = 4.0
    private let candidateThresholdSPM = 6.0
    private let candidateAgreementSPM = 3.0
    private let uncertaintyClearSeconds = 12.0

    public init() {}

    public func update(
        state: AutoTargetState,
        cadenceSPM: Double?,
        cadenceReliable: Bool,
        deltaSeconds: Double
    ) -> AutoTargetState {
        var next = state
        let elapsed = max(deltaSeconds, 0)
        next.secondsSinceCommit += elapsed

        guard cadenceReliable,
            let cadenceSPM,
            TempoEnvelope.locomotionCadenceSPM.contains(cadenceSPM)
        else {
            next.observedCadenceSPM = cadenceSPM
            next.candidateTargetSPM = nil
            next.candidateDurationSeconds = 0
            next.uncertaintySeconds += elapsed
            if next.uncertaintySeconds >= uncertaintyClearSeconds {
                next.settledTargetSPM = nil
                next.status = .acquiring
            } else {
                next.status = next.settledTargetSPM == nil ? .acquiring : .holding
            }
            return next
        }

        next.observedCadenceSPM = cadenceSPM
        next.uncertaintySeconds = 0

        guard let settledTarget = next.settledTargetSPM else {
            accumulateCandidate(cadenceSPM, elapsed: elapsed, state: &next)
            next.status = .acquiring
            let acquisitionDuration =
                TempoEnvelope.runningCadenceSPM.contains(cadenceSPM)
                ? runningAcquisitionDurationSeconds
                : walkingAcquisitionDurationSeconds
            if next.candidateDurationSeconds >= acquisitionDuration {
                commitCandidate(state: &next)
            }
            return next
        }

        let movement = cadenceSPM - settledTarget
        guard abs(movement) > targetDeadbandSPM else {
            clearCandidate(state: &next)
            next.status = .settled
            return next
        }
        guard abs(movement) >= candidateThresholdSPM else {
            clearCandidate(state: &next)
            next.status = .settled
            return next
        }

        let candidateContinues: Bool
        if let candidate = next.candidateTargetSPM {
            candidateContinues =
                (candidate - settledTarget) * movement > 0
                && abs(cadenceSPM - candidate) <= candidateAgreementSPM
        } else {
            candidateContinues = false
        }

        if candidateContinues {
            accumulateCandidate(cadenceSPM, elapsed: elapsed, state: &next)
        } else {
            next.candidateTargetSPM = cadenceSPM
            // The first changed sample starts the clock. Its preceding interval may still belong to
            // the old rhythm, so it cannot count as sustained evidence by itself.
            next.candidateDurationSeconds = 0
        }
        next.status = .considering

        if next.candidateDurationSeconds >= changeSustainSeconds,
            next.secondsSinceCommit >= minimumCommitIntervalSeconds
        {
            commitCandidate(state: &next)
        }
        return next
    }

    private func accumulateCandidate(
        _ cadenceSPM: Double,
        elapsed: Double,
        state: inout AutoTargetState
    ) {
        guard let candidate = state.candidateTargetSPM,
            abs(cadenceSPM - candidate) <= candidateAgreementSPM
        else {
            state.candidateTargetSPM = cadenceSPM
            state.candidateDurationSeconds = elapsed
            return
        }

        let priorDuration = state.candidateDurationSeconds
        let totalDuration = priorDuration + elapsed
        if totalDuration > 0 {
            state.candidateTargetSPM =
                ((candidate * priorDuration) + (cadenceSPM * elapsed)) / totalDuration
        }
        state.candidateDurationSeconds = totalDuration
    }

    private func commitCandidate(state: inout AutoTargetState) {
        guard let candidate = state.candidateTargetSPM else { return }
        state.settledTargetSPM = candidate.rounded()
        state.candidateTargetSPM = nil
        state.candidateDurationSeconds = 0
        state.secondsSinceCommit = 0
        state.status = .settled
    }

    private func clearCandidate(state: inout AutoTargetState) {
        state.candidateTargetSPM = nil
        state.candidateDurationSeconds = 0
    }
}
