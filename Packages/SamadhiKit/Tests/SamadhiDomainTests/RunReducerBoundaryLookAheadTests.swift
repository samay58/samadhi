import Testing

@testable import SamadhiDomain

// A walking-cadence collection shaped like the August 19 walk: two songs reach 108 steps per
// minute inside the rate window, two cannot.
private func song(_ id: String, bpm: Double) -> MusicTrack {
    MusicTrack(
        id: MusicTrackID(id),
        title: id,
        durationSeconds: 200,
        tempo: TempoAnalysis(baseBPM: bpm, confidence: 1, analyzedDurationSeconds: 30, version: 5)
    )
}

private let numb = song("numb", bpm: 126)
private let nightrider = song("nightrider", bpm: 164)
private let bermuda = song("bermuda", bpm: 120)
private let weightOff = song("weight-off", bpm: 160)
private let walkTargetSPM = 108.0
private let sessionID = 808

private func walkingRun(
    tracks: [MusicTrack],
    current: MusicTrack,
    elapsedSeconds: Int = 170,
    durationSeconds: Int = 200
) -> RunState {
    var session = RunSession(id: sessionID)
    session.currentTrackID = current.id
    session.trackIndex = tracks.firstIndex(where: { $0.id == current.id }) ?? 0
    session.queueAnchorIndex = session.trackIndex
    session.cadenceAcquisitionID = 1
    session.trackElapsedSeconds = elapsedSeconds
    session.trackDurationSeconds = durationSeconds
    session.autoTargetState = AutoTargetState(
        observedCadenceSPM: walkTargetSPM,
        settledTargetSPM: walkTargetSPM,
        status: .settled
    )
    return .active(
        ActiveRun(
            session: session,
            activity: .playing(rhythm: .locked(spm: Int(walkTargetSPM)), controls: .hidden)
        )
    )
}

private func progress(elapsed: Int = 171, duration: Int = 200, selectionID: Int = 77) -> RunEvent {
    .playbackProgress(
        sessionID: sessionID,
        operationID: sessionID,
        trackIndex: 0,
        elapsedSeconds: elapsed,
        durationSeconds: duration,
        selectionID: selectionID
    )
}

@Test func aQueuedSongThatFitsStaysQueued() {
    let reducer = RunReducer(tracks: [numb, bermuda, nightrider, weightOff])
    let (state, effects) = reducer.reduce(
        state: walkingRun(tracks: [numb, bermuda, nightrider, weightOff], current: numb),
        event: progress()
    )

    #expect(effects.isEmpty)
    #expect(state.session?.nextSongOutlook == .queuedSongFits)
    #expect(state.session?.pendingNextTrackID == nil)
}

@Test func anUnfitQueuedSongIsReplacedByAFitBeforeTheBoundary() {
    let tracks = [numb, nightrider, bermuda, weightOff]
    let reducer = RunReducer(tracks: tracks)
    let (state, effects) = reducer.reduce(
        state: walkingRun(tracks: tracks, current: numb),
        event: progress()
    )

    #expect(
        effects == [
            .prepareNextTrack(
                sessionID: sessionID,
                operationID: sessionID,
                selectionID: 77,
                trackID: bermuda.id
            )
        ]
    )
    #expect(state.session?.nextSongOutlook == .betterFitPrepared)
    #expect(state.session?.pendingNextTrackID == bermuda.id)
    #expect(state.session?.incompatibleTrackSeconds == 0)

    // The same judgment a second later issues nothing new: one choice, kept.
    let again = reducer.reduce(state: state, event: progress(elapsed: 172, selectionID: 78))
    #expect(again.1.isEmpty)
    #expect(again.0.session?.pendingNextTrackID == bermuda.id)
}

@Test func whenNothingFitsTheQueueProceedsAndTheStateSaysSo() {
    let tracks = [numb, nightrider, weightOff]
    let reducer = RunReducer(tracks: tracks)
    let (state, effects) = reducer.reduce(
        state: walkingRun(tracks: tracks, current: numb),
        event: progress()
    )

    #expect(effects.isEmpty)
    #expect(state.session?.nextSongOutlook == .nothingFits)
    #expect(state.session?.pendingNextTrackID == nil)
}

@Test func lookAheadWaitsForTheBoundaryWindow() {
    let tracks = [numb, nightrider, bermuda, weightOff]
    let reducer = RunReducer(tracks: tracks)
    let (state, effects) = reducer.reduce(
        state: walkingRun(tracks: tracks, current: numb, elapsedSeconds: 100),
        event: progress(elapsed: 101)
    )

    #expect(effects.isEmpty)
    #expect(state.session?.nextSongOutlook == .notYetKnown)
}

@Test func arrivingOnThePreparedSongKeepsTheQueueAnchorOnTheSongThatWasPlaying() {
    let tracks = [numb, nightrider, bermuda, weightOff]
    let reducer = RunReducer(tracks: tracks)
    var state = reducer.reduce(state: walkingRun(tracks: tracks, current: numb), event: progress()).0
    state =
        reducer.reduce(
            state: state,
            event: .nextTrackPrepared(
                sessionID: sessionID,
                operationID: sessionID,
                selectionID: 77,
                trackID: bermuda.id
            )
        ).0
    #expect(state.session?.preparedNextTrackID == bermuda.id)

    state =
        reducer.reduce(
            state: state,
            event: .playbackTrackChanged(
                sessionID: sessionID,
                operationID: sessionID,
                trackID: bermuda.id,
                trackIndex: 2,
                reason: .naturalBoundary,
                rateRequestID: 90
            )
        ).0

    #expect(state.session?.currentTrackID == bermuda.id)
    #expect(state.session?.trackIndex == 2)
    // The player slotted Bermuda in after Numb, so the queue still continues after Numb.
    #expect(state.session?.queueAnchorIndex == 0)
    #expect(state.session?.preparedNextTrackID == nil)
    #expect(state.session?.pendingNextTrackID == nil)
    #expect(state.session?.nextSongOutlook == .notYetKnown)
}

@Test func anExplicitSkipToAnotherSongDropsThePlanAndMovesTheAnchor() {
    let tracks = [numb, nightrider, bermuda, weightOff]
    let reducer = RunReducer(tracks: tracks)
    var state = reducer.reduce(state: walkingRun(tracks: tracks, current: numb), event: progress()).0
    #expect(state.session?.pendingNextTrackID == bermuda.id)

    let skipped = reducer.reduce(state: state, event: .skipTapped)
    #expect(skipped.1.contains(.skipTrack(sessionID: sessionID)))
    state =
        reducer.reduce(
            state: skipped.0,
            event: .playbackTrackChanged(
                sessionID: sessionID,
                operationID: sessionID,
                trackID: nightrider.id,
                trackIndex: 1,
                reason: .explicitSkip,
                rateRequestID: 91
            )
        ).0

    #expect(state.session?.pendingNextTrackID == nil)
    #expect(state.session?.preparedNextTrackID == nil)
    #expect(state.session?.queueAnchorIndex == 1)
}

@Test func playbackPreparedSetsTheQueueAnchor() {
    let tracks = [numb, nightrider, bermuda, weightOff]
    let reducer = RunReducer(tracks: tracks)
    var state: RunState = .ready
    state = reducer.reduce(state: state, event: .startTapped(sessionID: sessionID)).0
    state = reducer.reduce(state: state, event: .authorizationResolved(sessionID: sessionID, .authorized)).0
    state = reducer.reduce(state: state, event: .playbackPrepared(sessionID: sessionID, trackID: bermuda.id)).0

    #expect(state.session?.trackIndex == 2)
    #expect(state.session?.queueAnchorIndex == 2)
}
