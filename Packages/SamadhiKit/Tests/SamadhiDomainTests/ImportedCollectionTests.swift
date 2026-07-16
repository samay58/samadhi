import Testing

@testable import SamadhiDomain

@Test func importedCollectionPreservesOrderAndCountsOnlyReadyTracks() {
    let ready = TempoAnalysis(
        baseBPM: 168,
        confidence: 0.9,
        analyzedDurationSeconds: 30,
        version: 2
    )
    let collection = MusicCollection(
        id: MusicCollectionID("playlist"),
        name: "City Pocket",
        tracks: [
            MusicTrack(
                id: MusicTrackID("101"),
                title: "First",
                durationSeconds: 180,
                sourceFingerprint: "first-v1",
                analysisState: .ready(ready)
            ),
            MusicTrack(
                id: MusicTrackID("102"),
                title: "Second",
                durationSeconds: 190,
                sourceFingerprint: "second-v1",
                analysisState: .failed(.couldNotReadTempo)
            ),
            MusicTrack(
                id: MusicTrackID("103"),
                title: "Third",
                durationSeconds: 200,
                sourceFingerprint: "third-v1",
                analysisState: .pending
            ),
            MusicTrack(
                id: MusicTrackID("104"),
                title: "Low confidence",
                durationSeconds: 210,
                sourceFingerprint: "fourth-v1",
                analysisState: .ready(
                    TempoAnalysis(
                        baseBPM: 168,
                        confidence: 0.6,
                        analyzedDurationSeconds: 30,
                        version: 2
                    )
                )
            ),
        ]
    )

    #expect(collection.tracks.map(\.id.rawValue) == ["101", "102", "103", "104"])
    #expect(collection.readyTrackCount == 1)
    #expect(collection.tracks[1].tempo == nil)
    #expect(collection.tracks[1].analysisState == .failed(.couldNotReadTempo))
    #expect(collection.adaptiveReadyCollection.tracks.map(\.id.rawValue) == ["101"])
}

@Test func cacheKeyChangesWithSourceOrAnalyzerVersion() {
    let original = TempoAnalysisCacheKey(
        trackID: MusicTrackID("101"),
        sourceFingerprint: "source-a",
        analyzerVersion: 2
    )

    #expect(
        original
            != TempoAnalysisCacheKey(
                trackID: MusicTrackID("101"),
                sourceFingerprint: "source-b",
                analyzerVersion: 2
            )
    )
    #expect(
        original
            != TempoAnalysisCacheKey(
                trackID: MusicTrackID("101"),
                sourceFingerprint: "source-a",
                analyzerVersion: 3
            )
    )
}

@Test func runCannotStartWithoutAnAdaptiveReadyTrack() {
    let track = MusicTrack(
        id: MusicTrackID("101"),
        title: "Unreadable",
        durationSeconds: 180,
        sourceFingerprint: "unreadable-v1",
        analysisState: .failed(.couldNotReadTempo)
    )
    let reducer = RunReducer(tracks: [track])

    let (state, effects) = reducer.reduce(state: .ready, event: .startTapped(sessionID: 1))

    #expect(state == .ready)
    #expect(effects.isEmpty)
}

@Test func runCanStartWhenAReadyTrackExists() {
    let track = MusicTrack(
        id: MusicTrackID("101"),
        title: "Ready",
        durationSeconds: 180,
        sourceFingerprint: "ready-v1",
        analysisState: .ready(
            TempoAnalysis(
                baseBPM: 168,
                confidence: 0.9,
                analyzedDurationSeconds: 30,
                version: 2
            )
        )
    )
    let reducer = RunReducer(tracks: [track])

    let (state, effects) = reducer.reduce(state: .ready, event: .startTapped(sessionID: 1))

    guard case .preparing = state else {
        Issue.record("Expected a ready collection to begin preparation")
        return
    }
    #expect(effects == [.emitHaptic(.start), .requestMotionAuthorization(sessionID: 1)])
}
