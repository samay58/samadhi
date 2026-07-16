import Testing

@testable import SamadhiDomain

private let reducer = RunReducer()

@Test func adaptiveStartLocksAndRecordsOnlyEligibleTime() {
    var state: RunState = .ready
    state = reducer.reduce(state: state, event: .startTapped(sessionID: 7)).0
    state = reducer.reduce(state: state, event: .authorizationResolved(sessionID: 7, .authorized)).0
    state = reducer.reduce(state: state, event: .playbackPrepared(sessionID: 7)).0

    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0
    #expect(state.session?.elapsedActiveSeconds == 0)

    state = reducer.reduce(state: state, event: .cadenceLocked(sessionID: 7, acquisitionID: 1, spm: 168)).0
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0

    #expect(state.session?.elapsedActiveSeconds == 2)
    #expect(state.session?.summary.averageCadence == 168)
    #expect(state.session?.summary.tempoMatchedPercent == 100)
}

@Test func staleCadenceAndTimeoutTokensDoNothing() {
    var state = lockedRun()
    let locked = state
    state = reducer.reduce(state: state, event: .cadenceLocked(sessionID: 1, acquisitionID: 999, spm: 190)).0
    #expect(state == locked)

    state = reducer.reduce(state: state, event: .surfaceTapped(timeoutID: 4)).0
    let visible = state
    state = reducer.reduce(state: state, event: .controlsTimedOut(timeoutID: 3)).0
    #expect(state == visible)
    state = reducer.reduce(state: state, event: .controlsTimedOut(timeoutID: 4)).0
    #expect(state != visible)
}

@Test func pauseExcludesTimeAndResumeReacquiresWithPrior() {
    var state = lockedRun()
    state = reducer.reduce(state: state, event: .surfaceTapped(timeoutID: 2)).0
    state = reducer.reduce(state: state, event: .pauseTapped).0
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: nil)).0
    #expect(state.session?.elapsedActiveSeconds == 0)

    state = reducer.reduce(state: state, event: .resumeTapped(acquisitionID: 8, timeoutID: 9)).0
    guard case let .active(active) = state,
        case let .playing(.acquiring(prior, acquisitionID), .timed(timeoutID)) = active.activity
    else {
        Issue.record("Expected reacquiring run")
        return
    }
    #expect(prior == 168)
    #expect(acquisitionID == 8)
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
    state = reducer.reduce(state: state, event: .playbackPrepared(sessionID: 10)).0
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
        case let .playing(.acquiring(prior, acquisitionID), .timed(timeoutID)) = active.activity
    else {
        Issue.record("Expected explicit reacquisition")
        return
    }
    #expect(prior == 168)
    #expect(acquisitionID == 12)
    #expect(timeoutID == 13)
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

@Test func changingTracksResetsSongProgress() {
    var state = lockedRun()
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0
    state = reducer.reduce(state: state, event: .activeSecond(tempoMatched: true)).0
    #expect(state.session?.trackElapsedSeconds == 2)

    let result = reducer.reduce(state: state, event: .skipTapped)
    #expect(result.0.session?.trackElapsedSeconds == 0)
    #expect(result.0.session?.trackIndex == 1)
    #expect(result.0.session?.songCount == 2)
    #expect(result.1 == [.skipTrack(sessionID: 1)])
}

@Test func trackNavigationUsesConfiguredCollectionSize() {
    let twoTrackReducer = RunReducer(trackCount: 2)

    var state = twoTrackReducer.reduce(state: lockedRun(), event: .previousTapped).0
    #expect(state.session?.trackIndex == 1)

    state = twoTrackReducer.reduce(state: state, event: .skipTapped).0
    #expect(state.session?.trackIndex == 0)
}

private func lockedRun() -> RunState {
    let session = RunSession(id: 1)
    return .active(ActiveRun(session: session, activity: .playing(rhythm: .locked(spm: 168), controls: .hidden)))
}
