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

struct MusicImportTimingSnapshot: Codable, Equatable, Sendable {
    struct TrackTiming: Codable, Equatable, Sendable {
        let index: Int
        let catalogSeconds: Double
        let downloadSeconds: Double
        let analysisSeconds: Double
        let totalSeconds: Double
        let outcome: String
    }

    let schemaVersion: Int
    let capturedAt: Date
    let concurrencyLimit: Int
    let totalWallSeconds: Double
    let tracks: [TrackTiming]
}

actor MusicImportDiagnosticsStore {
    private let directoryURL: URL
    private let fileURL: URL

    init(directoryURL: URL? = nil) {
        let directory =
            directoryURL
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appending(path: "Samadhi", directoryHint: .isDirectory)
            ?? FileManager.default.temporaryDirectory.appending(
                path: "Samadhi",
                directoryHint: .isDirectory
            )
        self.directoryURL = directory
        fileURL = directory.appending(path: "latest-import-diagnostics.json")
    }

    func save(_ snapshot: MusicImportTimingSnapshot) throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(snapshot).write(to: fileURL, options: .atomic)
    }
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
    private let diagnosticsStore: MusicImportDiagnosticsStore
    private let catalogResolver = AppleMusicCatalogResolver()
    private var playlistsByID: [String: Playlist] = [:]

    init(
        store: MusicCollectionStore,
        analyzer: any TempoAnalyzing = LocalTempoAnalyzer(),
        diagnosticsStore: MusicImportDiagnosticsStore = MusicImportDiagnosticsStore()
    ) {
        self.store = store
        self.analyzer = analyzer
        self.diagnosticsStore = diagnosticsStore
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
        if playlistsByID[id] == nil {
            _ = try await loadPlaylists()
        }
        guard let playlist = playlistsByID[id] else {
            throw AppleMusicImportError.playlistUnavailable
        }
        let hydrated = try await playlist.with(.tracks)
        let sourceTracks = Array(hydrated.tracks ?? [])
        guard !sourceTracks.isEmpty else {
            throw AppleMusicImportError.emptyPlaylist
        }

        let startedAt = ProcessInfo.processInfo.systemUptime
        var importedTracks = sourceTracks.map(pendingTrack)
        var timings: [MusicImportTimingSnapshot.TrackTiming] = []
        var completedCount = 0
        progress(
            MusicImportProgress(
                completedCount: 0,
                totalCount: sourceTracks.count,
                tracks: importedTracks
            )
        )

        let concurrencyLimit = 3
        for batch in musicImportBatches(count: sourceTracks.count, width: concurrencyLimit) {
            try Task.checkCancellation()
            async let first = importTrackIfPresent(sourceTracks, index: batch[safe: 0])
            async let second = importTrackIfPresent(sourceTracks, index: batch[safe: 1])
            async let third = importTrackIfPresent(sourceTracks, index: batch[safe: 2])

            let batchResults = try await [first, second, third].compactMap { $0 }
            for result in batchResults {
                try Task.checkCancellation()
                importedTracks[result.index] = result.track
                timings.append(result.timing)
                completedCount += 1
                progress(
                    MusicImportProgress(
                        completedCount: completedCount,
                        totalCount: sourceTracks.count,
                        tracks: importedTracks
                    )
                )
            }
        }

        #if DEBUG
            try? await diagnosticsStore.save(
                MusicImportTimingSnapshot(
                    schemaVersion: 1,
                    capturedAt: Date(),
                    concurrencyLimit: concurrencyLimit,
                    totalWallSeconds: max(ProcessInfo.processInfo.systemUptime - startedAt, 0),
                    tracks: timings.sorted { $0.index < $1.index }
                )
            )
        #endif

        return MusicCollection(
            id: MusicCollectionID(hydrated.id.rawValue),
            name: hydrated.name,
            tracks: importedTracks
        )
    }

    private struct ImportedTrackResult: Sendable {
        let index: Int
        let track: MusicTrack
        let timing: MusicImportTimingSnapshot.TrackTiming
    }

    private func importTrackIfPresent(
        _ tracks: [Track],
        index: Int?
    ) async throws -> ImportedTrackResult? {
        guard let index, tracks.indices.contains(index) else { return nil }
        return try await importTrack(tracks[index], index: index)
    }

    private func importTrack(_ track: Track, index: Int) async throws -> ImportedTrackResult {
        let totalStartedAt = ProcessInfo.processInfo.systemUptime
        let fingerprint = sourceFingerprint(for: track)
        let catalogStartedAt = ProcessInfo.processInfo.systemUptime
        let resolvedSong: Song?
        do {
            resolvedSong = try await catalogResolver.resolve(track)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return result(
                index: index,
                source: track,
                fingerprint: fingerprint,
                failure: .temporaryCatalogFailure,
                catalogSeconds: elapsed(since: catalogStartedAt),
                startedAt: totalStartedAt
            )
        }
        guard let song = resolvedSong else {
            return result(
                index: index,
                source: track,
                fingerprint: fingerprint,
                failure: .catalogMatchUnavailable,
                catalogSeconds: elapsed(since: catalogStartedAt),
                startedAt: totalStartedAt
            )
        }
        let catalogSeconds = elapsed(since: catalogStartedAt)

        let trackID = MusicTrackID(song.id.rawValue)
        let key = TempoAnalysisCacheKey(
            trackID: trackID,
            sourceFingerprint: fingerprint,
            analyzerVersion: LocalTempoAnalyzer.analysisVersion
        )
        if let cached = try await store.cachedAnalysis(for: key) {
            return result(
                index: index,
                track: MusicTrack(
                    id: trackID,
                    title: track.title,
                    artist: track.artistName,
                    durationSeconds: song.duration ?? track.duration ?? 0,
                    sourceFingerprint: fingerprint,
                    analysisState: cached.isAdaptiveReady
                        ? .ready(cached)
                        : .failed(.rhythmUnclear)
                ),
                catalogSeconds: catalogSeconds,
                startedAt: totalStartedAt,
                outcome: cached.isAdaptiveReady ? "ready_cached" : "rhythm_unclear_cached"
            )
        }

        guard let remoteURL = song.previewAssets?.compactMap({ $0.url ?? $0.hlsURL }).first else {
            return result(
                index: index,
                source: track,
                id: trackID,
                duration: song.duration ?? track.duration ?? 0,
                fingerprint: fingerprint,
                failure: .previewUnavailable,
                catalogSeconds: catalogSeconds,
                startedAt: totalStartedAt
            )
        }

        let downloadStartedAt = ProcessInfo.processInfo.systemUptime
        let localURL: URL
        do {
            localURL = try await downloadPreview(remoteURL)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return result(
                index: index,
                source: track,
                id: trackID,
                duration: song.duration ?? track.duration ?? 0,
                fingerprint: fingerprint,
                failure: .temporaryDownloadFailure,
                catalogSeconds: catalogSeconds,
                downloadSeconds: elapsed(since: downloadStartedAt),
                startedAt: totalStartedAt
            )
        }
        let downloadSeconds = elapsed(since: downloadStartedAt)
        defer { try? FileManager.default.removeItem(at: localURL) }

        let analysisStartedAt = ProcessInfo.processInfo.systemUptime
        let analysis: TempoAnalysis?
        do {
            analysis = try await analyzer.analyze(fileURL: localURL)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return result(
                index: index,
                source: track,
                id: trackID,
                duration: song.duration ?? track.duration ?? 0,
                fingerprint: fingerprint,
                failure: .decodeFailure,
                catalogSeconds: catalogSeconds,
                downloadSeconds: downloadSeconds,
                analysisSeconds: elapsed(since: analysisStartedAt),
                startedAt: totalStartedAt
            )
        }
        let analysisSeconds = elapsed(since: analysisStartedAt)
        guard let analysis, analysis.isAdaptiveReady else {
            return result(
                index: index,
                source: track,
                id: trackID,
                duration: song.duration ?? track.duration ?? 0,
                fingerprint: fingerprint,
                failure: .rhythmUnclear,
                catalogSeconds: catalogSeconds,
                downloadSeconds: downloadSeconds,
                analysisSeconds: analysisSeconds,
                startedAt: totalStartedAt
            )
        }
        try? await store.cache(analysis, for: key)
        return result(
            index: index,
            track: MusicTrack(
                id: trackID,
                title: track.title,
                artist: track.artistName,
                durationSeconds: song.duration ?? track.duration ?? 0,
                sourceFingerprint: fingerprint,
                analysisState: .ready(analysis)
            ),
            catalogSeconds: catalogSeconds,
            downloadSeconds: downloadSeconds,
            analysisSeconds: analysisSeconds,
            startedAt: totalStartedAt,
            outcome: "ready"
        )
    }

    private func pendingTrack(_ track: Track) -> MusicTrack {
        MusicTrack(
            id: MusicTrackID(track.id.rawValue),
            title: track.title,
            artist: track.artistName,
            durationSeconds: track.duration ?? 0,
            sourceFingerprint: sourceFingerprint(for: track),
            analysisState: .pending
        )
    }

    private func result(
        index: Int,
        source: Track,
        id: MusicTrackID? = nil,
        duration: Double? = nil,
        fingerprint: String,
        failure: TrackAnalysisFailure,
        catalogSeconds: Double,
        downloadSeconds: Double = 0,
        analysisSeconds: Double = 0,
        startedAt: TimeInterval
    ) -> ImportedTrackResult {
        result(
            index: index,
            track: MusicTrack(
                id: id ?? MusicTrackID(source.id.rawValue),
                title: source.title,
                artist: source.artistName,
                durationSeconds: duration ?? source.duration ?? 0,
                sourceFingerprint: fingerprint,
                analysisState: .failed(failure)
            ),
            catalogSeconds: catalogSeconds,
            downloadSeconds: downloadSeconds,
            analysisSeconds: analysisSeconds,
            startedAt: startedAt,
            outcome: failure.rawValue
        )
    }

    private func result(
        index: Int,
        track: MusicTrack,
        catalogSeconds: Double,
        downloadSeconds: Double = 0,
        analysisSeconds: Double = 0,
        startedAt: TimeInterval,
        outcome: String
    ) -> ImportedTrackResult {
        ImportedTrackResult(
            index: index,
            track: track,
            timing: MusicImportTimingSnapshot.TrackTiming(
                index: index,
                catalogSeconds: catalogSeconds,
                downloadSeconds: downloadSeconds,
                analysisSeconds: analysisSeconds,
                totalSeconds: elapsed(since: startedAt),
                outcome: outcome
            )
        )
    }

    private func elapsed(since start: TimeInterval) -> Double {
        max(ProcessInfo.processInfo.systemUptime - start, 0)
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

func musicImportBatches(count: Int, width: Int) -> [[Int]] {
    guard count > 0, width > 0 else { return [] }
    return stride(from: 0, to: count, by: width).map { start in
        Array(start..<min(start + width, count))
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
