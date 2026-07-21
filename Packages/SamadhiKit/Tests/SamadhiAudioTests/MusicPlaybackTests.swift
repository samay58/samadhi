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
        1.06,
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
                rate: 1.06
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
    #expect(await events.next() == .trackChanged(operationID: 50, trackID: first.id))
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
    #expect(await events.next() == .trackChanged(operationID: 60, trackID: third.id))
}
