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

    static let simulatorDemo = MusicCollection(
        id: MusicCollectionID("simulator-demo"),
        name: "Samadhi demo",
        tracks: zip(TrackMetadata.demoTracks, [156.0, 168.0, 180.0]).map { track, bpm in
            demoTrack(
                id: "demo-\(track.title.lowercased().replacingOccurrences(of: " ", with: "-"))",
                title: track.title,
                artist: track.artist,
                bpm: bpm
            )
        }
    )

    static let simulatorCruise = MusicCollection(
        id: MusicCollectionID("simulator-cruise"),
        name: "Soft Miles",
        tracks: [
            demoTrack(id: "cruise-148", title: "Open Shade", artist: "Field Note", bpm: 148),
            demoTrack(id: "cruise-160", title: "Long Light", artist: "Low Season", bpm: 160),
            demoTrack(id: "cruise-172", title: "Warm Signal", artist: "Paper Coast", bpm: 172),
            demoTrack(id: "cruise-184", title: "Second Wind", artist: "North Window", bpm: 184),
        ]
    )

    static let simulatorLongName = MusicCollection(
        id: MusicCollectionID("simulator-long-name"),
        name: "Saturday Miles Through the Hills After the Rain",
        tracks: [
            demoTrack(id: "long-name-158", title: "Quiet Ascent", artist: "Field Note", bpm: 158),
            demoTrack(id: "long-name-172", title: "Rain Line", artist: "North Window", bpm: 172),
        ]
    )

    static let simulatorCollections = [simulatorDemo, simulatorCruise]

    static let simulatorExpandedCollections = (1...40).map { index in
        MusicCollection(
            id: MusicCollectionID("simulator-library-\(index)"),
            name: index == 40 ? "Long Run 40" : "Playlist \(index)",
            tracks: [
                demoTrack(
                    id: "simulator-library-\(index)-track",
                    title: "Open Road \(index)",
                    artist: "Samadhi fixture",
                    bpm: Double(148 + index % 36)
                )
            ]
        )
    }

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
                    version: 4
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
                        version: 4
                    )
                )
            ),
            MusicTrack(
                id: MusicTrackID("fixture-unreadable"),
                title: "Afterimage",
                artist: "Static Gardens",
                durationSeconds: 190,
                sourceFingerprint: "fixture-unreadable-v1",
                analysisState: .failed(.rhythmUnclear)
            ),
            MusicTrack(
                id: MusicTrackID("fixture-unavailable"),
                title: "Quiet Arcade",
                artist: "Paper Cinema",
                durationSeconds: 198,
                sourceFingerprint: "fixture-unavailable-v1",
                analysisState: .failed(.previewUnavailable)
            ),
            MusicTrack(
                id: MusicTrackID("fixture-unmatched"),
                title: "Distant Signal",
                artist: "Night Geometry",
                durationSeconds: 201,
                sourceFingerprint: "fixture-unmatched-v1",
                analysisState: .failed(.catalogMatchUnavailable)
            ),
            MusicTrack(
                id: MusicTrackID("fixture-network"),
                title: "Warm Static",
                artist: "Field Note",
                durationSeconds: 184,
                sourceFingerprint: "fixture-network-v1",
                analysisState: .failed(.temporaryDownloadFailure)
            ),
            MusicTrack(
                id: MusicTrackID("fixture-decode"),
                title: "Side Street",
                artist: "Paper Coast",
                durationSeconds: 219,
                sourceFingerprint: "fixture-decode-v1",
                analysisState: .failed(.decodeFailure)
            ),
        ]
    )

    private static func demoTrack(
        id: String,
        title: String,
        artist: String,
        bpm: Double
    ) -> MusicTrack {
        MusicTrack(
            id: MusicTrackID(id),
            title: title,
            artist: artist,
            durationSeconds: 210,
            sourceFingerprint: "simulator-\(id)",
            analysisState: .ready(
                TempoAnalysis(
                    baseBPM: bpm,
                    confidence: 1,
                    analyzedDurationSeconds: 30,
                    version: 2
                )
            )
        )
    }
}

@MainActor
final class SimulatorMusicImportService: MusicLibraryImporting {
    private let collections: [MusicCollection]
    private let trackDelay: Duration

    init(
        fixture: MusicSelectionFixture = .standard,
        reviewMode: Bool = false
    ) {
        trackDelay = reviewMode ? .milliseconds(650) : .milliseconds(120)
        switch fixture {
        case .emptyLibrary:
            collections = []
        case .largeLibrary:
            collections = AppMusicCollection.simulatorExpandedCollections
        case .longPlaylistName:
            collections = [AppMusicCollection.simulatorLongName]
        case .standard, .none, .loading, .loadingSelected, .analyzing, .partial,
            .authorizationFailure, .importFailure, .twoPlaylistLibrary:
            collections = AppMusicCollection.simulatorCollections
        }
    }

    func loadPlaylists() async throws -> [LibraryPlaylistChoice] {
        collections.map {
            LibraryPlaylistChoice(id: $0.id.rawValue, name: $0.name)
        }
    }

    func importPlaylist(
        id: String,
        progress: @escaping @MainActor (MusicImportProgress) -> Void
    ) async throws -> MusicCollection {
        guard
            let collection = collections.first(where: {
                $0.id.rawValue == id
            })
        else {
            throw AppleMusicImportError.playlistUnavailable
        }

        var imported: [MusicTrack] = []
        progress(MusicImportProgress(completedCount: 0, totalCount: collection.tracks.count, tracks: []))
        for track in collection.tracks {
            try await Task.sleep(for: trackDelay)
            imported.append(track)
            progress(
                MusicImportProgress(
                    completedCount: imported.count,
                    totalCount: collection.tracks.count,
                    tracks: imported
                )
            )
        }
        return collection
    }
}
