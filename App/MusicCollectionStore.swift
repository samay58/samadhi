import Foundation
import SamadhiDomain

actor MusicCollectionStore {
    private struct CacheRecord: Codable {
        let key: TempoAnalysisCacheKey
        let analysis: TempoAnalysis
    }

    private struct StoredState: Codable {
        var selectedCollection: MusicCollection?
        var cache: [CacheRecord]

        static let empty = StoredState(selectedCollection: nil, cache: [])
    }

    private let directoryURL: URL
    private let fileURL: URL

    init(directoryURL: URL? = nil) {
        let directory: URL
        if let directoryURL {
            directory = directoryURL
        } else if let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first {
            directory = applicationSupport.appending(
                path: "Samadhi",
                directoryHint: .isDirectory
            )
        } else {
            directory = FileManager.default.temporaryDirectory.appending(
                path: "Samadhi",
                directoryHint: .isDirectory
            )
        }
        self.directoryURL = directory
        fileURL = directory.appending(path: "selected-music.json")
    }

    func selectedCollection() throws -> MusicCollection? {
        try load().selectedCollection
    }

    func replaceSelection(_ collection: MusicCollection?) throws {
        var state = try load()
        state.selectedCollection = collection
        try save(state)
    }

    func cachedAnalysis(for key: TempoAnalysisCacheKey) throws -> TempoAnalysis? {
        try load().cache.first(where: { $0.key == key })?.analysis
    }

    func cache(_ analysis: TempoAnalysis, for key: TempoAnalysisCacheKey) throws {
        var state = try load()
        state.cache.removeAll { $0.key == key }
        state.cache.append(CacheRecord(key: key, analysis: analysis))
        try save(state)
    }

    func cachedAnalysisCount() throws -> Int {
        try load().cache.count
    }

    private func load() throws -> StoredState {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return .empty
        }
        do {
            return try JSONDecoder().decode(StoredState.self, from: Data(contentsOf: fileURL))
        } catch is DecodingError {
            return .empty
        }
    }

    private func save(_ state: StoredState) throws {
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        try encoder.encode(state).write(to: fileURL, options: .atomic)
    }
}
