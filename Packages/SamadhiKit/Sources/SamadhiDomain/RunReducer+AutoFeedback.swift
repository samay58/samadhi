// One meaningful Auto adjustment is one identified transaction. This file owns opening it, the
// exactly-once began and arrived triggers, and every cancellation rule. Feedback is only ever
// allowed by something Apple Music actually did on the current confirmed song.
extension RunReducer {
    // A read-back this close to the target counts as arrival. It matches the reducer's existing
    // applied-versus-commanded tolerance so one truth decides both.
    static let autoFeedbackArrivalTolerance = 0.005
    // Below this the applied rate has not really left its origin, so nothing has begun.
    static let autoFeedbackMovementTolerance = 0.000_5

    // Runs after every adaptation. Auto owns the song and a newly settled target that the music can
    // actually move toward opens a transaction; everything else cancels or leaves state alone.
    func updateAutoFeedback(session: inout RunSession) -> [RunEffect] {
        guard session.rhythmControl.mode == .automatic else {
            // Manual takeover. The runner owns the song, so a later Return to Auto may open a new
            // transaction for the same target.
            return cancelAutoFeedback(session: &session, forgettingSettledTarget: true)
        }
        guard let settledTargetSPM = session.autoTargetState.settledTargetSPM else {
            return cancelAutoFeedback(session: &session, forgettingSettledTarget: true)
        }
        guard settledTargetSPM != session.autoFeedback.lastSettledTargetSPM else { return [] }
        guard let trackID = session.currentTrackID,
            let targetRate = session.adaptationState.targetRate,
            let baseTempoBPM = session.adaptationState.baseTempoBPM,
            baseTempoBPM > 0
        else { return [] }

        let originRate = session.appliedPlaybackRate
        let changeSPM = (targetRate - originRate) * baseTempoBPM
        // Recording the target even when the change is too small stops a later drift from opening a
        // transaction for a target the runner already reached.
        session.autoFeedback.lastSettledTargetSPM = settledTargetSPM
        guard let size = AutoFeedbackSize.band(forChangeSPM: changeSPM) else { return [] }

        var effects: [RunEffect] = []
        if let replaced = session.autoFeedback.transaction, replaced.phase != .arrived {
            effects.append(.cancelAutoFeedback(transactionID: replaced.id))
        }
        session.autoFeedback.transaction = AutoFeedbackTransaction(
            id: session.autoFeedback.nextTransactionID,
            trackID: trackID,
            settledTargetSPM: settledTargetSPM,
            direction: targetRate > originRate ? .faster : .slower,
            size: size,
            originRate: originRate,
            targetRate: targetRate,
            changeSPM: changeSPM,
            isLimited: session.adaptationState.isAtLimit
        )
        session.autoFeedback.nextTransactionID += 1
        return effects
    }

    // An identified Apple Music reply is the only thing that can start or complete a transaction.
    // The caller has already checked session, operation, request, and track identity.
    func autoFeedbackAfterRateReadback(session: inout RunSession) -> [RunEffect] {
        guard var transaction = session.autoFeedback.transaction,
            transaction.phase != .arrived,
            session.currentTrackID == transaction.trackID,
            session.adaptationState.commandStatus == .applied
        else { return [] }

        let appliedRate = session.appliedPlaybackRate
        let intendedMovement = transaction.targetRate - transaction.originRate
        let observedMovement = appliedRate - transaction.originRate
        var effects: [RunEffect] = []

        if transaction.phase == .committed {
            guard observedMovement * intendedMovement > 0,
                abs(observedMovement) > Self.autoFeedbackMovementTolerance
            else { return [] }
            transaction.phase = .began
            effects.append(.emitAutoFeedback(cue(for: transaction, moment: .began)))
        }

        if abs(appliedRate - transaction.targetRate) <= Self.autoFeedbackArrivalTolerance {
            transaction.phase = .arrived
            effects.append(.emitAutoFeedback(cue(for: transaction, moment: .arrived)))
        }

        session.autoFeedback.transaction = transaction
        return effects
    }

    func cancelAutoFeedback(
        session: inout RunSession,
        forgettingSettledTarget: Bool
    ) -> [RunEffect] {
        var effects: [RunEffect] = []
        if let transaction = session.autoFeedback.transaction, transaction.phase != .arrived {
            effects.append(.cancelAutoFeedback(transactionID: transaction.id))
        }
        session.autoFeedback.transaction = nil
        if forgettingSettledTarget { session.autoFeedback.lastSettledTargetSPM = nil }
        return effects
    }

    // A confirmed different song carries no old command, reply, or feedback. Transaction numbering
    // keeps rising so a cancelled cue can never be confused with a new song's cue.
    func resetAutoFeedbackForNewSong(session: inout RunSession) -> [RunEffect] {
        let effects = cancelAutoFeedback(session: &session, forgettingSettledTarget: true)
        session.autoFeedback = AutoFeedbackState(
            nextTransactionID: session.autoFeedback.nextTransactionID
        )
        return effects
    }

    private func cue(
        for transaction: AutoFeedbackTransaction,
        moment: AutoFeedbackMoment
    ) -> AutoFeedbackCue {
        AutoFeedbackCue(
            transactionID: transaction.id,
            moment: moment,
            direction: transaction.direction,
            size: transaction.size,
            isLimited: transaction.isLimited
        )
    }
}
