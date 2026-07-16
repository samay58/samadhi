import SamadhiDesign
import SamadhiDomain

enum AppMusicCollection {
    static let simulated = MusicCollection(
        id: MusicCollectionID("simulation"),
        name: "Samadhi demo",
        tracks: TrackMetadata.demoTracks.enumerated().map { index, track in
            MusicTrack(
                id: MusicTrackID("demo-\(index)"),
                title: track.title,
                artist: track.artist,
                durationSeconds: Double(track.durationSeconds),
                tempo: TempoAnalysis(
                    baseBPM: 168,
                    confidence: 1,
                    analyzedDurationSeconds: 30,
                    version: 1
                )
            )
        }
    )

    // This catalog track is a temporary core-loop fixture, not a user-facing default.
    static let appleMusicCoreLoop = MusicCollection(
        id: MusicCollectionID("apple-music-core-loop"),
        name: "Apple Music core loop",
        tracks: [
            MusicTrack(
                id: MusicTrackID("1558215042"),
                title: "Astronaut In the Ocean (Workout Remix 150 BPM)",
                artist: "Power Music Workout",
                durationSeconds: 176,
                tempo: TempoAnalysis(
                    baseBPM: 149.75,
                    confidence: 1,
                    analyzedDurationSeconds: 30,
                    version: 2
                )
            )
        ]
    )

    static let partialImportFixture = MusicCollection(
        id: MusicCollectionID("partial-import"),
        name: "City Pocket",
        tracks: [
            MusicTrack(
                id: MusicTrackID("fixture-ready"),
                title: "Soft Current",
                artist: "North Window",
                durationSeconds: 210,
                sourceFingerprint: "fixture-ready-v1",
                analysisState: .ready(
                    TempoAnalysis(
                        baseBPM: 168,
                        confidence: 0.94,
                        analyzedDurationSeconds: 30,
                        version: 2
                    )
                )
            ),
            MusicTrack(
                id: MusicTrackID("fixture-unreadable"),
                title: "Afterimage",
                artist: "Static Gardens",
                durationSeconds: 190,
                sourceFingerprint: "fixture-unreadable-v1",
                analysisState: .failed(.couldNotReadTempo)
            ),
            MusicTrack(
                id: MusicTrackID("fixture-unavailable"),
                title: "Quiet Arcade",
                artist: "Paper Cinema",
                durationSeconds: 198,
                sourceFingerprint: "fixture-unavailable-v1",
                analysisState: .failed(.unavailable)
            ),
        ]
    )
}
