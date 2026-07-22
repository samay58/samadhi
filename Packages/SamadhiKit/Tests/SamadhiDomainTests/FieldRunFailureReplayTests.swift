import Testing

@testable import SamadhiDomain

@Test func broadManualTurnCannotEndAsAnUnverifiedTarget() {
    let current = fixtureTrack(id: "current", bpm: 170)
    let compatibleTracks = stride(from: 160, through: 120, by: -10).map {
        fixtureTrack(id: "compatible-\($0)", bpm: Double($0))
    }
    let reducer = RunReducer(tracks: [current] + compatibleTracks)
    var state = startRun(reducer: reducer, currentTrack: current)
    var appliedRates = [1.0]
    var requestedBPMs = [168.0]

    state = apply(
        reducer.reduce(
            state: state,
            event: .rhythmControlSetManual(rateRequestID: 10, timeoutID: 11)
        ),
        with: reducer,
        recording: &appliedRates
    )

    for step in 0..<48 {
        state = apply(
            reducer.reduce(
                state: state,
                event: .rhythmControlAdjusted(
                    steps: -1,
                    rateRequestID: 20 + step,
                    timeoutID: 100 + step
                )
            ),
            with: reducer,
            recording: &appliedRates
        )
        if let requested = state.session?.adaptationState.requestedBPM {
            requestedBPMs.append(requested)
        }
    }

    guard let session = state.session,
        let requested = session.adaptationState.requestedBPM
    else {
        Issue.record("Expected an active manual command")
        return
    }

    let requestedSpan = (requestedBPMs.max() ?? 0) - (requestedBPMs.min() ?? 0)
    let appliedSpan = (appliedRates.max() ?? 1) - (appliedRates.min() ?? 1)
    let currentEffectiveBPM = 170 * session.appliedPlaybackRate
    let hasTrackAction = session.pendingNextTrackID != nil || session.preparedNextTrackID != nil

    #expect(requestedSpan >= 40)
    #expect(
        abs(currentEffectiveBPM - requested) <= 3
            || hasTrackAction
            || appliedSpan >= 0.08,
        "A wide accepted BPM command must move verified playback or start a compatible-track action"
    )
}

private func fixtureTrack(id: String, bpm: Double) -> MusicTrack {
    MusicTrack(
        id: MusicTrackID(id),
        title: id,
        durationSeconds: 180,
        tempo: TempoAnalysis(
            baseBPM: bpm,
            confidence: 1,
            analyzedDurationSeconds: 30,
            version: 2
        )
    )
}

private func startRun(reducer: RunReducer, currentTrack: MusicTrack) -> RunState {
    var state = reducer.reduce(state: .ready, event: .startTapped(sessionID: 1)).0
    state =
        reducer.reduce(
            state: state,
            event: .authorizationResolved(sessionID: 1, .authorized)
        ).0
    return reducer.reduce(
        state: state,
        event: .playbackPrepared(sessionID: 1, trackID: currentTrack.id)
    ).0
}

private func apply(
    _ result: (RunState, [RunEffect]),
    with reducer: RunReducer,
    recording appliedRates: inout [Double]
) -> RunState {
    var state = result.0
    for effect in result.1 {
        guard
            case let .setPlaybackRate(
                sessionID,
                operationID,
                requestID,
                trackID,
                rate
            ) = effect
        else { continue }
        appliedRates.append(rate)
        state =
            reducer.reduce(
                state: state,
                event: .playbackRateApplied(
                    sessionID: sessionID,
                    operationID: operationID,
                    requestID: requestID,
                    trackID: trackID,
                    rate: rate,
                    latencySeconds: 0
                )
            ).0
    }
    return state
}
