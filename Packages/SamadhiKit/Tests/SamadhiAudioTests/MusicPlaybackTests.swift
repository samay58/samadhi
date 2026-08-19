import SamadhiDomain
import Testing

@testable import SamadhiAudio

@Test @MainActor func simulatedPlayerReportsIdentifiedLifecycleEvents() async throws {
    let player = SimulatedMusicPlayer()
    let collection = MusicCollection(
        id: MusicCollectionID("fixture"),
        name: "Known tempo",
        tracks: [
            MusicTrack(
                id: MusicTrackID("track-1"),
                title: "168 BPM",
                durationSeconds: 60,
                tempo: TempoAnalysis(
                    baseBPM: 168,
                    confidence: 1,
                    analyzedDurationSeconds: 30,
                    version: 1
                )
            )
        ]
    )
    var events = player.events().makeAsyncIterator()

    try await player.prepare(
        collection,
        startingAt: collection.tracks[0].id,
        operationID: 41
    )
    try await player.play(operationID: 41)
    player.setPlaybackRate(
        1.10,
        operationID: 41,
        requestID: 42,
        trackID: MusicTrackID("track-1")
    )
    player.pause(operationID: 41)
    player.stop(operationID: 41)

    #expect(await events.next() == .prepared(operationID: 41, trackID: MusicTrackID("track-1")))
    #expect(await events.next() == .stateChanged(operationID: 41, state: .playing))
    #expect(
        await events.next()
            == .rateChanged(
                operationID: 41,
                requestID: 42,
                trackID: MusicTrackID("track-1"),
                rate: 1.10,
                latencySeconds: 0
            ))
    #expect(await events.next() == .stateChanged(operationID: 41, state: .paused))
    #expect(await events.next() == .stateChanged(operationID: 41, state: .stopped))
}

@Test @MainActor func simulatedPlayerStartsAndAdvancesUsingPreparedTrackIdentity() async throws {
    let player = SimulatedMusicPlayer()
    let first = MusicTrack(id: MusicTrackID("first"), title: "First", durationSeconds: 60)
    let second = MusicTrack(id: MusicTrackID("second"), title: "Second", durationSeconds: 60)
    let third = MusicTrack(id: MusicTrackID("third"), title: "Third", durationSeconds: 60)
    let collection = MusicCollection(
        id: MusicCollectionID("fixture"),
        name: "Order",
        tracks: [first, second, third]
    )
    var events = player.events().makeAsyncIterator()

    try await player.prepare(collection, startingAt: second.id, operationID: 50)
    try await player.prepareNext(trackID: first.id, operationID: 50, selectionID: 51)
    try await player.skipToNext(operationID: 50)

    #expect(await events.next() == .prepared(operationID: 50, trackID: second.id))
    #expect(
        await events.next()
            == .trackChanged(
                operationID: 50,
                trackID: first.id,
                reason: .explicitSkip
            )
    )
}

@Test @MainActor func newerSelectionInvalidationRejectsLatePreparation() async throws {
    let player = SimulatedMusicPlayer()
    let first = MusicTrack(id: MusicTrackID("first"), title: "First", durationSeconds: 60)
    let second = MusicTrack(id: MusicTrackID("second"), title: "Second", durationSeconds: 60)
    let third = MusicTrack(id: MusicTrackID("third"), title: "Third", durationSeconds: 60)
    let collection = MusicCollection(
        id: MusicCollectionID("fixture"),
        name: "Order",
        tracks: [first, second, third]
    )
    var events = player.events().makeAsyncIterator()

    try await player.prepare(collection, startingAt: second.id, operationID: 60)
    try await player.prepareNext(trackID: first.id, operationID: 60, selectionID: 61)
    player.clearPreparedNext(operationID: 60, selectionID: 62)
    try await player.prepareNext(trackID: first.id, operationID: 60, selectionID: 61)
    try await player.skipToNext(operationID: 60)

    #expect(await events.next() == .prepared(operationID: 60, trackID: second.id))
    #expect(
        await events.next()
            == .trackChanged(
                operationID: 60,
                trackID: third.id,
                reason: .explicitSkip
            )
    )
}

@MainActor
private func scriptedPlayer() -> (SimulatedMusicPlayer, MusicCollection) {
    let player = SimulatedMusicPlayer()
    let collection = MusicCollection(
        id: MusicCollectionID("scripted"),
        name: "Scripted",
        tracks: [
            MusicTrack(id: MusicTrackID("one"), title: "One", durationSeconds: 60),
            MusicTrack(id: MusicTrackID("two"), title: "Two", durationSeconds: 60),
            MusicTrack(id: MusicTrackID("three"), title: "Three", durationSeconds: 60),
        ]
    )
    return (player, collection)
}

@Test @MainActor func scriptedNaturalBoundaryUsesThePreparedTrackAndItsOwnReason() async throws {
    let (player, collection) = scriptedPlayer()
    var events = player.events().makeAsyncIterator()

    try await player.prepare(collection, startingAt: collection.tracks[0].id, operationID: 70)
    try await player.prepareNext(
        trackID: collection.tracks[2].id,
        operationID: 70,
        selectionID: 71
    )
    player.simulateNaturalBoundary(operationID: 70)

    #expect(await events.next() == .prepared(operationID: 70, trackID: collection.tracks[0].id))
    #expect(
        await events.next()
            == .trackChanged(
                operationID: 70,
                trackID: collection.tracks[2].id,
                reason: .naturalBoundary
            )
    )
}

@Test @MainActor func scriptedExternalBoundaryMovesTheQueueWithoutSamadhisPreparedTrack() async throws {
    let (player, collection) = scriptedPlayer()
    var events = player.events().makeAsyncIterator()

    try await player.prepare(collection, startingAt: collection.tracks[0].id, operationID: 72)
    try await player.prepareNext(
        trackID: collection.tracks[2].id,
        operationID: 72,
        selectionID: 73
    )
    player.simulateExternalBoundary(operationID: 72)

    #expect(await events.next() == .prepared(operationID: 72, trackID: collection.tracks[0].id))
    #expect(
        await events.next()
            == .trackChanged(
                operationID: 72,
                trackID: collection.tracks[1].id,
                reason: .externalUnknown
            )
    )
}

@Test @MainActor func scriptedSameSongCallbackNamesTheCurrentTrack() async throws {
    let (player, collection) = scriptedPlayer()
    var events = player.events().makeAsyncIterator()

    try await player.prepare(collection, startingAt: collection.tracks[1].id, operationID: 74)
    player.simulateSameSongCallback(operationID: 74)

    #expect(await events.next() == .prepared(operationID: 74, trackID: collection.tracks[1].id))
    #expect(
        await events.next()
            == .trackChanged(
                operationID: 74,
                trackID: collection.tracks[1].id,
                reason: .explicitSkip
            )
    )
}

@Test @MainActor func scriptedInterruptionReportsItsBeginningAndItsEnd() async throws {
    let (player, collection) = scriptedPlayer()
    var events = player.events().makeAsyncIterator()

    try await player.prepare(collection, startingAt: collection.tracks[0].id, operationID: 76)
    player.simulateInterruption(operationID: 76)
    player.simulateInterruptionEnded(operationID: 76)

    #expect(await events.next() == .prepared(operationID: 76, trackID: collection.tracks[0].id))
    #expect(await events.next() == .interruptionBegan(operationID: 76))
    #expect(await events.next() == .interruptionEnded(operationID: 76))
}

@Test @MainActor func scriptedEventsFromAnotherOperationAreIgnored() async throws {
    let (player, collection) = scriptedPlayer()
    var events = player.events().makeAsyncIterator()

    try await player.prepare(collection, startingAt: collection.tracks[0].id, operationID: 78)
    player.simulateNaturalBoundary(operationID: 79)
    player.simulateExternalBoundary(operationID: 79)
    player.simulateInterruption(operationID: 79)
    player.simulateSameSongCallback(operationID: 79)
    player.pause(operationID: 78)

    #expect(await events.next() == .prepared(operationID: 78, trackID: collection.tracks[0].id))
    #expect(await events.next() == .stateChanged(operationID: 78, state: .paused))
}
