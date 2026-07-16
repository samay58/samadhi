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

    try await player.prepare(collection, operationID: 41)
    try await player.play(operationID: 41)
    player.setPlaybackRate(1.06, operationID: 41)
    player.pause(operationID: 41)

    #expect(await events.next() == .prepared(operationID: 41, trackID: MusicTrackID("track-1")))
    #expect(await events.next() == .stateChanged(operationID: 41, state: .playing))
    #expect(await events.next() == .rateChanged(operationID: 41, rate: 1.06))
    #expect(await events.next() == .stateChanged(operationID: 41, state: .paused))
}
