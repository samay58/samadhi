#if os(iOS)
    import AVFoundation
    // MusicKit's player stays main-actor owned until its async APIs carry complete sendability.
    @preconcurrency import MusicKit
    import SamadhiAudio
    import SamadhiDomain

    @MainActor
    final class AppleMusicPlaybackController: MusicPlaybackProviding {
        private let player = ApplicationMusicPlayer.shared
        private var continuation: AsyncStream<MusicPlaybackEvent>.Continuation?
        private var collection: MusicCollection?
        private var durations: [MusicTrackID: Double] = [:]
        private var songs: [MusicTrackID: Song] = [:]
        private var operationID: Int?
        private var stateTask: Task<Void, Never>?
        private var interruptionTask: Task<Void, Never>?
        private var routeTask: Task<Void, Never>?
        private var lastState: MusicPlaybackState?
        private var lastRate: Double?
        private var lastTrackID: MusicTrackID?
        private var pendingRateRequest: (id: Int, trackID: MusicTrackID)?
        private var preparedNextTrackID: MusicTrackID?
        private var latestSelectionID = 0

        func events() -> AsyncStream<MusicPlaybackEvent> {
            AsyncStream(bufferingPolicy: .bufferingNewest(128)) { continuation in
                self.continuation = continuation
                self.startMonitoring()
                continuation.onTermination = { [weak self] _ in
                    Task { @MainActor in
                        self?.stopMonitoring()
                    }
                }
            }
        }

        func prepare(
            _ collection: MusicCollection,
            startingAt trackID: MusicTrackID,
            operationID: Int
        ) async throws {
            guard collection.tracks.contains(where: { $0.id == trackID }) else {
                throw MusicPlaybackError.emptyCollection
            }

            var songs: [Song] = []
            var songsByID: [MusicTrackID: Song] = [:]
            var selectedSong: Song?
            var durations: [MusicTrackID: Double] = [:]
            for track in collection.tracks {
                var request = MusicCatalogResourceRequest<Song>(
                    matching: \.id,
                    equalTo: MusicItemID(track.id.rawValue)
                )
                request.limit = 1
                guard let song = try await request.response().items.first else {
                    throw AppleMusicPlaybackError.trackUnavailable(track.id)
                }
                songs.append(song)
                songsByID[track.id] = song
                if track.id == trackID { selectedSong = song }
                durations[track.id] = song.duration ?? track.durationSeconds
            }
            guard let selectedSong else { throw AppleMusicPlaybackError.trackUnavailable(trackID) }

            player.stop()
            player.state.playbackRate = 1
            player.queue = ApplicationMusicPlayer.Queue(for: songs, startingAt: selectedSong)
            self.collection = collection
            self.durations = durations
            self.songs = songsByID
            self.operationID = operationID
            lastState = nil
            lastRate = nil
            lastTrackID = trackID
            pendingRateRequest = nil
            preparedNextTrackID = nil
            latestSelectionID = 0
            continuation?.yield(.prepared(operationID: operationID, trackID: trackID))
        }

        func play(operationID: Int) async throws {
            guard isCurrent(operationID) else { return }
            try await player.play()
        }

        func pause(operationID: Int) {
            guard isCurrent(operationID) else { return }
            player.pause()
        }

        func resume(operationID: Int) async throws {
            try await play(operationID: operationID)
        }

        func skipToPrevious(operationID: Int) async throws {
            guard isCurrent(operationID) else { return }
            try await player.skipToPreviousEntry()
        }

        func skipToNext(operationID: Int) async throws {
            guard isCurrent(operationID) else { return }
            try applyPreparedNextIfNeeded()
            try await player.skipToNextEntry()
        }

        func prepareNext(
            trackID: MusicTrackID,
            operationID: Int,
            selectionID: Int
        ) async throws {
            guard isCurrent(operationID), songs[trackID] != nil else {
                throw MusicPlaybackError.notPrepared
            }
            guard selectionID >= latestSelectionID else { return }
            latestSelectionID = selectionID
            preparedNextTrackID = trackID
        }

        func clearPreparedNext(operationID: Int, selectionID: Int) {
            guard isCurrent(operationID), selectionID >= latestSelectionID else { return }
            latestSelectionID = selectionID
            preparedNextTrackID = nil
        }

        func setPlaybackRate(
            _ rate: Double,
            operationID: Int,
            requestID: Int,
            trackID: MusicTrackID
        ) {
            guard isCurrent(operationID),
                collection?.tracks.contains(where: { $0.id == trackID }) == true,
                currentTrackID == trackID
            else { return }
            let boundedRate = Double(Float(min(max(rate, 0.94), 1.06)))
            pendingRateRequest = (requestID, trackID)
            player.state.playbackRate = Float(boundedRate)
        }

        func stop(operationID: Int) {
            guard isCurrent(operationID) else { return }
            player.stop()
            collection = nil
            durations = [:]
            songs = [:]
            self.operationID = nil
            lastState = nil
            lastRate = nil
            lastTrackID = nil
            pendingRateRequest = nil
            preparedNextTrackID = nil
            latestSelectionID = 0
        }

        private func startMonitoring() {
            guard stateTask == nil else { return }

            stateTask = Task { [weak self] in
                while !Task.isCancelled {
                    guard let self else { return }
                    publishPlayerState()
                    try? await Task.sleep(for: .seconds(1))
                }
            }
            interruptionTask = Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(
                    named: AVAudioSession.interruptionNotification)
                {
                    guard !Task.isCancelled, let self else { return }
                    guard let operationID else { continue }
                    let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
                    let type = rawType.flatMap(AVAudioSession.InterruptionType.init(rawValue:))
                    if type == .began {
                        player.pause()
                        continuation?.yield(.interruptionBegan(operationID: operationID))
                    } else if type == .ended {
                        continuation?.yield(.interruptionEnded(operationID: operationID))
                    }
                }
            }
            routeTask = Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(
                    named: AVAudioSession.routeChangeNotification)
                {
                    guard !Task.isCancelled, let self else { return }
                    guard let operationID else { continue }
                    let rawReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt
                    let reason = rawReason.flatMap(AVAudioSession.RouteChangeReason.init(rawValue:))
                    switch reason {
                    case .oldDeviceUnavailable:
                        player.pause()
                        continuation?.yield(.routeLost(operationID: operationID))
                    case .newDeviceAvailable:
                        continuation?.yield(.routeRestored(operationID: operationID))
                    default:
                        break
                    }
                }
            }
        }

        private func stopMonitoring() {
            stateTask?.cancel()
            interruptionTask?.cancel()
            routeTask?.cancel()
            stateTask = nil
            interruptionTask = nil
            routeTask = nil
        }

        private func publishPlayerState() {
            guard let operationID, let collection else { return }

            if let currentTrackID,
                let duration = durations[currentTrackID],
                duration - player.playbackTime <= 8
            {
                try? applyPreparedNextIfNeeded()
            }

            let state = playbackState
            if state != lastState {
                lastState = state
                continuation?.yield(.stateChanged(operationID: operationID, state: state))
            }

            let rate = Double(player.state.playbackRate)
            if let request = pendingRateRequest {
                pendingRateRequest = nil
                lastRate = rate
                continuation?.yield(
                    .rateChanged(
                        operationID: operationID,
                        requestID: request.id,
                        trackID: request.trackID,
                        rate: rate
                    )
                )
            } else if rate != lastRate {
                lastRate = rate
                continuation?.yield(
                    .rateChanged(
                        operationID: operationID,
                        requestID: nil,
                        trackID: currentTrackID,
                        rate: rate
                    )
                )
            }

            guard let itemID = player.queue.currentEntry?.item?.id.rawValue else { return }
            let trackID = MusicTrackID(itemID)
            if trackID != lastTrackID {
                lastTrackID = trackID
                pendingRateRequest = nil
                preparedNextTrackID = nil
                continuation?.yield(.trackChanged(operationID: operationID, trackID: trackID))
            }
            guard let track = collection.tracks.first(where: { $0.id == trackID }) else { return }
            continuation?.yield(
                .progress(
                    operationID: operationID,
                    PlaybackProgress(
                        trackID: trackID,
                        elapsedSeconds: player.playbackTime,
                        durationSeconds: durations[trackID] ?? track.durationSeconds
                    )
                )
            )
        }

        private var playbackState: MusicPlaybackState {
            switch player.state.playbackStatus {
            case .playing:
                .playing
            case .paused:
                .paused
            default:
                .stopped
            }
        }

        private func isCurrent(_ operationID: Int) -> Bool {
            self.operationID == operationID && collection != nil
        }

        private func applyPreparedNextIfNeeded() throws {
            guard let trackID = preparedNextTrackID,
                let selectedSong = songs[trackID],
                let currentEntry = player.queue.currentEntry
            else { return }

            var entries = player.queue.entries
            guard let selectedIndex = entries.firstIndex(where: { $0.item?.id == selectedSong.id })
            else { throw AppleMusicPlaybackError.trackUnavailable(trackID) }
            let selectedEntry = entries.remove(at: selectedIndex)
            guard let currentIndex = entries.firstIndex(of: currentEntry) else {
                throw MusicPlaybackError.notPrepared
            }
            entries.insert(selectedEntry, at: min(currentIndex + 1, entries.endIndex))
            player.queue.entries = entries
            player.queue.currentEntry = currentEntry
            preparedNextTrackID = nil
        }

        private var currentTrackID: MusicTrackID? {
            guard let rawValue = player.queue.currentEntry?.item?.id.rawValue else {
                return lastTrackID
            }
            return MusicTrackID(rawValue)
        }
    }

    enum AppleMusicPlaybackError: Error, Sendable, Equatable {
        case trackUnavailable(MusicTrackID)
    }
#endif
