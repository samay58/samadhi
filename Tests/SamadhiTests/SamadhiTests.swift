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

@Test @MainActor func choosingMusicKeepsTheCurrentPlaylistStableAndMarksItInThePicker() async {
    let model = MusicSelectionModel(configuration: .simulatorFixture)

    model.beginChoosing()

    guard case let .loadingPlaylists(current) = model.presentation else {
        Issue.record("Expected playlist loading presentation")
        return
    }
    #expect(current?.name == AppMusicCollection.simulatorDemo.name)

    await waitUntil { model.playlistSheet != nil }
    #expect(model.playlistSheet?.selectedPlaylistID == AppMusicCollection.simulatorDemo.id.rawValue)
}

@Test @MainActor func emptyLibraryFixturePresentsAnEmptyPickerWithoutInventedChoices() async {
    let model = MusicSelectionModel(configuration: .simulatorFastFixture(.emptyLibrary))

    #expect(model.presentation == .none)
    model.beginChoosing()
    await waitUntil { model.playlistSheet != nil }

    #expect(model.playlistSheet?.playlists.isEmpty == true)
    #expect(model.playlistSheet?.selectedPlaylistID == nil)
}

@Test @MainActor func twoPlaylistFixtureKeepsStableChoiceIdentity() async {
    let model = MusicSelectionModel(configuration: .simulatorFastFixture(.twoPlaylistLibrary))

    model.beginChoosing()
    await waitUntil { model.playlistSheet != nil }

    let choices = model.playlistSheet?.playlists ?? []
    #expect(choices.map(\.id) == ["simulator-demo", "simulator-cruise"])
    #expect(choices.map(\.name) == ["Samadhi demo", "Soft Miles"])
    #expect(Set(choices.map(\.id)).count == choices.count)
}

@Test @MainActor func selectedPlaylistIdentitySurvivesLibraryLoading() {
    let model = MusicSelectionModel(configuration: .simulatorFastFixture(.loadingSelected))

    #expect(model.selectedCollection == AppMusicCollection.simulatorDemo)
    guard case let .loadingPlaylists(current) = model.presentation else {
        Issue.record("Expected loading presentation with the existing playlist")
        return
    }
    #expect(current?.name == AppMusicCollection.simulatorDemo.name)
    #expect(current?.readyTrackCount == AppMusicCollection.simulatorDemo.readyTrackCount)
}

@Test @MainActor func longPlaylistFixturePreservesTheCompleteNameAndReadyTruth() {
    let model = MusicSelectionModel(configuration: .simulatorFastFixture(.longPlaylistName))

    guard case let .ready(presentation) = model.presentation else {
        Issue.record("Expected long-name fixture to be ready")
        return
    }
    #expect(presentation.name == "Saturday Miles Through the Hills After the Rain")
    #expect(presentation.readyTrackCount == 2)
    #expect(presentation.skippedTrackCount == 0)
}

@Test @MainActor func partialFixtureKeepsReadyTruthSeparateFromEverySkippedReason() {
    let model = MusicSelectionModel(configuration: .simulatorFastFixture(.partial))

    guard case let .ready(presentation) = model.presentation else {
        Issue.record("Expected partial fixture to be ready")
        return
    }
    #expect(presentation.readyTrackCount == 1)
    #expect(presentation.skippedTrackCount == 5)
    #expect(presentation.tracks.count == 6)
    #expect(presentation.tracks.filter { $0.status == .ready }.count == 1)
    #expect(presentation.tracks.filter { $0.status != .ready }.count == 5)
    #expect(presentation.hasTemporaryFailures)
}

@Test func importBatchesPreserveOrderAndBoundConcurrency() {
    let batches = musicImportBatches(count: 18, width: 3)

    #expect(batches.flatMap { $0 } == Array(0..<18))
    #expect(batches.allSatisfy { $0.count <= 3 })
    #expect(musicImportBatches(count: 0, width: 3).isEmpty)
}

@Test func diagnosticLaunchArgumentsHidePrivateValues() {
    let arguments = DiagnosticEnvironment.sanitizedLaunchArguments([
        "--diagnostic-scenario=verified",
        "--api-key=private-value",
        "--token",
        "another-private-value",
    ])

    #expect(
        arguments == [
            "--diagnostic-scenario=verified",
            "--api-key=<redacted>",
            "--token",
            "<redacted>",
        ]
    )
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
                originalStepRhythmSPM: 152,
                appliedStepRhythmSPM: 157,
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
    let encoded = try String(
        contentsOf: directory.appending(path: "latest-run-diagnostics.json"),
        encoding: .utf8
    )
    #expect(encoded.contains("originalStepRhythmSPM"))
    #expect(encoded.contains("appliedStepRhythmSPM"))
    #expect(!encoded.contains("runningPulseBPM"))
    #expect(!encoded.contains("appliedRunningPulseBPM"))
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

    _ = apply(.startTapped(sessionID: 1))
    _ = apply(.authorizationResolved(sessionID: 1, .authorized))
    _ = apply(.playbackPrepared(sessionID: 1, trackID: collection.tracks[0].id))
    _ = apply(
        .cadenceUpdated(
            sessionID: 1,
            acquisitionID: 1,
            stepsPerMinute: 162,
            deltaSeconds: 1,
            rateRequestID: 3
        )
    )
    _ = apply(
        .playbackRateApplied(
            sessionID: 1,
            operationID: 1,
            requestID: 3,
            trackID: collection.tracks[0].id,
            rate: 0.98,
            latencySeconds: 0
        )
    )
    _ = apply(
        .playbackProgress(
            sessionID: 1,
            operationID: 1,
            trackIndex: 0,
            elapsedSeconds: 12,
            durationSeconds: 180
        )
    )
    _ = apply(.activeSecond(tempoMatched: true))
    _ = apply(
        .playbackTrackChanged(
            sessionID: 1,
            operationID: 1,
            trackID: collection.tracks[1].id,
            trackIndex: 1,
            reason: .naturalBoundary,
            rateRequestID: 4
        )
    )
    _ = apply(.surfaceTapped(timeoutID: 4))
    _ = apply(.finishTapped)
    _ = apply(.finishHoldBegan(holdID: 5))
    _ = apply(.finishHoldCompleted(holdID: 5))
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
    #expect(snapshot.schemaVersion == RunDiagnosticSnapshot.currentSchemaVersion)
    #expect(snapshot.completionState == .completed)
    #expect(snapshot.timeline[1].controlMode == RhythmControlMode.automatic.rawValue)
    #expect(snapshot.timeline[1].automaticCorrectionBPM == 0)
    #expect(snapshot.timeline[1].requestedBPM == 162)
    #expect(snapshot.timeline[1].derivedTargetRate != nil)
    #expect(snapshot.timeline[5].trackChangeReason == TrackChangeReason.naturalBoundary.rawValue)
}

@Test func runDiagnosticsSurviveAnUnfinishedRunAndKeepCadenceTiming() throws {
    var time = Date(timeIntervalSince1970: 1_721_000_000)
    var recorder = RunDiagnosticsRecorder(now: { time })
    let collection = importedCollection(id: "playlist", name: "Field fixture", readyCount: 3)
    let reducer = RunReducer(tracks: collection.tracks)
    var state: RunState = .ready

    func apply(_ event: RunEvent) -> RunDiagnosticSnapshot? {
        let oldState = state
        state = reducer.reduce(state: state, event: event).0
        let snapshot = recorder.record(
            event: event,
            oldState: oldState,
            newState: state,
            collection: collection
        )
        time = time.addingTimeInterval(1)
        return snapshot
    }

    _ = apply(.startTapped(sessionID: 7))
    _ = apply(.authorizationResolved(sessionID: 7, .authorized))
    _ = apply(.playbackPrepared(sessionID: 7, trackID: collection.tracks[0].id))
    time = time.addingTimeInterval(3)
    let cadenceSnapshot = recorder.record(
        cadenceSample: CadenceDiagnosticSample(
            rawStepsPerMinute: 161,
            sampleAgeSeconds: 0.2,
            sampleEndDateSeconds: 1_721_000_003,
            callbackIntervalSeconds: 1.4,
            filterState: .tracking,
            disposition: .acceptedFresh,
            filteredStepsPerMinute: 159
        ),
        state: state,
        collection: collection
    )
    let rolling = try #require(cadenceSnapshot)

    #expect(rolling.completionState == .inProgress)
    #expect(rolling.schemaVersion == RunDiagnosticSnapshot.currentSchemaVersion)
    #expect(rolling.timeline.last?.kind == .cadenceObserved)
    #expect(rolling.timeline.last?.rawCadenceSPM == 161)
    #expect(rolling.timeline.last?.callbackIntervalSeconds == 1.4)
    #expect(rolling.timeline.last?.cadenceFilterState == "tracking")
    #expect(rolling.timeline.last?.cadenceSampleDisposition == "acceptedFresh")
    #expect(rolling.timeline.last?.filteredCadenceSPM == 159)
}

@Test func diagnosticViewKeepsSongBeatsAndRunnerStepsSeparate() throws {
    let track = MusicTrack(
        id: MusicTrackID("low-tempo"),
        title: "Low tempo fixture",
        durationSeconds: 180,
        tempo: TempoAnalysis(
            baseBPM: 84,
            alternatePulseBPM: 168,
            confidence: 0.94,
            analyzedDurationSeconds: 30,
            version: 4
        )
    )
    let collection = MusicCollection(
        id: MusicCollectionID("diagnostic-fixture"),
        name: "Diagnostic fixture",
        tracks: [track]
    )
    let reducer = RunReducer(tracks: [track])
    var state: RunState = .ready
    state = reducer.reduce(state: state, event: .startTapped(sessionID: 31)).0
    state =
        reducer.reduce(
            state: state,
            event: .authorizationResolved(sessionID: 31, .authorized)
        ).0
    state =
        reducer.reduce(
            state: state,
            event: .playbackPrepared(sessionID: 31, trackID: track.id)
        ).0
    state =
        reducer.reduce(
            state: state,
            event: .cadenceUpdated(
                sessionID: 31,
                acquisitionID: 1,
                stepsPerMinute: 175,
                deltaSeconds: 1,
                rateRequestID: 33
            )
        ).0
    let commandedRate = try #require(state.session?.pendingCommandedRate)
    state =
        reducer.reduce(
            state: state,
            event: .playbackRateApplied(
                sessionID: 31,
                operationID: 31,
                requestID: 33,
                trackID: track.id,
                rate: commandedRate,
                latencySeconds: 0.08
            )
        ).0
    let presentation = CoreLoopDiagnosticPresentation(
        state: state,
        collection: collection,
        cadenceSample: CadenceDiagnosticSample(
            rawStepsPerMinute: 176,
            sampleAgeSeconds: 0.1,
            sampleEndDateSeconds: 1_721_000_000,
            callbackIntervalSeconds: 1,
            filterState: .tracking,
            disposition: .acceptedFresh,
            filteredStepsPerMinute: 175
        )
    )

    #expect(presentation.measuredSongBPM == 84)
    #expect(presentation.alternatePulseBPM == 168)
    #expect(presentation.relationship == .twoStepsPerBeat)
    #expect(presentation.originalStepRhythmSPM == 168)
    #expect(presentation.rawStepSPM == 176)
    #expect(presentation.smoothedStepSPM == 175)
    #expect(presentation.resultingMusicalBPM == 84 * commandedRate)
    #expect(presentation.resultingStepRhythmSPM == 168 * commandedRate)
    #expect(
        abs(try #require(presentation.remainingDifferenceSPM) - ((168 * commandedRate) - 175))
            < 0.001
    )
    #expect(presentation.status == TempoDiagnosticStatus.verified)
    #expect(presentation.settledAutoTargetSPM == 175)
    #expect(presentation.autoTargetStatus == .settled)
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

@Test @MainActor func importFailuresKeepTypedPlaylistRecoveryContext() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let importer = FixtureMusicImporter(
        collections: [:],
        importErrors: ["missing": .playlistUnavailable]
    )
    let model = MusicSelectionModel(
        store: MusicCollectionStore(directoryURL: directory),
        importer: importer,
        configuration: .productionFixture
    )

    model.selectPlaylist(LibraryPlaylistChoice(id: "missing", name: "Evening Miles"))
    await waitUntil {
        model.presentation == .failed(.playlistUnavailable(name: "Evening Miles"))
    }

    #expect(model.presentation == .failed(.playlistUnavailable(name: "Evening Miles")))
}

@Test @MainActor func emptyPlaylistFailureKeepsTypedPlaylistRecoveryContext() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let importer = FixtureMusicImporter(
        collections: [:],
        importErrors: ["empty": .emptyPlaylist]
    )
    let model = MusicSelectionModel(
        store: MusicCollectionStore(directoryURL: directory),
        importer: importer,
        configuration: .productionFixture
    )

    model.selectPlaylist(LibraryPlaylistChoice(id: "empty", name: "Quiet Miles"))
    await waitUntil {
        model.presentation == .failed(.emptyPlaylist(name: "Quiet Miles"))
    }

    #expect(model.presentation == .failed(.emptyPlaylist(name: "Quiet Miles")))
}

@Test @MainActor func authorizationFailureIsDistinctFromLibraryFailure() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let model = MusicSelectionModel(
        store: MusicCollectionStore(directoryURL: directory),
        importer: FixtureMusicImporter(
            collections: [:],
            loadError: .authorizationDenied
        ),
        configuration: .productionFixture
    )

    model.beginChoosing()
    await waitUntil { model.presentation == .failed(.authorizationDenied) }

    #expect(model.presentation == .failed(.authorizationDenied))
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
    let loadError: AppleMusicImportError?
    let importErrors: [String: AppleMusicImportError]
    private(set) var importedIDs: [String] = []

    init(
        collections: [String: MusicCollection],
        delayedID: String? = nil,
        loadError: AppleMusicImportError? = nil,
        importErrors: [String: AppleMusicImportError] = [:]
    ) {
        self.collections = collections
        self.delayedID = delayedID
        self.loadError = loadError
        self.importErrors = importErrors
    }

    func loadPlaylists() async throws -> [LibraryPlaylistChoice] {
        if let loadError { throw loadError }
        return collections.map { LibraryPlaylistChoice(id: $0.key, name: $0.value.name) }
    }

    func importPlaylist(
        id: String,
        progress: @escaping @MainActor (MusicImportProgress) -> Void
    ) async throws -> MusicCollection {
        importedIDs.append(id)
        if let error = importErrors[id] { throw error }
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
    static func simulatorFastFixture(
        _ musicSelectionFixture: MusicSelectionFixture
    ) -> SimulationConfiguration {
        SimulationConfiguration(
            fastMode: true,
            permissionDenied: false,
            simulateRouteLoss: false,
            missingArtwork: false,
            extendedAcquisitionWindow: false,
            useAppleMusicCoreLoop: false,
            useSimulatorDemoMusic: true,
            setupReviewMode: false,
            musicSelectionFixture: musicSelectionFixture
        )
    }

    static let productionFixture = SimulationConfiguration(
        fastMode: false,
        permissionDenied: false,
        simulateRouteLoss: false,
        missingArtwork: false,
        extendedAcquisitionWindow: false,
        useAppleMusicCoreLoop: false,
        useSimulatorDemoMusic: false,
        setupReviewMode: false,
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
        setupReviewMode: false,
        musicSelectionFixture: .standard
    )
}
