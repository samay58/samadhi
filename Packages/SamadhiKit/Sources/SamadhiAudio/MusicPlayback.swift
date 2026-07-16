import SamadhiDomain

public enum MusicPlaybackState: Sendable, Equatable {
    case stopped
    case playing
    case paused
}

public enum MusicPlaybackEvent: Sendable, Equatable {
    case prepared(operationID: Int, trackID: MusicTrackID)
    case stateChanged(operationID: Int, state: MusicPlaybackState)
    case rateChanged(operationID: Int, rate: Double)
    case progress(operationID: Int, PlaybackProgress)
    case trackChanged(operationID: Int, trackID: MusicTrackID)
    case interruptionBegan(operationID: Int)
    case interruptionEnded(operationID: Int)
    case routeLost(operationID: Int)
    case routeRestored(operationID: Int)
    case failed(operationID: Int, message: String)
}

public enum MusicPlaybackError: Error, Sendable, Equatable {
    case emptyCollection
    case notPrepared
}

@MainActor
public protocol MusicPlaybackProviding: AnyObject {
    func events() -> AsyncStream<MusicPlaybackEvent>
    func prepare(_ collection: MusicCollection, operationID: Int) async throws
    func play(operationID: Int) async throws
    func pause(operationID: Int)
    func resume(operationID: Int) async throws
    func skipToPrevious(operationID: Int) async throws
    func skipToNext(operationID: Int) async throws
    func setPlaybackRate(_ rate: Double, operationID: Int)
    func stop(operationID: Int)
}

@MainActor
public final class SimulatedMusicPlayer: MusicPlaybackProviding {
    private var continuation: AsyncStream<MusicPlaybackEvent>.Continuation?
    private var collection: MusicCollection?
    private var operationID: Int?
    private var trackIndex = 0

    public init() {}

    public func events() -> AsyncStream<MusicPlaybackEvent> {
        AsyncStream(bufferingPolicy: .bufferingNewest(64)) { continuation in
            self.continuation = continuation
        }
    }

    public func prepare(_ collection: MusicCollection, operationID: Int) async throws {
        guard let firstTrack = collection.tracks.first else {
            throw MusicPlaybackError.emptyCollection
        }
        self.collection = collection
        self.operationID = operationID
        trackIndex = 0
        continuation?.yield(.prepared(operationID: operationID, trackID: firstTrack.id))
    }

    public func play(operationID: Int) async throws {
        guard isCurrent(operationID) else { return }
        continuation?.yield(.stateChanged(operationID: operationID, state: .playing))
    }

    public func pause(operationID: Int) {
        guard isCurrent(operationID) else { return }
        continuation?.yield(.stateChanged(operationID: operationID, state: .paused))
    }

    public func resume(operationID: Int) async throws {
        try await play(operationID: operationID)
    }

    public func skipToPrevious(operationID: Int) async throws {
        guard isCurrent(operationID), let collection else { return }
        trackIndex = (trackIndex - 1 + collection.tracks.count) % collection.tracks.count
        continuation?.yield(
            .trackChanged(operationID: operationID, trackID: collection.tracks[trackIndex].id)
        )
    }

    public func skipToNext(operationID: Int) async throws {
        guard isCurrent(operationID), let collection else { return }
        trackIndex = (trackIndex + 1) % collection.tracks.count
        continuation?.yield(
            .trackChanged(operationID: operationID, trackID: collection.tracks[trackIndex].id)
        )
    }

    public func setPlaybackRate(_ rate: Double, operationID: Int) {
        guard isCurrent(operationID) else { return }
        continuation?.yield(
            .rateChanged(operationID: operationID, rate: min(max(rate, 0.94), 1.06))
        )
    }

    public func stop(operationID: Int) {
        guard isCurrent(operationID) else { return }
        continuation?.yield(.stateChanged(operationID: operationID, state: .stopped))
        collection = nil
        self.operationID = nil
    }

    private func isCurrent(_ operationID: Int) -> Bool {
        self.operationID == operationID && collection != nil
    }
}
