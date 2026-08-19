import Testing

@testable import SamadhiDomain

private func song(_ id: String, bpm: Double) -> MusicTrack {
    MusicTrack(
        id: MusicTrackID(id),
        title: id,
        durationSeconds: 200,
        tempo: TempoAnalysis(baseBPM: bpm, confidence: 1, analyzedDurationSeconds: 30, version: 5)
    )
}

// One of five songs reaches 108 steps per minute; one of five reaches 200. Everything else is a
// jogging song that a brisk walk cannot pull down, or a walking song a sprint cannot pull up.
private let joggingSet = [
    song("numb", bpm: 126),
    song("nightrider", bpm: 164),
    song("weight-off", bpm: 160),
    song("open-road", bpm: 168),
    song("last-mile", bpm: 175),
]
private let reachReducer = RunReducer(tracks: joggingSet)
private let reachSessionID = 909

private func settledRun(targetSPM: Double) -> RunState {
    var session = RunSession(id: reachSessionID)
    session.currentTrackID = joggingSet[0].id
    session.cadenceAcquisitionID = 1
    session.autoTargetState = AutoTargetState(
        observedCadenceSPM: targetSPM,
        settledTargetSPM: targetSPM,
        status: .settled
    )
    return .active(
        ActiveRun(
            session: session,
            activity: .playing(rhythm: .locked(spm: Int(targetSPM)), controls: .hidden)
        )
    )
}

private func notices(_ effects: [RunEffect]) -> [CollectionReach] {
    effects.compactMap {
        guard case let .showReachNotice(reach) = $0 else { return nil }
        return reach
    }
}

private func walk(
    _ state: RunState,
    cadence: Double,
    seconds: Int,
    startingRequestID: Int
) -> (RunState, [CollectionReach]) {
    var state = state
    var noticed: [CollectionReach] = []
    for second in 0..<seconds {
        let (next, effects) = reachReducer.reduce(
            state: state,
            event: .cadenceUpdated(
                sessionID: reachSessionID,
                acquisitionID: 1,
                stepsPerMinute: cadence,
                deltaSeconds: 1,
                rateRequestID: startingRequestID + second
            )
        )
        state = next
        noticed += notices(effects)
    }
    return (state, noticed)
}

@Test func aMostlyFasterCollectionIsNamedOnceAfterTwentyHeldSeconds() {
    let (afterNineteen, early) = walk(settledRun(targetSPM: 108), cadence: 108, seconds: 19, startingRequestID: 10)
    #expect(early.isEmpty)
    #expect(afterNineteen.session?.collectionReach.condition == .mostlyFaster)

    let (afterTwenty, atTwenty) = walk(afterNineteen, cadence: 108, seconds: 1, startingRequestID: 40)
    #expect(atTwenty == [.mostlyFaster])
    #expect(afterTwenty.session?.collectionReach.noticed == [.mostlyFaster])

    let (_, later) = walk(afterTwenty, cadence: 108, seconds: 60, startingRequestID: 50)
    #expect(later.isEmpty)
}

@Test func theOppositeDirectionGetsItsOwnSingleNoticeAndNeitherRepeats() {
    let (walked, first) = walk(settledRun(targetSPM: 108), cadence: 108, seconds: 25, startingRequestID: 10)
    #expect(first == [.mostlyFaster])

    // Sprinting: the settled target climbs to 200, where only one song can follow.
    let (sprinted, second) = walk(walked, cadence: 200, seconds: 60, startingRequestID: 100)
    #expect(second == [.mostlySlower])
    #expect(sprinted.session?.collectionReach.noticed == [.mostlyFaster, .mostlySlower])

    let (_, third) = walk(sprinted, cadence: 108, seconds: 60, startingRequestID: 200)
    #expect(third.isEmpty)
}

@Test func aReachableCollectionNeverSpeaks() {
    let reducer = RunReducer(tracks: [song("a", bpm: 126), song("b", bpm: 120), song("c", bpm: 130)])
    var state = settledRun(targetSPM: 108)
    var noticed: [CollectionReach] = []
    for second in 0..<40 {
        let (next, effects) = reducer.reduce(
            state: state,
            event: .cadenceUpdated(
                sessionID: reachSessionID,
                acquisitionID: 1,
                stepsPerMinute: 108,
                deltaSeconds: 1,
                rateRequestID: 10 + second
            )
        )
        state = next
        noticed += notices(effects)
    }
    #expect(noticed.isEmpty)
    #expect(state.session?.collectionReach.condition == nil)
}

@Test func manualTakeoverPausesTheCount() {
    let (walked, _) = walk(settledRun(targetSPM: 108), cadence: 108, seconds: 10, startingRequestID: 10)
    let manual = reachReducer.reduce(
        state: walked,
        event: .rhythmControlSetManual(rateRequestID: 300, timeoutID: 301)
    ).0
    let (stillManual, noticed) = walk(manual, cadence: 108, seconds: 30, startingRequestID: 310)
    #expect(noticed.isEmpty)
    #expect(stillManual.session?.collectionReach.heldSeconds == 0)
}

@Test func reachDirectionFollowsTheUnreachableMajority() {
    #expect(reachReducer.collectionReach(at: 108) == .mostlyFaster)
    #expect(reachReducer.collectionReach(at: 200) == .mostlySlower)
    #expect(reachReducer.collectionReach(at: 165) == nil)
}
