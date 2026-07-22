import Foundation
import Observation
import SamadhiDesign
import SamadhiDomain

struct PlaylistSheetPresentation: Identifiable, Equatable {
    let id: Int
    let playlists: [LibraryPlaylistChoice]
}

@MainActor
@Observable
final class MusicSelectionModel {
    private(set) var selectedCollection: MusicCollection?
    private(set) var presentation: MusicSelectionPresentation = .none
    var playlistSheet: PlaylistSheetPresentation?

    @ObservationIgnored private let store: MusicCollectionStore
    @ObservationIgnored private let importer: any MusicLibraryImporting
    @ObservationIgnored private let configuration: SimulationConfiguration
    @ObservationIgnored private var operationTask: Task<Void, Never>?
    @ObservationIgnored private var nextOperationID = 1
    @ObservationIgnored private var currentOperationID: Int?
    @ObservationIgnored private var lastSelectedChoice: LibraryPlaylistChoice?

    init(
        store: MusicCollectionStore = MusicCollectionStore(),
        importer: (any MusicLibraryImporting)? = nil,
        configuration: SimulationConfiguration = .current
    ) {
        self.store = store
        if let importer {
            self.importer = importer
        } else if configuration.useSimulatorDemoMusic {
            self.importer = SimulatorMusicImportService()
        } else {
            self.importer = AppleMusicImportService(store: store)
        }
        self.configuration = configuration

        if configuration.fastMode {
            applyFixture(configuration.musicSelectionFixture)
        } else if configuration.useAppleMusicCoreLoop {
            apply(AppMusicCollection.appleMusicCoreLoop)
        } else if configuration.useSimulatorDemoMusic {
            apply(AppMusicCollection.simulatorDemo)
        }
    }

    deinit {
        operationTask?.cancel()
    }

    func restore() async {
        guard !configuration.fastMode,
            !configuration.useAppleMusicCoreLoop,
            !configuration.useSimulatorDemoMusic
        else { return }
        do {
            guard let collection = try await store.selectedCollection() else {
                presentation = .none
                return
            }
            lastSelectedChoice = LibraryPlaylistChoice(
                id: collection.id.rawValue,
                name: collection.name
            )
            apply(collection)
        } catch {
            presentation = .failed("Your saved music could not be opened.")
        }
    }

    func beginChoosing() {
        let operationID = beginOperation()
        presentation = .loadingPlaylists
        operationTask = Task { [weak self, importer] in
            do {
                let playlists = try await importer.loadPlaylists()
                guard !Task.isCancelled, let self, currentOperationID == operationID else {
                    return
                }
                playlistSheet = PlaylistSheetPresentation(
                    id: operationID,
                    playlists: playlists
                )
                presentation = selectedCollection.map(Self.readyPresentation) ?? .none
            } catch is CancellationError {
                return
            } catch {
                guard let self, currentOperationID == operationID else { return }
                presentation = .failed(Self.message(for: error))
            }
        }
    }

    func selectPlaylist(_ choice: LibraryPlaylistChoice) {
        lastSelectedChoice = choice
        playlistSheet = nil
        let operationID = beginOperation()
        presentation = .analyzing(
            ImportedCollectionPresentation(
                name: choice.name,
                totalTrackCount: 0,
                readyTrackCount: 0,
                completedTrackCount: 0,
                tracks: []
            )
        )
        operationTask = Task { [weak self, importer, store] in
            do {
                let collection = try await importer.importPlaylist(id: choice.id) { progress in
                    guard let self, self.currentOperationID == operationID else { return }
                    self.presentation = .analyzing(
                        Self.presentation(
                            name: choice.name,
                            tracks: progress.tracks,
                            totalCount: progress.totalCount,
                            completedCount: progress.completedCount
                        )
                    )
                }
                guard !Task.isCancelled, let self, currentOperationID == operationID else {
                    return
                }
                try await store.replaceSelection(collection)
                guard currentOperationID == operationID else { return }
                apply(collection)
            } catch is CancellationError {
                return
            } catch {
                guard let self, currentOperationID == operationID else { return }
                presentation = .failed(Self.message(for: error))
            }
        }
    }

    func retryLastImport() {
        guard let lastSelectedChoice else { return }
        selectPlaylist(lastSelectedChoice)
    }

    private func beginOperation() -> Int {
        operationTask?.cancel()
        let operationID = nextOperationID
        nextOperationID += 1
        currentOperationID = operationID
        return operationID
    }

    private func apply(_ collection: MusicCollection) {
        selectedCollection = collection
        presentation = Self.readyPresentation(collection)
    }

    private func applyFixture(_ fixture: MusicSelectionFixture) {
        switch fixture {
        case .standard:
            apply(AppMusicCollection.simulated)
        case .none:
            presentation = .none
        case .loading:
            presentation = .loadingPlaylists
        case .analyzing:
            let collection = AppMusicCollection.partialImportFixture
            presentation = .analyzing(
                Self.presentation(
                    name: collection.name,
                    tracks: Array(collection.tracks.prefix(2)),
                    totalCount: 8,
                    completedCount: 2
                )
            )
        case .partial:
            apply(AppMusicCollection.partialImportFixture)
        case .authorizationFailure:
            presentation = .failed("Apple Music access is needed to choose a playlist.")
        case .importFailure:
            presentation = .failed("Your Apple Music playlist could not be analyzed.")
        }
    }

    private static func readyPresentation(
        _ collection: MusicCollection
    ) -> MusicSelectionPresentation {
        .ready(
            presentation(
                name: collection.name,
                tracks: collection.tracks,
                totalCount: collection.tracks.count,
                completedCount: collection.tracks.count
            )
        )
    }

    private static func presentation(
        name: String,
        tracks: [MusicTrack],
        totalCount: Int,
        completedCount: Int
    ) -> ImportedCollectionPresentation {
        ImportedCollectionPresentation(
            name: name,
            totalTrackCount: totalCount,
            readyTrackCount: tracks.count(where: \.isAdaptiveReady),
            completedTrackCount: completedCount,
            tracks: tracks.map {
                ImportedTrackPresentation(
                    id: $0.id.rawValue,
                    title: $0.title,
                    status: presentationStatus(for: $0.analysisState)
                )
            }
        )
    }

    private static func presentationStatus(
        for state: MusicTrackAnalysisState
    ) -> MusicTrackImportPresentation {
        switch state {
        case .pending:
            .pending
        case let .ready(analysis):
            analysis.isAdaptiveReady ? .ready : .rhythmUnclear
        case .failed(.rhythmUnclear), .failed(.couldNotReadTempo):
            .rhythmUnclear
        case .failed(.previewUnavailable):
            .previewUnavailable
        case .failed(.catalogMatchUnavailable), .failed(.unavailable):
            .catalogMatchUnavailable
        case .failed(.temporaryCatalogFailure), .failed(.temporaryDownloadFailure),
            .failed(.decodeFailure):
            .temporaryFailure
        }
    }

    private static func message(for error: Error) -> String {
        switch error {
        case AppleMusicImportError.authorizationDenied:
            "Apple Music access is needed to choose a playlist."
        case AppleMusicImportError.emptyPlaylist:
            "This playlist has no tracks."
        default:
            "Your Apple Music playlists could not be opened."
        }
    }
}
