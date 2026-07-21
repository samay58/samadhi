import Testing

@testable import SamadhiDomain

private let reducer = RunReducer()
private let coreLoopTrack = MusicTrack(
    id: MusicTrackID("1066177773"),
    title: "Shake It Off (Workout Remix 170 Bpm)",
    durationSeconds: 248.442,
    tempo: TempoAnalysis(
        baseBPM: 170.25,
        confidence: 1,
        analyzedDurationSeconds: 30,
        version: 2
    )
)
private let coreLoopReducer = RunReducer(tracks: [coreLoopTrack])
private let transitionTrack = MusicTrack(
    id: MusicTrackID("transition-track"),
    title: "Transition",
    durationSeconds: 210,
    tempo: TempoAnalysis(
        baseBPM: 160,
        confidence: 1,
        analyzedDurationSeconds: 30,
        version: 2
    )
)

private let slowTrack = MusicTrack(
    id: MusicTrackID("slow-track"),
    title: "Slow",
    durationSeconds: 210,
    tempo: TempoAnalysis(
        baseBPM: 148,
        confidence: 1,
        analyzedDurationSeconds: 30,
        version: 2
    )
)

@Test func adaptivePreparationChoosesTheClosestTrackToTheInitialPrior() {
    let planningReducer = RunReducer(tracks: [slowTrack, coreLoopTrack])
    let state = planningReducer.reduce(
        state: .ready,
        event: .startTapped(sessionID: 200)
    ).0

    let result = planningReducer.reduce(
        state: state,
        event: .authorizationResolved(sessionID: 200, .authorized)
    )

    #expect(
        result.1 == [
            .preparePlayback(
                sessionID: 200,
                mode: .adaptive,
                startingTrackID: coreLoopTrack.id
            )
        ]
    )
}

@Test func preparedTrackSetsItsRealCollectionIndex() {
    let planningReducer = RunReducer(tracks: [slowTrack, coreLoopTrack])
    var state = planningReducer.reduce(
        state: .ready,
        event: .startTapped(sessionID: 201)
    ).0
    state =
        planningReducer.reduce(
            state: state,
            event: .authorizationResolved(sessionID: 201, .authorized)
        ).0

    let result = planningReducer.reduce(
        state: state,
        event: .playbackPrepared(sessionID: 201, trackID: coreLoopTrack.id)
    )

    #expect(result.0.session?.currentTrackID == coreLoopTrack.id)
    #expect(result.0.session?.trackIndex == 1)
}

@Test func incompatibleTrackMustStayOutsideTheEnvelopeForFiveSeconds() {
    let planningReducer = RunReducer(tracks: [slowTrack, coreLoopTrack])
    var state = incompatibleRun()

    var result = planningReducer.reduce(
        state: state,
        event: .cadenceUpdated(
            sessionID: 202,
            acquisitionID: 1,
            stepsPerMinute: 168,
            deltaSeconds: 4,
            rateRequestID: 300
        )
    )
    state = result.0
    #expect(result.1.isEmpty)

    result = planningReducer.reduce(
        state: state,
        event: .cadenceUpdated(
            sessionID: 202,
            acquisitionID: 1,
            stepsPerMinute: 168,
            deltaSeconds: 1,
            rateRequestID: 301
        )
    )

    #expect(
        result.1 == [
            .prepareNextTrack(
                sessionID: 202,
                operationID: 202,
                selectionID: 301,
                trackID: coreLoopTrack.id
            )
        ]
    )
    #expect(result.0.session?.pendingTrackSelectionID == 301)
}

@Test func stalePreparedSelectionCannotReplaceANewerPlan() {
    let planningReducer = RunReducer(tracks: [slowTrack, coreLoopTrack])
    var state = incompatibleRun()
    state =
        planningReducer.reduce(
            state: state,
            event: .cadenceUpdated(
                sessionID: 202,
                acquisitionID: 1,
                stepsPerMinute: 168,
                deltaSeconds: 5,
                rateRequestID: 301
            )
        ).0

    let stale = planningReducer.reduce(
        state: state,
        event: .nextTrackPrepared(
            sessionID: 202,
            operationID: 202,
            selectionID: 300,
            trackID: coreLoopTrack.id
        )
    )
    #expect(stale.0 == state)

    let current = planningReducer.reduce(
        state: state,
        event: .nextTrackPrepared(
            sessionID: 202,
            operationID: 202,
            selectionID: 301,
            trackID: coreLoopTrack.id
        )
    )
    #expect(current.0.session?.pendingTrackSelectionID == nil)
    #expect(current.0.session?.preparedNextTrackID == coreLoopTrack.id)
}

@Test func compatibilityRecoveryInvalidatesAnOutstandingSelection() {
    let planningReducer = RunReducer(tracks: [slowTrack, coreLoopTrack])
    var state = incompatibleRun()
    state =
        planningReducer.reduce(
            state: state,
            event: .cadenceUpdated(
                sessionID: 202,
                acquisitionID: 1,
                stepsPerMinute: 168,
                deltaSeconds: 5,
                rateRequestID: 301
            )
        ).0

    let result = planningReducer.reduce(
        state: state,
        event: .cadenceUpdated(
            sessionID: 202,
            acquisitionID: 1,
            stepsPerMinute: 148,
            deltaSeconds: 1,
            rateRequestID: 302
        )
    )
    state = result.0

    #expect(state.session?.pendingTrackSelectionID == nil)
    #expect(state.session?.incompatibleTrackSeconds == 0)
    #expect(
        result.1 == [
            .clearPreparedNextTrack(
                sessionID: 202,
                operationID: 202,
                selectionID: 302
            )
        ]
    )
}

@Test func adaptiveStartLocksAndRecordsOnlyEligibleTime() {
    var state: RunState = .ready
    state = reducer.reduce(state: state, event: .startTapped(sessionID: 7)).0
    state = reducer.reduce(state: state, event: .authorizationResolved(sessionID: 7, .authorized)).0
    state =
        reducer.reduce(
            state: state,
            event: .playbackPrepared(sessionID: 7, trackID: MusicTrackID("demo-0"))
        ).0

    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0
    #expect(state.session?.elapsedActiveSeconds == 0)

    state =
        reducer.reduce(
            state: state,
            event: .cadenceUpdated(
                sessionID: 7,
                acquisitionID: 1,
                stepsPerMinute: 168,
                deltaSeconds: 1,
                rateRequestID: 2
            )
        ).0
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0

    #expect(state.session?.elapsedActiveSeconds == 2)
    #expect(state.session?.summary.averageCadence == 168)
    #expect(state.session?.summary.tempoMatchedPercent == 100)
}

@Test func staleCadenceAndTimeoutTokensDoNothing() {
    var state = lockedRun()
    let locked = state
    state =
        reducer.reduce(
            state: state,
            event: .cadenceUpdated(
                sessionID: 1,
                acquisitionID: 999,
                stepsPerMinute: 190,
                deltaSeconds: 1,
                rateRequestID: 20
            )
        ).0
    #expect(state == locked)

    state = reducer.reduce(state: state, event: .surfaceTapped(timeoutID: 4)).0
    let visible = state
    state = reducer.reduce(state: state, event: .controlsTimedOut(timeoutID: 3)).0
    #expect(state == visible)
    state = reducer.reduce(state: state, event: .controlsTimedOut(timeoutID: 4)).0
    #expect(state != visible)
}

@Test func surfaceTapCannotReplaceAnOpenRhythmControl() {
    var state = reducer.reduce(
        state: lockedRun(),
        event: .rhythmControlRevealed(timeoutID: 4)
    ).0
    let rhythmVisible = state

    state = reducer.reduce(state: state, event: .surfaceTapped(timeoutID: 5)).0

    #expect(state == rhythmVisible)
}

@Test func pauseExcludesTimeAndResumeReacquiresWithPrior() {
    var state = lockedRun()
    state = reducer.reduce(state: state, event: .surfaceTapped(timeoutID: 2)).0
    state = reducer.reduce(state: state, event: .pauseTapped).0
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: nil)).0
    #expect(state.session?.elapsedActiveSeconds == 0)

    state = reducer.reduce(state: state, event: .resumeTapped(acquisitionID: 8, timeoutID: 9)).0
    guard case let .active(active) = state,
        case let .playing(
            .acquiring(prior, acquisitionID),
            .timed(surface, timeoutID)
        ) = active.activity
    else {
        Issue.record("Expected reacquiring run")
        return
    }
    #expect(prior == 168)
    #expect(acquisitionID == 8)
    #expect(surface == .transport)
    #expect(timeoutID == 9)
}

@Test func permissionDenialHasHonestFixedRhythmFallback() {
    var state: RunState = .ready
    state = reducer.reduce(state: state, event: .startTapped(sessionID: 10)).0
    state = reducer.reduce(state: state, event: .authorizationResolved(sessionID: 10, .denied)).0
    guard case .permissionRecovery = state else {
        Issue.record("Expected permission recovery")
        return
    }

    state = reducer.reduce(state: state, event: .useFixedRhythmTapped).0
    state =
        reducer.reduce(
            state: state,
            event: .playbackPrepared(sessionID: 10, trackID: MusicTrackID("demo-0"))
        ).0
    guard case let .active(active) = state,
        case .playing(.fixed, .hidden) = active.activity
    else {
        Issue.record("Expected fixed rhythm playback")
        return
    }
    #expect(active.session.mode == .fixed)
}

@Test func routeRestorationNeverAutoResumesPlayingOrigin() {
    var state = lockedRun()
    state = reducer.reduce(state: state, event: .audioRouteLost).0
    state = reducer.reduce(state: state, event: .audioRouteRestored).0
    guard case let .routeRecovery(recovery) = state else {
        Issue.record("Expected route recovery")
        return
    }
    #expect(recovery.availability == .restored)

    state = reducer.reduce(state: state, event: .routeResumeTapped(acquisitionID: 12, timeoutID: 13)).0
    guard case let .active(active) = state,
        case let .playing(
            .acquiring(prior, acquisitionID),
            .timed(surface, timeoutID)
        ) = active.activity
    else {
        Issue.record("Expected explicit reacquisition")
        return
    }
    #expect(prior == 168)
    #expect(acquisitionID == 12)
    #expect(surface == .transport)
    #expect(timeoutID == 13)
}

@Test func rhythmControlStartsInAutomaticAndResetsForEveryRun() {
    var prior = RunSession(id: 1)
    prior.rhythmControl = RhythmControlState(mode: .manual, manualTargetBPM: 176)

    let next = RunSession(id: 2)

    #expect(prior.rhythmControl.mode == .manual)
    #expect(next.rhythmControl == .initial)
}

@Test func manualControlAdjustsMusicBeforeCadenceLocks() {
    let state = acquiringCoreLoopRun(sessionID: 61)
    let result = coreLoopReducer.reduce(
        state: state,
        event: .rhythmControlSetManual(rateRequestID: 62, timeoutID: 63)
    )

    guard case let .active(active) = result.0,
        case let .playing(.acquiring, .timed(surface, timeoutID)) = active.activity
    else {
        Issue.record("Expected visible manual rhythm control")
        return
    }
    #expect(active.session.rhythmControl.mode == .manual)
    #expect(active.session.rhythmControl.manualTargetBPM == 168)
    #expect(active.session.adaptationState.requestedBPM == 168)
    #expect(active.session.adaptationState.lastReliableCadenceSPM == nil)
    #expect(surface == .rhythm)
    #expect(timeoutID == 63)
    #expect(
        result.1 == [
            .emitHaptic(.rhythmStep),
            .setPlaybackRate(
                sessionID: 61,
                operationID: 61,
                requestID: 62,
                trackID: coreLoopTrack.id,
                rate: 168.0 / 170.25
            ),
            .scheduleControlsTimeout(sessionID: 61, timeoutID: 63),
        ]
    )
}

@Test func manualTimeWithoutCadenceRemainsNotMeasured() {
    var state = acquiringCoreLoopRun(sessionID: 64)
    state =
        coreLoopReducer.reduce(
            state: state,
            event: .rhythmControlSetManual(rateRequestID: 65, timeoutID: 66)
        ).0
    state = coreLoopReducer.reduce(state: state, event: .activeSecond(tempoMatched: nil)).0

    #expect(state.session?.elapsedActiveSeconds == 1)
    #expect(state.session?.summary.averageCadence == nil)
    #expect(state.session?.summary.tempoMatchedPercent == nil)
}

@Test func manualTargetSurvivesConfidenceLossWithoutLeavingStaleCadenceLocked() {
    var state = coreLoopReducer.reduce(
        state: acquiringCoreLoopRun(sessionID: 68),
        event: .cadenceUpdated(
            sessionID: 68,
            acquisitionID: 1,
            stepsPerMinute: 168,
            deltaSeconds: 1,
            rateRequestID: 69
        )
    ).0
    state =
        coreLoopReducer.reduce(
            state: state,
            event: .rhythmControlSetManual(rateRequestID: 70, timeoutID: 71)
        ).0

    let result = coreLoopReducer.reduce(
        state: state,
        event: .cadenceConfidenceLost(
            sessionID: 68,
            acquisitionID: 1,
            deltaSeconds: 10,
            rateRequestID: 72
        )
    )

    guard case let .active(active) = result.0,
        case .playing(.acquiring, _) = active.activity
    else {
        Issue.record("Expected cadence acquisition while manual music target remains active")
        return
    }
    #expect(active.session.rhythmControl.mode == .manual)
    #expect(active.session.adaptationState.requestedBPM == 168)
    #expect(active.session.adaptationState.lastReliableCadenceSPM == nil)
}

@Test func automaticFineTuneClampsAtEightBPM() {
    var state = acquiringCoreLoopRun(sessionID: 67)
    var stepHapticCount = 0
    var finalEffects: [RunEffect] = []
    for step in 0..<9 {
        let result = coreLoopReducer.reduce(
            state: state,
            event: .rhythmControlAdjusted(
                steps: 1,
                rateRequestID: 70 + step,
                timeoutID: 90 + step
            )
        )
        state = result.0
        finalEffects = result.1
        if result.1.contains(.emitHaptic(.rhythmStep)) {
            stepHapticCount += 1
        }
    }

    #expect(state.session?.rhythmControl.automaticCorrectionBPM == 8)
    #expect(stepHapticCount == 8)
    #expect(finalEffects.contains(.emitHaptic(.rhythmLimit)))
}

@Test func resetReturnsFineTuneToNeutralAutomaticMode() {
    var state = acquiringCoreLoopRun(sessionID: 74)
    state =
        coreLoopReducer.reduce(
            state: state,
            event: .rhythmControlAdjusted(steps: 3, rateRequestID: 75, timeoutID: 76)
        ).0

    let result = coreLoopReducer.reduce(
        state: state,
        event: .rhythmControlReset(rateRequestID: 77, timeoutID: 78)
    )

    #expect(result.0.session?.rhythmControl == .initial)
    #expect(result.1.contains(.emitHaptic(.rhythmAuto)))
}

@Test func manualOwnershipSurvivesPauseResumeAndRecomputesForTheNextTrack() {
    let transitionReducer = RunReducer(tracks: [coreLoopTrack, transitionTrack])
    var state: RunState = .ready
    state = transitionReducer.reduce(state: state, event: .startTapped(sessionID: 79)).0
    state =
        transitionReducer.reduce(
            state: state,
            event: .authorizationResolved(sessionID: 79, .authorized)
        ).0
    state =
        transitionReducer.reduce(
            state: state,
            event: .playbackPrepared(sessionID: 79, trackID: coreLoopTrack.id)
        ).0
    state =
        transitionReducer.reduce(
            state: state,
            event: .rhythmControlSetManual(rateRequestID: 80, timeoutID: 81)
        ).0
    state = transitionReducer.reduce(state: state, event: .pauseTapped).0
    state =
        transitionReducer.reduce(
            state: state,
            event: .resumeTapped(acquisitionID: 82, timeoutID: 83)
        ).0

    let result = transitionReducer.reduce(
        state: state,
        event: .playbackTrackChanged(
            sessionID: 79,
            operationID: 79,
            trackID: transitionTrack.id,
            trackIndex: 1,
            rateRequestID: 84
        )
    )

    #expect(result.0.session?.rhythmControl.mode == .manual)
    #expect(result.0.session?.adaptationState.derivedTargetRate == 1.05)
    #expect(
        result.1 == [
            .setPlaybackRate(
                sessionID: 79,
                operationID: 79,
                requestID: 84,
                trackID: transitionTrack.id,
                rate: 1.02
            )
        ]
    )
}

@Test func finishRequiresVisibleControlsAndMatchingHold() {
    var state = lockedRun()
    let hidden = state
    state = reducer.reduce(state: state, event: .finishTapped).0
    #expect(state == hidden)

    state = reducer.reduce(state: state, event: .surfaceTapped(timeoutID: 2)).0
    state = reducer.reduce(state: state, event: .finishTapped).0
    state = reducer.reduce(state: state, event: .finishHoldBegan(holdID: 30)).0
    let pressing = state
    state = reducer.reduce(state: state, event: .finishHoldCompleted(holdID: 29)).0
    #expect(state == pressing)
    state = reducer.reduce(state: state, event: .finishHoldCompleted(holdID: 30)).0
    guard case .finishing = state else {
        Issue.record("Expected finishing")
        return
    }
}

@Test func pauseCancelsTransientWorkBeforeStoppingPlayback() {
    let result = reducer.reduce(state: lockedRun(), event: .pauseTapped)
    #expect(
        result.1 == [
            .cancelTask(sessionID: 1, .acquisition),
            .cancelTask(sessionID: 1, .controlsTimeout),
            .cancelTask(sessionID: 1, .ticker),
            .pausePlayback(sessionID: 1),
            .emitHaptic(.pause),
        ])
}

@Test func routeLossCancelsAllWorkAndPausesPlayback() {
    let result = reducer.reduce(state: lockedRun(), event: .audioRouteLost)
    #expect(
        result.1 == [
            .cancelAllTasks(sessionID: 1),
            .pausePlayback(sessionID: 1),
        ])
}

@Test func voiceOverFocusPinsControlsAndReschedulesTimeoutOnExit() {
    var state = reducer.reduce(state: lockedRun(), event: .surfaceTapped(timeoutID: 5)).0
    var result = reducer.reduce(state: state, event: .controlsFocusEntered)
    state = result.0
    #expect(result.1 == [.cancelTask(sessionID: 1, .controlsTimeout)])

    result = reducer.reduce(state: state, event: .controlsTimedOut(timeoutID: 5))
    #expect(result.0 == state)

    result = reducer.reduce(state: state, event: .controlsFocusExited(timeoutID: 6))
    #expect(result.1 == [.scheduleControlsTimeout(sessionID: 1, timeoutID: 6)])
}

@Test func finishingBuildsMixedSummaryMetrics() {
    var session = RunSession(id: 21)
    session.recordSecond(cadence: 160, tempoMatched: true)
    session.recordSecond(cadence: 180, tempoMatched: false)
    session.songCount = 3

    let result = reducer.reduce(state: .finishing(session), event: .finishCompleted(sessionID: 21))
    let expected = RunSummary(durationSeconds: 2, averageCadence: 170, tempoMatchedPercent: 50, songCount: 3)
    #expect(result.0 == .summary(expected))
    #expect(result.1.isEmpty)
}

@Test func fixedRhythmSummaryDoesNotPretendTempoWasMeasured() {
    var session = RunSession(id: 22, mode: .fixed)
    session.recordSecond(cadence: nil, tempoMatched: nil)

    #expect(session.summary.tempoMatchedPercent == nil)
}

@Test func skipWaitsForPlayerTruthBeforeChangingTheSong() {
    var state = lockedRun()
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0
    #expect(state.session?.trackElapsedSeconds == 2)

    let result = reducer.reduce(state: state, event: .skipTapped)
    #expect(result.0.session?.trackElapsedSeconds == 2)
    #expect(result.0.session?.trackIndex == 0)
    #expect(result.0.session?.songCount == 1)
    #expect(result.1 == [.skipTrack(sessionID: 1)])
}

@Test func previousWaitsForPlayerTruthBeforeChangingTheSong() {
    let state = lockedRun()
    let result = reducer.reduce(state: state, event: .previousTapped)

    #expect(result.0 == state)
    #expect(result.1 == [.previousTrack(sessionID: 1)])
}

@Test func playbackProgressRequiresCurrentSessionAndOperation() {
    let state = lockedRun()
    let stale = reducer.reduce(
        state: state,
        event: .playbackProgress(
            sessionID: 1,
            operationID: 999,
            trackIndex: 1,
            elapsedSeconds: 42,
            durationSeconds: 180
        )
    ).0
    #expect(stale == state)

    let current = reducer.reduce(
        state: state,
        event: .playbackProgress(
            sessionID: 1,
            operationID: 1,
            trackIndex: 1,
            elapsedSeconds: 42,
            durationSeconds: 180
        )
    ).0
    #expect(current.session?.trackIndex == 1)
    #expect(current.session?.trackElapsedSeconds == 42)
    #expect(current.session?.trackDurationSeconds == 180)
    #expect(current.session?.songCount == 2)
}

@Test func playbackPreparationFailureReturnsToReadyOnlyForCurrentOperation() {
    var state = reducer.reduce(state: .ready, event: .startTapped(sessionID: 51)).0
    state =
        reducer.reduce(
            state: state,
            event: .authorizationResolved(sessionID: 51, .authorized)
        ).0

    let stale = reducer.reduce(
        state: state,
        event: .playbackFailed(sessionID: 51, operationID: 50)
    )
    #expect(stale.0 == state)
    #expect(stale.1.isEmpty)

    let current = reducer.reduce(
        state: state,
        event: .playbackFailed(sessionID: 51, operationID: 51)
    )
    #expect(current.0 == .ready)
    #expect(current.1 == [.cancelAllTasks(sessionID: 51)])
}

@Test func stableCadenceProducesIdentifiedBoundedRateEffect() {
    let state = acquiringCoreLoopRun(sessionID: 71)
    let result = coreLoopReducer.reduce(
        state: state,
        event: .cadenceUpdated(
            sessionID: 71,
            acquisitionID: 1,
            stepsPerMinute: 166,
            deltaSeconds: 1,
            rateRequestID: 80
        )
    )

    guard case let .active(active) = result.0,
        case let .playing(.locked(spm), _) = active.activity
    else {
        Issue.record("Expected locked adaptive run")
        return
    }
    #expect(spm == 166)
    #expect(active.session.pendingRateRequestID == 80)
    #expect(
        result.1 == [
            .emitHaptic(.lock),
            .setPlaybackRate(
                sessionID: 71,
                operationID: 71,
                requestID: 80,
                trackID: coreLoopTrack.id,
                rate: 0.98
            ),
        ])
}

@Test func appliedRateFeedbackRequiresCurrentSessionRequestAndTrack() {
    var state = coreLoopReducer.reduce(
        state: acquiringCoreLoopRun(sessionID: 72),
        event: .cadenceUpdated(
            sessionID: 72,
            acquisitionID: 1,
            stepsPerMinute: 166,
            deltaSeconds: 1,
            rateRequestID: 81
        )
    ).0
    let waiting = state

    state =
        coreLoopReducer.reduce(
            state: state,
            event: .playbackRateApplied(
                sessionID: 72,
                operationID: 72,
                requestID: 80,
                trackID: coreLoopTrack.id,
                rate: 0.98
            )
        ).0
    #expect(state == waiting)

    state =
        coreLoopReducer.reduce(
            state: state,
            event: .playbackRateApplied(
                sessionID: 72,
                operationID: 72,
                requestID: 81,
                trackID: MusicTrackID("wrong-track"),
                rate: 0.98
            )
        ).0
    #expect(state == waiting)

    state =
        coreLoopReducer.reduce(
            state: state,
            event: .playbackRateApplied(
                sessionID: 72,
                operationID: 72,
                requestID: 81,
                trackID: coreLoopTrack.id,
                rate: 0.98
            )
        ).0
    #expect(state.session?.appliedPlaybackRate == 0.98)
    #expect(state.session?.pendingRateRequestID == nil)
}

@Test func sustainedConfidenceLossHoldsThenReturnsTowardNormal() {
    var state = coreLoopReducer.reduce(
        state: acquiringCoreLoopRun(sessionID: 73),
        event: .cadenceUpdated(
            sessionID: 73,
            acquisitionID: 1,
            stepsPerMinute: 176,
            deltaSeconds: 1,
            rateRequestID: 82
        )
    ).0
    state =
        coreLoopReducer.reduce(
            state: state,
            event: .playbackRateApplied(
                sessionID: 73,
                operationID: 73,
                requestID: 82,
                trackID: coreLoopTrack.id,
                rate: 1.02
            )
        ).0

    let held = coreLoopReducer.reduce(
        state: state,
        event: .cadenceConfidenceLost(
            sessionID: 73,
            acquisitionID: 1,
            deltaSeconds: 6,
            rateRequestID: 83
        )
    )
    #expect(held.1.isEmpty)

    let easing = coreLoopReducer.reduce(
        state: held.0,
        event: .cadenceConfidenceLost(
            sessionID: 73,
            acquisitionID: 1,
            deltaSeconds: 2,
            rateRequestID: 84
        )
    )
    #expect(
        easing.1 == [
            .setPlaybackRate(
                sessionID: 73,
                operationID: 73,
                requestID: 84,
                trackID: coreLoopTrack.id,
                rate: 1.01
            )
        ])

    let acquiring = coreLoopReducer.reduce(
        state: easing.0,
        event: .cadenceConfidenceLost(
            sessionID: 73,
            acquisitionID: 1,
            deltaSeconds: 2,
            rateRequestID: 85
        )
    )
    guard case let .active(active) = acquiring.0,
        case .playing(.acquiring, _) = active.activity
    else {
        Issue.record("Expected acquisition after confidence timeout")
        return
    }
    #expect(
        acquiring.1 == [
            .setPlaybackRate(
                sessionID: 73,
                operationID: 73,
                requestID: 85,
                trackID: coreLoopTrack.id,
                rate: 1
            )
        ])
}

@Test func oldSessionCannotApplyRateToReplacementRun() {
    var replacement = acquiringCoreLoopRun(sessionID: 91)
    replacement =
        coreLoopReducer.reduce(
            state: replacement,
            event: .cadenceUpdated(
                sessionID: 91,
                acquisitionID: 1,
                stepsPerMinute: 166,
                deltaSeconds: 1,
                rateRequestID: 92
            )
        ).0

    let result = coreLoopReducer.reduce(
        state: replacement,
        event: .playbackRateApplied(
            sessionID: 90,
            operationID: 90,
            requestID: 92,
            trackID: coreLoopTrack.id,
            rate: 0.98
        )
    )

    #expect(result.0 == replacement)
    #expect(result.1.isEmpty)
}

@Test func cadenceProviderFailurePausesCurrentRunOnly() {
    let state = acquiringCoreLoopRun(sessionID: 101)
    let stale = coreLoopReducer.reduce(
        state: state,
        event: .cadenceAcquisitionFailed(sessionID: 101, acquisitionID: 999)
    )
    #expect(stale.0 == state)
    #expect(stale.1.isEmpty)

    let current = coreLoopReducer.reduce(
        state: state,
        event: .cadenceAcquisitionFailed(sessionID: 101, acquisitionID: 1)
    )
    guard case .permissionRecovery = current.0 else {
        Issue.record("Expected permission recovery")
        return
    }
    #expect(
        current.1 == [
            .cancelTask(sessionID: 101, .acquisition),
            .cancelTask(sessionID: 101, .ticker),
            .pausePlayback(sessionID: 101),
        ])
}

private func lockedRun() -> RunState {
    let session = RunSession(id: 1)
    return .active(ActiveRun(session: session, activity: .playing(rhythm: .locked(spm: 168), controls: .hidden)))
}

private func acquiringCoreLoopRun(sessionID: Int) -> RunState {
    var state: RunState = .ready
    state = coreLoopReducer.reduce(state: state, event: .startTapped(sessionID: sessionID)).0
    state =
        coreLoopReducer.reduce(
            state: state,
            event: .authorizationResolved(sessionID: sessionID, .authorized)
        ).0
    return
        coreLoopReducer.reduce(
            state: state,
            event: .playbackPrepared(sessionID: sessionID, trackID: coreLoopTrack.id)
        ).0
}

private func incompatibleRun() -> RunState {
    var session = RunSession(id: 202)
    session.currentTrackID = slowTrack.id
    session.cadenceAcquisitionID = 1
    return .active(
        ActiveRun(
            session: session,
            activity: .playing(rhythm: .locked(spm: 168), controls: .hidden)
        )
    )
}
