import SamadhiDomain

public enum MusicPlaybackState: Sendable, Equatable {
    case stopped
    case playing
    case paused
}

public enum MusicPlaybackEvent: Sendable, Equatable {
    case prepared(operationID: Int, trackID: MusicTrackID)
    case stateChanged(operationID: Int, state: MusicPlaybackState)
    case rateChanged(
        operationID: Int,
        requestID: Int?,
        trackID: MusicTrackID?,
        rate: Double,
        latencySeconds: Double?
    )
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
    func prepare(
        _ collection: MusicCollection,
        startingAt trackID: MusicTrackID,
        operationID: Int
    ) async throws
    func play(operationID: Int) async throws
    func pause(operationID: Int)
    func resume(operationID: Int) async throws
    func skipToPrevious(operationID: Int) async throws
    func skipToNext(operationID: Int) async throws
    func prepareNext(
        trackID: MusicTrackID,
        operationID: Int,
        selectionID: Int
    ) async throws
    func clearPreparedNext(operationID: Int, selectionID: Int)
    func setPlaybackRate(
        _ rate: Double,
        operationID: Int,
        requestID: Int,
        trackID: MusicTrackID
    )
    func stop(operationID: Int)
}

@MainActor
public final class SimulatedMusicPlayer: MusicPlaybackProviding {
    private var continuation: AsyncStream<MusicPlaybackEvent>.Continuation?
    private var collection: MusicCollection?
    private var operationID: Int?
    private var trackIndex = 0
    private var preparedNextTrackIndex: Int?
    private var latestSelectionID = 0

    public init() {}

    public func events() -> AsyncStream<MusicPlaybackEvent> {
        AsyncStream(bufferingPolicy: .bufferingNewest(64)) { continuation in
            self.continuation = continuation
        }
    }

    public func prepare(
        _ collection: MusicCollection,
        startingAt trackID: MusicTrackID,
        operationID: Int
    ) async throws {
        guard let selectedIndex = collection.tracks.firstIndex(where: { $0.id == trackID }) else {
            throw MusicPlaybackError.emptyCollection
        }
        self.collection = collection
        self.operationID = operationID
        trackIndex = selectedIndex
        preparedNextTrackIndex = nil
        latestSelectionID = 0
        continuation?.yield(.prepared(operationID: operationID, trackID: trackID))
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
        trackIndex = preparedNextTrackIndex ?? (trackIndex + 1) % collection.tracks.count
        preparedNextTrackIndex = nil
        continuation?.yield(
            .trackChanged(operationID: operationID, trackID: collection.tracks[trackIndex].id)
        )
    }

    public func prepareNext(
        trackID: MusicTrackID,
        operationID: Int,
        selectionID: Int
    ) async throws {
        guard isCurrent(operationID), let collection,
            let index = collection.tracks.firstIndex(where: { $0.id == trackID })
        else { throw MusicPlaybackError.notPrepared }
        guard selectionID >= latestSelectionID else { return }
        latestSelectionID = selectionID
        preparedNextTrackIndex = index
    }

    public func clearPreparedNext(operationID: Int, selectionID: Int) {
        guard isCurrent(operationID), selectionID >= latestSelectionID else { return }
        latestSelectionID = selectionID
        preparedNextTrackIndex = nil
    }

    public func setPlaybackRate(
        _ rate: Double,
        operationID: Int,
        requestID: Int,
        trackID: MusicTrackID
    ) {
        guard isCurrent(operationID),
            collection?.tracks[trackIndex].id == trackID
        else { return }
        continuation?.yield(
            .rateChanged(
                operationID: operationID,
                requestID: requestID,
                trackID: trackID,
                rate: min(max(rate, 0.90), 1.10),
                latencySeconds: 0
            )
        )
    }

    public func stop(operationID: Int) {
        guard isCurrent(operationID) else { return }
        continuation?.yield(.stateChanged(operationID: operationID, state: .stopped))
        collection = nil
        preparedNextTrackIndex = nil
        latestSelectionID = 0
        self.operationID = nil
    }

    private func isCurrent(_ operationID: Int) -> Bool {
        self.operationID == operationID && collection != nil
    }
}
