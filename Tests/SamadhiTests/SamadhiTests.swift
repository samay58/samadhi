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

@Test @MainActor func simulatorDemoStartsReadyWithoutAppleMusic() {
    let model = MusicSelectionModel(configuration: .simulatorFixture)

    #expect(model.selectedCollection == AppMusicCollection.simulatorDemo)
    guard case let .ready(presentation) = model.presentation else {
        Issue.record("Expected local demo music to be ready")
        return
    }
    #expect(presentation.readyTrackCount == 3)
}

@Test @MainActor func simulatorDemoCanChooseAnotherPlaceholderPlaylist() async {
    let model = MusicSelectionModel(configuration: .simulatorFixture)

    model.beginChoosing()
    await waitUntil { model.playlistSheet != nil }
    let choice = try? #require(model.playlistSheet?.playlists.last)
    guard let choice else { return }
    model.selectPlaylist(choice)
    await waitUntil { model.selectedCollection?.id.rawValue == choice.id }

    #expect(model.selectedCollection?.name == choice.name)
    #expect(model.selectedCollection?.readyTrackCount == 4)
}

@Test func importBatchesPreserveOrderAndBoundConcurrency() {
    let batches = musicImportBatches(count: 18, width: 3)

    #expect(batches.flatMap { $0 } == Array(0..<18))
    #expect(batches.allSatisfy { $0.count <= 3 })
    #expect(musicImportBatches(count: 0, width: 3).isEmpty)
}

@Test func runDiagnosticsRoundTripPreservesPhysicalEvidence() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = RunDiagnosticsStore(directoryURL: directory)
    let capturedAt = Date(timeIntervalSince1970: 1_721_000_000)
    let snapshot = RunDiagnosticSnapshot(
        schemaVersion: 3,
        capturedAt: capturedAt,
        collectionID: "playlist",
        collectionName: "Strut Frequency",
        readyTrackCount: 3,
        summary: RunDiagnosticSnapshot.Summary(
            durationSeconds: 59,
            averageCadence: 155,
            tempoMatchedPercent: 98,
            tempoMatchedCoveragePercent: 95,
            automaticSeconds: 40,
            manualSeconds: 19,
            songCount: 2
        ),
        timeline: [
            RunDiagnosticSnapshot.Entry(
                offsetSeconds: 12,
                kind: .rateApplied,
                activeSeconds: 10,
                cadenceSPM: 155,
                targetRate: 1.035,
                controlMode: RhythmControlMode.automatic.rawValue,
                automaticCorrectionBPM: 2,
                manualTargetBPM: 168,
                requestedBPM: 157,
                derivedTargetRate: 1.035,
                atLimit: false,
                commandStatus: TempoCommandStatus.applied.rawValue,
                achievableBPM: 157,
                commandedRate: 1.03,
                commandLatencySeconds: 0.08,
                appliedRate: 1.03,
                awaitingRateFeedback: false,
                trackID: "101",
                trackTitle: "First",
                trackIndex: 0,
                trackElapsedSeconds: 10,
                trackDurationSeconds: 180,
                tempoMatched: true
            )
        ]
    )

    try await store.save(snapshot)

    #expect(try await store.latest() == snapshot)
}

@Test func runDiagnosticsCapturePlayerTruthThroughFinish() throws {
    var time = Date(timeIntervalSince1970: 1_721_000_000)
    var recorder = RunDiagnosticsRecorder(now: { time })
    let collection = importedCollection(id: "playlist", name: "Strut Frequency", readyCount: 3)
    let reducer = RunReducer(tracks: collection.tracks)
    var state: RunState = .ready

    func apply(_ event: RunEvent) -> RunDiagnosticSnapshot? {
        let oldState = state
        let newState = reducer.reduce(state: state, event: event).0
        state = newState
        time = time.addingTimeInterval(1)
        return recorder.record(
            event: event,
            oldState: oldState,
            newState: newState,
            collection: collection
        )
    }

    #expect(apply(.startTapped(sessionID: 1)) == nil)
    #expect(apply(.authorizationResolved(sessionID: 1, .authorized)) == nil)
    #expect(
        apply(
            .playbackPrepared(
                sessionID: 1,
                trackID: collection.tracks[0].id
            )
        ) == nil
    )
    #expect(
        apply(
            .cadenceUpdated(
                sessionID: 1,
                acquisitionID: 1,
                stepsPerMinute: 162,
                deltaSeconds: 1,
                rateRequestID: 3
            )
        ) == nil
    )
    #expect(
        apply(
            .playbackRateApplied(
                sessionID: 1,
                operationID: 1,
                requestID: 3,
                trackID: collection.tracks[0].id,
                rate: 0.98,
                latencySeconds: 0
            )
        ) == nil
    )
    #expect(
        apply(
            .playbackProgress(
                sessionID: 1,
                operationID: 1,
                trackIndex: 0,
                elapsedSeconds: 12,
                durationSeconds: 180
            )
        ) == nil
    )
    #expect(apply(.activeSecond(tempoMatched: true)) == nil)
    #expect(
        apply(
            .playbackTrackChanged(
                sessionID: 1,
                operationID: 1,
                trackID: collection.tracks[1].id,
                trackIndex: 1,
                rateRequestID: 4
            )
        ) == nil
    )
    #expect(apply(.surfaceTapped(timeoutID: 4)) == nil)
    #expect(apply(.finishTapped) == nil)
    #expect(apply(.finishHoldBegan(holdID: 5)) == nil)
    #expect(apply(.finishHoldCompleted(holdID: 5)) == nil)
    let snapshot = try #require(apply(.finishCompleted(sessionID: 1)))

    #expect(snapshot.summary.averageCadence == 162)
    #expect(snapshot.summary.tempoMatchedPercent == 100)
    #expect(snapshot.summary.tempoMatchedCoveragePercent == 100)
    #expect(snapshot.summary.automaticSeconds == 1)
    #expect(snapshot.summary.manualSeconds == 0)
    #expect(snapshot.summary.songCount == 2)
    #expect(
        snapshot.timeline.map(\.kind) == [
            .started,
            .cadenceUpdated,
            .rateApplied,
            .playerProgress,
            .activeSecond,
            .trackChanged,
            .finishRequested,
            .finished,
        ]
    )
    #expect(snapshot.timeline[2].appliedRate == 0.98)
    #expect(snapshot.timeline[3].trackElapsedSeconds == 12)
    #expect(snapshot.schemaVersion == 4)
    #expect(snapshot.timeline[1].controlMode == RhythmControlMode.automatic.rawValue)
    #expect(snapshot.timeline[1].automaticCorrectionBPM == 0)
    #expect(snapshot.timeline[1].requestedBPM == 162)
    #expect(snapshot.timeline[1].derivedTargetRate != nil)
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
    let importer = FixtureMusicImporter(collections: [collection.id.rawValue: collection])
    let model = MusicSelectionModel(
        store: store,
        importer: importer,
        configuration: .productionFixture
    )

    await model.restore()

    #expect(model.selectedCollection == collection)
    guard case let .ready(presentation) = model.presentation else {
        Issue.record("Expected restored music to be ready")
        return
    }
    #expect(presentation.readyTrackCount == 2)

    model.retryLastImport()
    await waitUntil { importer.importedIDs == [collection.id.rawValue] }
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
                        version: 4
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
    #expect(presentation.tracks.first?.status == .rhythmUnclear)
}

@Test @MainActor func staleTempoAnalysisIsReimportedBeforeUse() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = MusicCollectionStore(directoryURL: directory)
    let stale = importedCollection(id: "saved", name: "Saved", readyCount: 2, analysisVersion: 3)
    let refreshed = importedCollection(id: "saved", name: "Saved", readyCount: 2)
    try await store.replaceSelection(stale)
    let importer = FixtureMusicImporter(collections: ["saved": refreshed])
    let model = MusicSelectionModel(
        store: store,
        importer: importer,
        configuration: .productionFixture
    )

    await model.restore()
    await waitUntil { model.selectedCollection == refreshed }

    #expect(importer.importedIDs == ["saved"])
    #expect(try await store.selectedCollection() == refreshed)
}

@Test @MainActor func importPresentationKeepsEveryTrackAndItsFailureReason() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let analysis = TempoAnalysis(
        baseBPM: 168,
        confidence: 0.9,
        analyzedDurationSeconds: 30,
        version: 2
    )
    let failures: [TrackAnalysisFailure] = [
        .rhythmUnclear,
        .previewUnavailable,
        .catalogMatchUnavailable,
        .temporaryCatalogFailure,
        .temporaryDownloadFailure,
        .decodeFailure,
    ]
    let tracks = (0..<18).map { index in
        MusicTrack(
            id: MusicTrackID("track-\(index)"),
            title: "Track \(index)",
            durationSeconds: 180,
            sourceFingerprint: "track-\(index)-v1",
            analysisState: index < 12
                ? .ready(analysis)
                : .failed(failures[index - 12])
        )
    }
    let collection = MusicCollection(
        id: MusicCollectionID("complete"),
        name: "Complete",
        tracks: tracks
    )
    let importer = FixtureMusicImporter(collections: ["complete": collection])
    let model = MusicSelectionModel(
        store: MusicCollectionStore(directoryURL: directory),
        importer: importer,
        configuration: .productionFixture
    )

    model.selectPlaylist(LibraryPlaylistChoice(id: "complete", name: "Complete"))
    await waitUntil { model.selectedCollection?.id == collection.id }

    guard case let .ready(presentation) = model.presentation else {
        Issue.record("Expected complete import presentation")
        return
    }
    #expect(presentation.tracks.count == 18)
    #expect(presentation.readyTrackCount == 12)
    #expect(presentation.tracks[12].status == .rhythmUnclear)
    #expect(presentation.tracks[13].status == .previewUnavailable)
    #expect(presentation.tracks[14].status == .catalogMatchUnavailable)
    #expect(presentation.tracks[15].status == .temporaryFailure)
    #expect(presentation.tracks[16].status == .temporaryFailure)
    #expect(presentation.tracks[17].status == .temporaryFailure)
}

@Test @MainActor func transientImportCanRetryTheSamePlaylist() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let collection = importedCollection(id: "retry", name: "Retry", readyCount: 2)
    let importer = FixtureMusicImporter(collections: ["retry": collection])
    let model = MusicSelectionModel(
        store: MusicCollectionStore(directoryURL: directory),
        importer: importer,
        configuration: .productionFixture
    )

    model.selectPlaylist(LibraryPlaylistChoice(id: "retry", name: "Retry"))
    await waitUntil { importer.importedIDs.count == 1 }
    model.retryLastImport()
    await waitUntil { importer.importedIDs.count == 2 }

    #expect(importer.importedIDs == ["retry", "retry"])
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
    private(set) var importedIDs: [String] = []

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
        importedIDs.append(id)
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
        try? await Task.sleep(for: .milliseconds(10))
    }
    Issue.record("Timed out waiting for state")
}

private func importedCollection(
    id: String,
    name: String,
    readyCount: Int,
    analysisVersion: Int = 4
) -> MusicCollection {
    let analysis = TempoAnalysis(
        baseBPM: 168,
        confidence: 0.9,
        analyzedDurationSeconds: 30,
        version: analysisVersion
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
        useSimulatorDemoMusic: false,
        musicSelectionFixture: .standard
    )

    static let simulatorFixture = SimulationConfiguration(
        fastMode: false,
        permissionDenied: false,
        simulateRouteLoss: false,
        missingArtwork: false,
        extendedAcquisitionWindow: false,
        useAppleMusicCoreLoop: false,
        useSimulatorDemoMusic: true,
        musicSelectionFixture: .standard
    )
}
