import Testing

@testable import SamadhiDomain

// Every song here is analyzed at a cadence pulse the runner can actually reach, so a settled target
// of pulse plus the wanted change produces exactly that change in step rhythm.
private let feedbackTrack = MusicTrack(
    id: MusicTrackID("feedback-track"),
    title: "Feedback",
    durationSeconds: 240,
    tempo: TempoAnalysis(
        baseBPM: 168,
        confidence: 1,
        analyzedDurationSeconds: 30,
        version: 4
    )
)
private let secondFeedbackTrack = MusicTrack(
    id: MusicTrackID("feedback-track-two"),
    title: "Feedback two",
    durationSeconds: 240,
    tempo: TempoAnalysis(
        baseBPM: 168,
        confidence: 1,
        analyzedDurationSeconds: 30,
        version: 4
    )
)
private let feedbackReducer = RunReducer(tracks: [feedbackTrack, secondFeedbackTrack])
private let feedbackSessionID = 700
private let feedbackPulseSPM = 168.0

private func autoRun(
    settledTargetSPM: Double,
    appliedRate: Double = 1
) -> RunState {
    var session = RunSession(id: feedbackSessionID)
    session.currentTrackID = feedbackTrack.id
    session.cadenceAcquisitionID = 1
    session.appliedPlaybackRate = appliedRate
    session.autoTargetState = AutoTargetState(
        observedCadenceSPM: settledTargetSPM,
        settledTargetSPM: settledTargetSPM,
        status: .settled
    )
    return .active(
        ActiveRun(
            session: session,
            activity: .playing(
                rhythm: .locked(spm: Int(settledTargetSPM.rounded())),
                controls: .hidden
            )
        )
    )
}

private func cues(_ effects: [RunEffect]) -> [AutoFeedbackCue] {
    effects.compactMap {
        guard case let .emitAutoFeedback(cue) = $0 else { return nil }
        return cue
    }
}

private func cancellations(_ effects: [RunEffect]) -> [Int] {
    effects.compactMap {
        guard case let .cancelAutoFeedback(transactionID) = $0 else { return nil }
        return transactionID
    }
}

private func commandedRate(_ effects: [RunEffect]) -> (requestID: Int, rate: Double)? {
    for effect in effects {
        if case let .setPlaybackRate(_, _, requestID, _, rate) = effect {
            return (requestID, rate)
        }
    }
    return nil
}

private struct Ramp {
    var state: RunState
    var cues: [AutoFeedbackCue] = []
    var cancelledTransactionIDs: [Int] = []
    var repliedRates: [Double] = []
}

// Drives cadence updates and the matching identified replies the way the shell would, with no
// wall-clock anywhere. Every emitted cue is collected so exactly-once can be asserted.
private func rampToTarget(
    from state: RunState,
    holdingCadenceSPM cadence: Double,
    steps: Int = 12,
    firstToken: Int = 900,
    replying: Bool = true
) -> Ramp {
    var ramp = Ramp(state: state)
    var token = firstToken
    for _ in 0..<steps {
        let updated = feedbackReducer.reduce(
            state: ramp.state,
            event: .cadenceUpdated(
                sessionID: feedbackSessionID,
                acquisitionID: 1,
                stepsPerMinute: cadence,
                deltaSeconds: 1,
                rateRequestID: token
            )
        )
        ramp.state = updated.0
        ramp.cues.append(contentsOf: cues(updated.1))
        ramp.cancelledTransactionIDs.append(contentsOf: cancellations(updated.1))
        guard replying, let command = commandedRate(updated.1) else {
            token += 1
            continue
        }
        let applied = feedbackReducer.reduce(
            state: ramp.state,
            event: .playbackRateApplied(
                sessionID: feedbackSessionID,
                operationID: feedbackSessionID,
                requestID: command.requestID,
                trackID: feedbackTrack.id,
                rate: command.rate,
                latencySeconds: 0.08
            )
        )
        ramp.state = applied.0
        ramp.cues.append(contentsOf: cues(applied.1))
        ramp.cancelledTransactionIDs.append(contentsOf: cancellations(applied.1))
        ramp.repliedRates.append(command.rate)
        token += 1
    }
    return ramp
}

@Test(
    arguments: [
        (175.0, AutoFeedbackDirection.faster, AutoFeedbackSize.small),
        (180.0, AutoFeedbackDirection.faster, AutoFeedbackSize.medium),
        (188.0, AutoFeedbackDirection.faster, AutoFeedbackSize.large),
        (161.0, AutoFeedbackDirection.slower, AutoFeedbackSize.small),
        (156.0, AutoFeedbackDirection.slower, AutoFeedbackSize.medium),
        (148.0, AutoFeedbackDirection.slower, AutoFeedbackSize.large),
    ]
)
func everyBandProducesOneBeginningAndOneArrival(
    target: Double,
    direction: AutoFeedbackDirection,
    size: AutoFeedbackSize
) throws {
    let ramp = rampToTarget(from: autoRun(settledTargetSPM: target), holdingCadenceSPM: target)

    #expect(ramp.cues.count == 2)
    #expect(ramp.cues.map(\.moment) == [.began, .arrived])
    #expect(ramp.cues.allSatisfy { $0.direction == direction })
    #expect(ramp.cues.allSatisfy { $0.size == size })
    #expect(ramp.cues.allSatisfy { !$0.isLimited })
    #expect(Set(ramp.cues.map(\.transactionID)).count == 1)
    #expect(ramp.cancelledTransactionIDs.isEmpty)
    let session = try #require(ramp.state.session)
    #expect(session.autoFeedback.transaction?.phase == .arrived)
    #expect(session.autoFeedback.lastSettledTargetSPM == target)
    #expect(abs(session.appliedPlaybackRate - (target / feedbackPulseSPM)) <= 0.005)
}

@Test func aTargetOutsideTheEnvelopeArrivesTruthfullyAtTheLimit() throws {
    let ramp = rampToTarget(from: autoRun(settledTargetSPM: 200), holdingCadenceSPM: 200, steps: 16)

    #expect(ramp.cues.map(\.moment) == [.began, .arrived])
    #expect(ramp.cues.allSatisfy { $0.isLimited })
    #expect(ramp.cues.allSatisfy { $0.direction == .faster })
    let session = try #require(ramp.state.session)
    #expect(session.adaptationState.isAtLimit)
    #expect(abs(session.appliedPlaybackRate - TempoEnvelope.rateRange.upperBound) <= 0.005)
}

@Test func intermediateRampRepliesEmitNothingBetweenTheBeginningAndTheArrival() throws {
    let ramp = rampToTarget(from: autoRun(settledTargetSPM: 188), holdingCadenceSPM: 188)

    #expect(ramp.repliedRates.count >= 3)
    #expect(ramp.cues.count == 2)
    let transaction = try #require(ramp.state.session?.autoFeedback.transaction)
    #expect(transaction.size == .large)
    #expect(transaction.phase == .arrived)
}

@Test func aChangeBelowTheBandFloorOpensNothingAndStillRemembersTheTarget() throws {
    let ramp = rampToTarget(from: autoRun(settledTargetSPM: 172), holdingCadenceSPM: 172)

    #expect(ramp.cues.isEmpty)
    let session = try #require(ramp.state.session)
    #expect(session.autoFeedback.transaction == nil)
    #expect(session.autoFeedback.lastSettledTargetSPM == 172)
}

@Test func aReaffirmedTargetOpensNothingAfterTheFirstTransactionArrived() throws {
    var ramp = rampToTarget(from: autoRun(settledTargetSPM: 180), holdingCadenceSPM: 180)
    #expect(ramp.cues.count == 2)
    let firstTransactionID = try #require(ramp.state.session?.autoFeedback.transaction?.id)

    ramp = rampToTarget(
        from: ramp.state,
        holdingCadenceSPM: 180,
        steps: 6,
        firstToken: 1_100
    )

    #expect(ramp.cues.isEmpty)
    #expect(ramp.state.session?.autoFeedback.transaction?.id == firstTransactionID)
}

@Test func oneFalseSpikeAndOrdinaryNoiseNeverOpenATransaction() throws {
    var state = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 168),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 168,
            deltaSeconds: 1,
            rateRequestID: 800
        )
    ).0

    let spike = feedbackReducer.reduce(
        state: state,
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 188,
            deltaSeconds: 1,
            rateRequestID: 801
        )
    )
    state = spike.0
    let noise = feedbackReducer.reduce(
        state: state,
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 170,
            deltaSeconds: 1,
            rateRequestID: 802
        )
    )

    #expect(cues(spike.1).isEmpty)
    #expect(cues(noise.1).isEmpty)
    let session = try #require(noise.0.session)
    #expect(session.autoFeedback.transaction == nil)
    #expect(session.autoTargetState.settledTargetSPM == 168)
}

@Test func aRejectedReadbackKeepsTheTransactionWaitingWithoutAnyCue() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 180),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 180,
            deltaSeconds: 1,
            rateRequestID: 810
        )
    )
    let command = try #require(commandedRate(opened.1))

    let rejected = feedbackReducer.reduce(
        state: opened.0,
        event: .playbackRateApplied(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID,
            requestID: command.requestID,
            trackID: feedbackTrack.id,
            rate: 1,
            latencySeconds: 0.4
        )
    )

    #expect(rejected.1.isEmpty)
    let session = try #require(rejected.0.session)
    #expect(session.adaptationState.commandStatus == .rejected)
    #expect(session.autoFeedback.transaction?.phase == .committed)
}

@Test func aStaleRequestAndADuplicateReplyCannotEmitASecondCue() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 180),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 180,
            deltaSeconds: 1,
            rateRequestID: 820
        )
    )
    let command = try #require(commandedRate(opened.1))
    let reply = RunEvent.playbackRateApplied(
        sessionID: feedbackSessionID,
        operationID: feedbackSessionID,
        requestID: command.requestID,
        trackID: feedbackTrack.id,
        rate: command.rate,
        latencySeconds: 0.09
    )
    let began = feedbackReducer.reduce(state: opened.0, event: reply)
    #expect(cues(began.1).map(\.moment) == [.began])

    let duplicate = feedbackReducer.reduce(state: began.0, event: reply)
    let stale = feedbackReducer.reduce(
        state: began.0,
        event: .playbackRateApplied(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID,
            requestID: command.requestID - 5,
            trackID: feedbackTrack.id,
            rate: 1.07,
            latencySeconds: 2.4
        )
    )

    #expect(duplicate.1.isEmpty)
    #expect(duplicate.0 == began.0)
    #expect(stale.1.isEmpty)
    #expect(stale.0 == began.0)
}

@Test func aDelayedReplyStillBeginsTheTransactionItMatches() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 156),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 156,
            deltaSeconds: 1,
            rateRequestID: 830
        )
    )
    let command = try #require(commandedRate(opened.1))

    let delayed = feedbackReducer.reduce(
        state: opened.0,
        event: .playbackRateApplied(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID,
            requestID: command.requestID,
            trackID: feedbackTrack.id,
            rate: command.rate,
            latencySeconds: 3.6
        )
    )

    #expect(cues(delayed.1).map(\.moment) == [.began])
    #expect(delayed.0.session?.adaptationState.commandLatencySeconds == 3.6)
}

@Test func manualTakeoverDuringTheRampCancelsTheTransactionAndReturningToAutoOpensANewOne() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 188),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 188,
            deltaSeconds: 1,
            rateRequestID: 840
        )
    )
    let firstTransaction = try #require(opened.0.session?.autoFeedback.transaction)

    let manual = feedbackReducer.reduce(
        state: opened.0,
        event: .rhythmControlSetManual(rateRequestID: 841, timeoutID: 842)
    )
    #expect(cancellations(manual.1) == [firstTransaction.id])
    #expect(manual.0.session?.autoFeedback.transaction == nil)
    #expect(manual.0.session?.autoFeedback.lastSettledTargetSPM == nil)

    let automatic = feedbackReducer.reduce(
        state: manual.0,
        event: .rhythmControlReset(rateRequestID: 843, timeoutID: 844)
    )
    let reopened = try #require(automatic.0.session?.autoFeedback.transaction)

    #expect(reopened.id > firstTransaction.id)
    #expect(reopened.direction == .faster)
    #expect(cues(automatic.1).isEmpty)
}

@Test func pauseAndResumePreserveATransactionThatCanStillArrive() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 175),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 175,
            deltaSeconds: 1,
            rateRequestID: 850
        )
    )
    let command = try #require(commandedRate(opened.1))
    var state = feedbackReducer.reduce(
        state: opened.0,
        event: .playbackRateApplied(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID,
            requestID: command.requestID,
            trackID: feedbackTrack.id,
            rate: command.rate,
            latencySeconds: 0.1
        )
    ).0
    let paused = feedbackReducer.reduce(state: state, event: .pauseTapped)
    #expect(cancellations(paused.1).isEmpty)
    #expect(paused.0.session?.autoFeedback.transaction?.phase == .began)
    state =
        feedbackReducer.reduce(
            state: paused.0,
            event: .resumeTapped(acquisitionID: 1, timeoutID: 851)
        ).0

    let ramp = rampToTarget(
        from: state,
        holdingCadenceSPM: 175,
        steps: 6,
        firstToken: 860
    )

    #expect(ramp.cues.map(\.moment) == [.arrived])
    #expect(ramp.state.session?.autoFeedback.transaction?.phase == .arrived)
}

@Test func routeLossAndInterruptionBothCancelTheTransactionWithoutReplayingIt() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 188),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 188,
            deltaSeconds: 1,
            rateRequestID: 870
        )
    )
    let transaction = try #require(opened.0.session?.autoFeedback.transaction)

    let routeLost = feedbackReducer.reduce(state: opened.0, event: .audioRouteLost)
    let interrupted = feedbackReducer.reduce(
        state: opened.0,
        event: .playbackInterrupted(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID
        )
    )

    #expect(cancellations(routeLost.1) == [transaction.id])
    #expect(cancellations(interrupted.1) == [transaction.id])
    #expect(routeLost.0.session?.autoFeedback.transaction == nil)
    #expect(interrupted.0.session?.autoFeedback.transaction == nil)

    let restored = feedbackReducer.reduce(state: routeLost.0, event: .audioRouteRestored)
    let resumed = feedbackReducer.reduce(
        state: restored.0,
        event: .routeResumeTapped(acquisitionID: 2, timeoutID: 871)
    )
    #expect(cues(restored.1).isEmpty)
    #expect(cues(resumed.1).isEmpty)
}

@Test func aConfirmedDifferentSongClearsTheTransactionAndAnOldReplyCannotArrive() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 188),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 188,
            deltaSeconds: 1,
            rateRequestID: 880
        )
    )
    let command = try #require(commandedRate(opened.1))
    let transaction = try #require(opened.0.session?.autoFeedback.transaction)

    let changed = feedbackReducer.reduce(
        state: opened.0,
        event: .playbackTrackChanged(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID,
            trackID: secondFeedbackTrack.id,
            trackIndex: 1,
            reason: .naturalBoundary,
            rateRequestID: 881
        )
    )

    #expect(cancellations(changed.1) == [transaction.id])
    #expect(cues(changed.1).isEmpty)
    #expect(changed.0.session?.lastTrackChangeReason == .naturalBoundary)
    // The new song carries nothing from the old one. Auto may open a fresh transaction for it, and
    // that transaction has a new identity on the new track.
    let carried = changed.0.session?.autoFeedback.transaction
    #expect(carried?.id != transaction.id)
    #expect(carried?.trackID == secondFeedbackTrack.id)

    let oldSongReply = feedbackReducer.reduce(
        state: changed.0,
        event: .playbackRateApplied(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID,
            requestID: command.requestID,
            trackID: feedbackTrack.id,
            rate: command.rate,
            latencySeconds: 1.9
        )
    )

    #expect(oldSongReply.1.isEmpty)
    #expect(oldSongReply.0 == changed.0)
}

@Test func aNewQualifyingTargetReplacesAnInFlightTransactionSilently() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 188),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 188,
            deltaSeconds: 1,
            rateRequestID: 890
        )
    )
    let first = try #require(opened.0.session?.autoFeedback.transaction)

    var state = opened.0
    var session = try #require(state.session)
    // Auto settled on a different target while the first change was still moving.
    session.autoTargetState = AutoTargetState(
        observedCadenceSPM: 155,
        settledTargetSPM: 155,
        status: .settled
    )
    state = .active(
        ActiveRun(
            session: session,
            activity: .playing(rhythm: .locked(spm: 155), controls: .hidden)
        )
    )

    let replaced = feedbackReducer.reduce(
        state: state,
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 155,
            deltaSeconds: 1,
            rateRequestID: 891
        )
    )
    let second = try #require(replaced.0.session?.autoFeedback.transaction)

    #expect(cancellations(replaced.1) == [first.id])
    #expect(cues(replaced.1).isEmpty)
    #expect(second.id != first.id)
    #expect(second.direction == .slower)
    #expect(second.phase == .committed)
}

@Test func finishCancelsAnInFlightTransactionAndArmsWithItsOwnHaptic() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 188),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 188,
            deltaSeconds: 1,
            rateRequestID: 895
        )
    )
    let transaction = try #require(opened.0.session?.autoFeedback.transaction)
    let revealed = feedbackReducer.reduce(
        state: opened.0,
        event: .surfaceTapped(timeoutID: 896)
    ).0

    let armed = feedbackReducer.reduce(state: revealed, event: .finishTapped)
    #expect(armed.1.first == .emitHaptic(.finishArmed))

    let pressing = feedbackReducer.reduce(state: armed.0, event: .finishHoldBegan(holdID: 897)).0
    let completed = feedbackReducer.reduce(
        state: pressing,
        event: .finishHoldCompleted(holdID: 897)
    )

    #expect(cancellations(completed.1) == [transaction.id])
    #expect(completed.1.contains(.emitHaptic(.finish)))
    #expect(completed.0.session?.autoFeedback.transaction == nil)
}

@Test func repeatedTransportTapsStayRequestsWithOneHapticEach() {
    let state = autoRun(settledTargetSPM: 168)
    let first = feedbackReducer.reduce(state: state, event: .skipTapped)
    let second = feedbackReducer.reduce(state: first.0, event: .skipTapped)
    let previous = feedbackReducer.reduce(state: second.0, event: .previousTapped)

    #expect(first.0 == state)
    #expect(second.0 == state)
    #expect(previous.0 == state)
    #expect(
        first.1 == [
            .emitHaptic(.transportRequest),
            .skipTrack(sessionID: feedbackSessionID),
        ]
    )
    #expect(
        previous.1 == [
            .emitHaptic(.transportRequest),
            .previousTrack(sessionID: feedbackSessionID),
        ]
    )
}

@Test func transportStaysAvailableWhileASpeedCommandIsStillPending() throws {
    let opened = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 188),
        event: .cadenceUpdated(
            sessionID: feedbackSessionID,
            acquisitionID: 1,
            stepsPerMinute: 188,
            deltaSeconds: 1,
            rateRequestID: 898
        )
    )
    #expect(opened.0.session?.pendingRateRequestID == 898)

    let skipped = feedbackReducer.reduce(state: opened.0, event: .skipTapped)
    let paused = feedbackReducer.reduce(state: opened.0, event: .pauseTapped)

    #expect(skipped.1.contains(.skipTrack(sessionID: feedbackSessionID)))
    #expect(paused.1.contains(.pausePlayback(sessionID: feedbackSessionID)))
    #expect(skipped.0.session?.autoFeedback.transaction != nil)
    #expect(paused.0.session?.autoFeedback.transaction != nil)
}

@Test(
    arguments: [
        TrackChangeReason.naturalBoundary,
        TrackChangeReason.externalUnknown,
        TrackChangeReason.explicitSkip,
        TrackChangeReason.explicitPrevious,
    ]
)
func everyConfirmedSongChangeRecordsItsCause(reason: TrackChangeReason) throws {
    let changed = feedbackReducer.reduce(
        state: autoRun(settledTargetSPM: 168),
        event: .playbackTrackChanged(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID,
            trackID: secondFeedbackTrack.id,
            trackIndex: 1,
            reason: reason,
            rateRequestID: 899
        )
    )

    #expect(changed.0.session?.lastTrackChangeReason == reason)
    #expect(changed.0.session?.currentTrackID == secondFeedbackTrack.id)
}

@Test func aConfirmedSameSongCallbackChangesNothingIncludingTheRecordedCause() throws {
    let state = autoRun(settledTargetSPM: 168)
    let callback = feedbackReducer.reduce(
        state: state,
        event: .playbackTrackChanged(
            sessionID: feedbackSessionID,
            operationID: feedbackSessionID,
            trackID: feedbackTrack.id,
            trackIndex: 0,
            reason: .explicitSkip,
            rateRequestID: 900
        )
    )

    #expect(callback.0 == state)
    #expect(callback.1.isEmpty)
    #expect(callback.0.session?.lastTrackChangeReason == nil)
}
