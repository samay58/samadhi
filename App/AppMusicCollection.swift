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
                id: MusicTrackID("1434921088"),
                title: "Can't Stop the Feeling! (Workout Remix 140 BPM)",
                artist: "Power Music Workout",
                durationSeconds: 281.143,
                tempo: TempoAnalysis(
                    baseBPM: 139.5,
                    confidence: 1,
                    analyzedDurationSeconds: 30,
                    version: 2
                )
            )
        ]
    )
}
