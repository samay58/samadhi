import Foundation
import SamadhiDomain
import Testing

@testable import Samadhi

@Test @MainActor func presentationStartsReadyWithDemoMusic() {
    let model = RunPresentationModel()
    #expect(model.viewState.phase == .ready)
    #expect(model.viewState.track.title == "Dawn on Valencia")
}

@Test @MainActor func startActionMovesPresentationIntoPreparation() {
    let model = RunPresentationModel()
    model.send(.start)
    #expect(model.viewState.phase == .preparing)
}

@Test func collectionStoreRoundTripsSelectionAndCache() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }

    let store = MusicCollectionStore(directoryURL: directory)
    let analysis = TempoAnalysis(
        baseBPM: 168,
        confidence: 0.91,
        analyzedDurationSeconds: 30,
        version: 2
    )
    let track = MusicTrack(
        id: MusicTrackID("101"),
        title: "First",
        durationSeconds: 180,
        sourceFingerprint: "first-v1",
        analysisState: .ready(analysis)
    )
    let collection = MusicCollection(
        id: MusicCollectionID("playlist"),
        name: "City Pocket",
        tracks: [track]
    )
    let key = TempoAnalysisCacheKey(
        trackID: track.id,
        sourceFingerprint: track.sourceFingerprint,
        analyzerVersion: analysis.version
    )

    try await store.replaceSelection(collection)
    try await store.cache(analysis, for: key)

    let restored = MusicCollectionStore(directoryURL: directory)
    #expect(try await restored.selectedCollection() == collection)
    #expect(try await restored.cachedAnalysis(for: key) == analysis)
}

@Test func collectionStoreFailsClosedForCorruptData() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try Data("not-json".utf8).write(
        to: directory.appending(path: "selected-music.json"),
        options: .atomic
    )

    let store = MusicCollectionStore(directoryURL: directory)
    #expect(try await store.selectedCollection() == nil)
    #expect(try await store.cachedAnalysisCount() == 0)
}

@Test @MainActor func musicSelectionRestoresPersistedCollection() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = MusicCollectionStore(directoryURL: directory)
    let collection = importedCollection(id: "saved", name: "Saved", readyCount: 2)
    try await store.replaceSelection(collection)
    let model = MusicSelectionModel(
        store: store,
        importer: FixtureMusicImporter(collections: [:]),
        configuration: .productionFixture
    )

    await model.restore()

    #expect(model.selectedCollection == collection)
    guard case let .ready(presentation) = model.presentation else {
        Issue.record("Expected restored music to be ready")
        return
    }
    #expect(presentation.readyTrackCount == 2)
}

@Test @MainActor func lowConfidenceAnalysisIsNotPresentedAsReady() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = MusicCollectionStore(directoryURL: directory)
    let collection = MusicCollection(
        id: MusicCollectionID("low-confidence"),
        name: "Low confidence",
        tracks: [
            MusicTrack(
                id: MusicTrackID("low"),
                title: "Uncertain",
                durationSeconds: 180,
                sourceFingerprint: "low-v1",
                analysisState: .ready(
                    TempoAnalysis(
                        baseBPM: 168,
                        confidence: 0.6,
                        analyzedDurationSeconds: 30,
                        version: 2
                    )
                )
            )
        ]
    )
    try await store.replaceSelection(collection)
    let model = MusicSelectionModel(
        store: store,
        importer: FixtureMusicImporter(collections: [:]),
        configuration: .productionFixture
    )

    await model.restore()

    guard case let .ready(presentation) = model.presentation else {
        Issue.record("Expected restored music presentation")
        return
    }
    #expect(presentation.readyTrackCount == 0)
    #expect(presentation.tracks.first?.status == .couldNotReadTempo)
}

@Test @MainActor func replacementCancelsOlderImportAndPersistsNewestCollection() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = MusicCollectionStore(directoryURL: directory)
    let old = importedCollection(id: "old", name: "Old", readyCount: 1)
    let newest = importedCollection(id: "new", name: "New", readyCount: 3)
    let importer = FixtureMusicImporter(
        collections: ["old": old, "new": newest],
        delayedID: "old"
    )
    let model = MusicSelectionModel(
        store: store,
        importer: importer,
        configuration: .productionFixture
    )

    model.selectPlaylist(LibraryPlaylistChoice(id: "old", name: "Old"))
    await Task.yield()
    model.selectPlaylist(LibraryPlaylistChoice(id: "new", name: "New"))
    await waitUntil { model.selectedCollection?.id == newest.id }

    #expect(model.selectedCollection == newest)
    #expect(try await store.selectedCollection() == newest)
}

@MainActor
private final class FixtureMusicImporter: MusicLibraryImporting {
    let collections: [String: MusicCollection]
    let delayedID: String?

    init(collections: [String: MusicCollection], delayedID: String? = nil) {
        self.collections = collections
        self.delayedID = delayedID
    }

    func loadPlaylists() async throws -> [LibraryPlaylistChoice] {
        collections.map { LibraryPlaylistChoice(id: $0.key, name: $0.value.name) }
    }

    func importPlaylist(
        id: String,
        progress: @escaping @MainActor (MusicImportProgress) -> Void
    ) async throws -> MusicCollection {
        if id == delayedID {
            try await Task.sleep(for: .seconds(1))
        }
        guard let collection = collections[id] else {
            throw AppleMusicImportError.playlistUnavailable
        }
        progress(
            MusicImportProgress(
                completedCount: collection.tracks.count,
                totalCount: collection.tracks.count,
                tracks: collection.tracks
            )
        )
        return collection
    }
}

@MainActor
private func waitUntil(
    _ condition: @escaping @MainActor () -> Bool
) async {
    for _ in 0..<100 {
        if condition() { return }
        await Task.yield()
    }
    Issue.record("Timed out waiting for state")
}

private func importedCollection(
    id: String,
    name: String,
    readyCount: Int
) -> MusicCollection {
    let analysis = TempoAnalysis(
        baseBPM: 168,
        confidence: 0.9,
        analyzedDurationSeconds: 30,
        version: 2
    )
    return MusicCollection(
        id: MusicCollectionID(id),
        name: name,
        tracks: (0..<3).map { index in
            MusicTrack(
                id: MusicTrackID("\(id)-\(index)"),
                title: "Track \(index)",
                durationSeconds: 180,
                sourceFingerprint: "\(id)-\(index)-v1",
                analysisState: index < readyCount ? .ready(analysis) : .failed(.couldNotReadTempo)
            )
        }
    )
}

private extension SimulationConfiguration {
    static let productionFixture = SimulationConfiguration(
        fastMode: false,
        permissionDenied: false,
        simulateRouteLoss: false,
        missingArtwork: false,
        extendedAcquisitionWindow: false,
        useAppleMusicCoreLoop: false,
        musicSelectionFixture: .standard
    )
}
