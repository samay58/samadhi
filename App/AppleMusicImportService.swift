import Foundation
@preconcurrency import MusicKit
import SamadhiAudio
import SamadhiDomain

struct LibraryPlaylistChoice: Identifiable, Sendable, Equatable {
    let id: String
    let name: String
}

struct MusicImportProgress: Sendable, Equatable {
    let completedCount: Int
    let totalCount: Int
    let tracks: [MusicTrack]
}

@MainActor
protocol MusicLibraryImporting: AnyObject {
    func loadPlaylists() async throws -> [LibraryPlaylistChoice]
    func importPlaylist(
        id: String,
        progress: @escaping @MainActor (MusicImportProgress) -> Void
    ) async throws -> MusicCollection
}

@MainActor
final class AppleMusicImportService: MusicLibraryImporting {
    private let store: MusicCollectionStore
    private let analyzer: any TempoAnalyzing
    private let catalogResolver = AppleMusicCatalogResolver()
    private var playlistsByID: [String: Playlist] = [:]

    init(
        store: MusicCollectionStore,
        analyzer: any TempoAnalyzing = LocalTempoAnalyzer()
    ) {
        self.store = store
        self.analyzer = analyzer
    }

    func loadPlaylists() async throws -> [LibraryPlaylistChoice] {
        let status = await MusicAuthorization.request()
        guard status == .authorized else {
            throw AppleMusicImportError.authorizationDenied
        }

        var request = MusicLibraryRequest<Playlist>()
        request.limit = 100
        let response = try await request.response()
        let playlists = Array(response.items)
        playlistsByID = Dictionary(
            uniqueKeysWithValues: playlists.map { ($0.id.rawValue, $0) }
        )
        return playlists.map {
            LibraryPlaylistChoice(id: $0.id.rawValue, name: $0.name)
        }
    }

    func importPlaylist(
        id: String,
        progress: @escaping @MainActor (MusicImportProgress) -> Void
    ) async throws -> MusicCollection {
        guard let playlist = playlistsByID[id] else {
            throw AppleMusicImportError.playlistUnavailable
        }
        let hydrated = try await playlist.with(.tracks)
        let sourceTracks = Array(hydrated.tracks ?? [])
        guard !sourceTracks.isEmpty else {
            throw AppleMusicImportError.emptyPlaylist
        }

        var importedTracks: [MusicTrack] = []
        importedTracks.reserveCapacity(sourceTracks.count)
        progress(
            MusicImportProgress(
                completedCount: 0,
                totalCount: sourceTracks.count,
                tracks: []
            )
        )

        for sourceTrack in sourceTracks {
            try Task.checkCancellation()
            let imported = try await importTrack(sourceTrack)
            importedTracks.append(imported)
            progress(
                MusicImportProgress(
                    completedCount: importedTracks.count,
                    totalCount: sourceTracks.count,
                    tracks: importedTracks
                )
            )
        }

        return MusicCollection(
            id: MusicCollectionID(hydrated.id.rawValue),
            name: hydrated.name,
            tracks: importedTracks
        )
    }

    private func importTrack(_ track: Track) async throws -> MusicTrack {
        let fingerprint = sourceFingerprint(for: track)
        guard let song = try await catalogResolver.resolve(track) else {
            return MusicTrack(
                id: MusicTrackID(track.id.rawValue),
                title: track.title,
                artist: track.artistName,
                durationSeconds: track.duration ?? 0,
                sourceFingerprint: fingerprint,
                analysisState: .failed(.unavailable)
            )
        }

        let trackID = MusicTrackID(song.id.rawValue)
        let key = TempoAnalysisCacheKey(
            trackID: trackID,
            sourceFingerprint: fingerprint,
            analyzerVersion: LocalTempoAnalyzer.analysisVersion
        )
        if let cached = try await store.cachedAnalysis(for: key) {
            return MusicTrack(
                id: trackID,
                title: track.title,
                artist: track.artistName,
                durationSeconds: song.duration ?? track.duration ?? 0,
                sourceFingerprint: fingerprint,
                analysisState: cached.isAdaptiveReady
                    ? .ready(cached)
                    : .failed(.couldNotReadTempo)
            )
        }

        guard let remoteURL = song.previewAssets?.compactMap({ $0.url ?? $0.hlsURL }).first else {
            return MusicTrack(
                id: trackID,
                title: track.title,
                artist: track.artistName,
                durationSeconds: song.duration ?? track.duration ?? 0,
                sourceFingerprint: fingerprint,
                analysisState: .failed(.unavailable)
            )
        }

        do {
            let localURL = try await downloadPreview(remoteURL)
            defer { try? FileManager.default.removeItem(at: localURL) }
            guard let analysis = try await analyzer.analyze(fileURL: localURL),
                analysis.isAdaptiveReady
            else {
                return MusicTrack(
                    id: trackID,
                    title: track.title,
                    artist: track.artistName,
                    durationSeconds: song.duration ?? track.duration ?? 0,
                    sourceFingerprint: fingerprint,
                    analysisState: .failed(.couldNotReadTempo)
                )
            }
            try await store.cache(analysis, for: key)
            return MusicTrack(
                id: trackID,
                title: track.title,
                artist: track.artistName,
                durationSeconds: song.duration ?? track.duration ?? 0,
                sourceFingerprint: fingerprint,
                analysisState: .ready(analysis)
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return MusicTrack(
                id: trackID,
                title: track.title,
                artist: track.artistName,
                durationSeconds: song.duration ?? track.duration ?? 0,
                sourceFingerprint: fingerprint,
                analysisState: .failed(.couldNotReadTempo)
            )
        }
    }

    private func downloadPreview(_ remoteURL: URL) async throws -> URL {
        let (downloadedURL, response) = try await URLSession.shared.download(from: remoteURL)
        if let response = response as? HTTPURLResponse,
            !(200...299).contains(response.statusCode)
        {
            throw URLError(.badServerResponse)
        }

        let fileExtension = remoteURL.pathExtension.isEmpty ? "m4a" : remoteURL.pathExtension
        let localURL = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
            .appendingPathExtension(fileExtension)
        try FileManager.default.moveItem(at: downloadedURL, to: localURL)
        return localURL
    }

    private func sourceFingerprint(for track: Track) -> String {
        [
            track.title,
            track.artistName,
            track.albumTitle ?? "",
            String(format: "%.3f", track.duration ?? 0),
        ]
        .map(normalized)
        .joined(separator: "|")
    }

    private func normalized(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}

enum AppleMusicImportError: Error, Sendable, Equatable {
    case authorizationDenied
    case playlistUnavailable
    case emptyPlaylist
}
