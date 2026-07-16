#if DEBUG
    import AVFoundation
    import Foundation
    @preconcurrency import MusicKit
    import Observation
    import SamadhiAudio
    import UIKit

    struct FeasibilityTraceEntry: Codable, Identifiable, Sendable {
        let id: UUID
        let date: Date
        let event: String
        let detail: String
        let device: String
        let os: String
        let route: String
    }

    @MainActor
    @Observable
    final class MusicKitFeasibilityModel {
        private(set) var authorization = MusicAuthorization.currentStatus.description
        private(set) var playlists: [Playlist] = []
        private(set) var selectedPlaylistName: String?
        private(set) var tracks: [Track] = []
        private(set) var analyzableCoverage = "Not checked"
        private(set) var entries: [FeasibilityTraceEntry] = []
        private(set) var isWorking = false
        private(set) var currentTrack = "None"
        private(set) var outputRoute = "none"
        private(set) var requiresExplicitResume = false

        private let player = ApplicationMusicPlayer.shared
        private let tempoAnalyzer = LocalTempoAnalyzer()
        private let catalogResolver = AppleMusicCatalogResolver()
        private var monitoringTasks: [Task<Void, Never>] = []
        private var lastPlayerState = ""
        private var lastHeartbeat = Date.distantPast
        private var lastObservedRoute = "none"

        var traceURL: URL? {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appending(path: "samadhi-apple-music-feasibility.json")
        }

        func startMonitoring() {
            guard monitoringTasks.isEmpty else { return }
            player.stop()
            player.state.playbackRate = 1
            outputRoute = currentRoute
            lastObservedRoute = outputRoute
            record("harness_started", "MusicKit feasibility harness opened with playback reset")

            monitoringTasks.append(
                Task { [weak self] in
                    for await notification in NotificationCenter.default.notifications(
                        named: AVAudioSession.interruptionNotification)
                    {
                        guard !Task.isCancelled else { return }
                        self?.handleInterruption(notification)
                    }
                }
            )
            monitoringTasks.append(
                Task { [weak self] in
                    for await notification in NotificationCenter.default.notifications(
                        named: AVAudioSession.routeChangeNotification)
                    {
                        guard !Task.isCancelled else { return }
                        self?.handleRouteChange(notification)
                    }
                }
            )
            monitoringTasks.append(
                Task { [weak self] in
                    for await _ in NotificationCenter.default.notifications(
                        named: UIApplication.didEnterBackgroundNotification)
                    {
                        guard !Task.isCancelled else { return }
                        self?.record("app_backgrounded", self?.playerSnapshot ?? "unknown")
                    }
                }
            )
            monitoringTasks.append(
                Task { [weak self] in
                    for await _ in NotificationCenter.default.notifications(
                        named: UIApplication.didBecomeActiveNotification)
                    {
                        guard !Task.isCancelled else { return }
                        self?.record("app_became_active", self?.playerSnapshot ?? "unknown")
                    }
                }
            )
            monitoringTasks.append(
                Task { [weak self] in
                    while !Task.isCancelled {
                        guard let self else { return }
                        let state = playerStateSignature
                        if state != lastPlayerState {
                            lastPlayerState = state
                            record("player_state", playerSnapshot)
                        }
                        if player.state.playbackStatus == .playing,
                            Date().timeIntervalSince(lastHeartbeat) >= 15
                        {
                            lastHeartbeat = Date()
                            record("playback_heartbeat", playerSnapshot)
                        }
                        observeRoute()
                        try? await Task.sleep(for: .seconds(1))
                    }
                }
            )
        }

        func authorizeAndLoadPlaylists() {
            run {
                let status = await MusicAuthorization.request()
                self.authorization = status.description
                self.record("authorization", status.description)
                guard status == .authorized else { return }

                var request = MusicLibraryRequest<Playlist>()
                request.limit = 50
                let response = try await request.response()
                self.playlists = Array(response.items)
                self.record("playlists_loaded", "\(self.playlists.count) playlists")
            }
        }

        func testCatalogToken() {
            run {
                do {
                    var request = MusicCatalogSearchRequest(term: "tempo", types: [Song.self])
                    request.limit = 1
                    let response = try await request.response()
                    self.record(
                        "catalog_token_passed",
                        "Catalog returned \(response.songs.count) song"
                    )
                } catch {
                    self.record("catalog_token_failed", String(describing: error))
                }
            }
        }

        func select(_ playlist: Playlist) {
            run {
                let hydrated = try await playlist.with(.tracks)
                let tracks = Array(hydrated.tracks ?? [])
                self.selectedPlaylistName = hydrated.name
                self.tracks = tracks

                let sample = Array(tracks.prefix(10))
                var analyzable = 0
                for track in sample where await self.previewYieldsTempo(track) {
                    analyzable += 1
                }
                self.analyzableCoverage =
                    sample.isEmpty ? "No tracks" : "\(analyzable) of \(sample.count)"
                self.record(
                    "playlist_selected",
                    "\(hydrated.name); \(tracks.count) tracks; decoded preview coverage \(self.analyzableCoverage)"
                )
            }
        }

        func play() {
            run {
                guard !self.tracks.isEmpty else {
                    self.record("playback_blocked", "Select a playlist with tracks first")
                    return
                }
                self.player.queue = ApplicationMusicPlayer.Queue(for: self.tracks)
                try await self.player.play()
                self.requiresExplicitResume = false
                self.record(
                    "playback_started",
                    "Queue contains \(self.tracks.count) tracks; \(self.playerSnapshot)"
                )
            }
        }

        func setRate(_ rate: Float) {
            player.state.playbackRate = rate
            record("rate_written", "requested \(rate); reported \(player.state.playbackRate)")
        }

        func pause() {
            player.pause()
            record("pause", "Pause requested")
        }

        func resume() {
            run {
                try await self.player.play()
                self.requiresExplicitResume = false
                self.record("explicit_resume", "Resume requested; \(self.playerSnapshot)")
            }
        }

        func next() {
            run {
                let previousTrack = self.currentTrack
                try await self.player.skipToNextEntry()
                try? await Task.sleep(for: .seconds(1))
                self.updatePlayerPresentation()
                self.record(
                    "next_track_observed",
                    "\(previousTrack) -> \(self.currentTrack); \(self.playerSnapshot)"
                )
            }
        }

        func stop() {
            player.stop()
            record("stop", "Stop requested")
        }

        private func handleInterruption(_ notification: Notification) {
            let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            let type = rawType.flatMap(AVAudioSession.InterruptionType.init(rawValue:))
            let rawOptions = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: rawOptions)
            let rawReason = notification.userInfo?[AVAudioSessionInterruptionReasonKey] as? UInt

            if type == .began {
                player.pause()
                requiresExplicitResume = true
            }
            record(
                type == .began ? "interruption_began" : "interruption_ended",
                "type \(rawType.map(String.init) ?? "none"); reason \(rawReason.map(String.init) ?? "none"); options \(options.rawValue); explicit resume \(requiresExplicitResume)"
            )
        }

        private func handleRouteChange(_ notification: Notification) {
            let rawReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt
            let reason = rawReason.flatMap(AVAudioSession.RouteChangeReason.init(rawValue:))
            let previousRoute =
                (notification.userInfo?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription)
                .map(routeDescription) ?? "unknown"

            outputRoute = currentRoute
            lastObservedRoute = outputRoute
            if reason == .oldDeviceUnavailable {
                player.pause()
                requiresExplicitResume = true
                record(
                    "route_lost",
                    "\(previousRoute) -> \(outputRoute); paused; explicit resume required"
                )
                return
            }
            record(
                "route_changed",
                "reason \(routeChangeReasonName(reason)); \(previousRoute) -> \(outputRoute); explicit resume \(requiresExplicitResume)"
            )
        }

        private func observeRoute() {
            let observedRoute = currentRoute
            guard observedRoute != lastObservedRoute else { return }

            let previousRoute = lastObservedRoute
            lastObservedRoute = observedRoute
            outputRoute = observedRoute
            if previousRoute.contains("BluetoothA2DPOutput"),
                !observedRoute.contains("BluetoothA2DPOutput")
            {
                player.pause()
                requiresExplicitResume = true
                record(
                    "route_lost",
                    "\(previousRoute) -> \(observedRoute); paused; explicit resume required"
                )
            } else {
                record(
                    "route_observed",
                    "\(previousRoute) -> \(observedRoute); explicit resume \(requiresExplicitResume)"
                )
            }
        }

        private func routeChangeReasonName(_ reason: AVAudioSession.RouteChangeReason?) -> String {
            switch reason {
            case .newDeviceAvailable: "newDeviceAvailable"
            case .oldDeviceUnavailable: "oldDeviceUnavailable"
            case .categoryChange: "categoryChange"
            case .override: "override"
            case .wakeFromSleep: "wakeFromSleep"
            case .noSuitableRouteForCategory: "noSuitableRouteForCategory"
            case .routeConfigurationChange: "routeConfigurationChange"
            case .unknown: "unknown"
            case nil: "none"
            @unknown default: "unrecognized"
            }
        }

        private func run(_ operation: @escaping @MainActor () async throws -> Void) {
            guard !isWorking else { return }
            isWorking = true
            Task {
                defer { isWorking = false }
                do {
                    try await operation()
                } catch {
                    record("error", String(describing: error))
                }
            }
        }

        private func previewYieldsTempo(_ track: Track) async -> Bool {
            let resolvedTrack = await trackWithCatalogPreview(for: track)
            guard let url = resolvedTrack.previewAssets?.compactMap({ $0.url ?? $0.hlsURL }).first
            else {
                record("preview_unavailable", "\(track.title); id \(track.id); isrc \(track.isrc ?? "none")")
                return false
            }

            do {
                let localURL = try await localPreviewURL(for: url)
                defer { try? FileManager.default.removeItem(at: localURL) }
                guard let analysis = try await tempoAnalyzer.analyze(fileURL: localURL) else {
                    record("preview_tempo_rejected", track.title)
                    return false
                }
                record(
                    "preview_tempo_estimated",
                    "\(track.title); \(analysis.baseBPM.formatted(.number.precision(.fractionLength(1)))) BPM; confidence \(analysis.confidence.formatted(.number.precision(.fractionLength(2)))); version \(analysis.version)"
                )
                return true
            } catch {
                record("preview_error", "\(track.title); \(error)")
                return false
            }
        }

        private func localPreviewURL(for remoteURL: URL) async throws -> URL {
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

        private func trackWithCatalogPreview(for track: Track) async -> Track {
            if track.previewAssets?.isEmpty == false {
                record("preview_found_in_library", track.title)
                return track
            }

            let resolvedSong: Song?
            do {
                resolvedSong = try await catalogResolver.resolve(track)
            } catch {
                record("catalog_lookup_error", "\(track.title); id \(track.id); \(error)")
                return track
            }

            guard let resolvedSong else {
                record("catalog_lookup_empty", "\(track.title); id \(track.id); isrc \(track.isrc ?? "none")")
                return track
            }
            guard resolvedSong.previewAssets?.isEmpty == false else {
                record("catalog_preview_unavailable", "\(track.title); catalog id \(resolvedSong.id)")
                return .song(resolvedSong)
            }

            record("catalog_preview_resolved", "\(track.title); catalog id \(resolvedSong.id)")
            return .song(resolvedSong)
        }

        private func record(_ event: String, _ detail: String) {
            let device = UIDevice.current
            updatePlayerPresentation()
            entries.append(
                FeasibilityTraceEntry(
                    id: UUID(),
                    date: Date(),
                    event: event,
                    detail: detail,
                    device: device.model,
                    os: "\(device.systemName) \(device.systemVersion)",
                    route: currentRoute
                )
            )
            saveTrace()
        }

        private var currentRoute: String {
            routeDescription(AVAudioSession.sharedInstance().currentRoute)
        }

        private func routeDescription(_ route: AVAudioSessionRouteDescription) -> String {
            let outputs = route.outputs
            guard !outputs.isEmpty else { return "none" }
            return outputs.map { "\($0.portType.rawValue):\($0.portName)" }.joined(separator: ", ")
        }

        private var playerSnapshot: String {
            let entry = player.queue.currentEntry
            let title = entry?.title ?? "none"
            let id = entry?.id ?? "none"
            return
                "\(String(describing: player.state.playbackStatus)) @ \(player.state.playbackRate); \(title); id \(id); time \(String(format: "%.1f", player.playbackTime))"
        }

        private var playerStateSignature: String {
            let entryID = player.queue.currentEntry?.id ?? "none"
            return
                "\(String(describing: player.state.playbackStatus)) @ \(player.state.playbackRate); \(entryID)"
        }

        private func updatePlayerPresentation() {
            currentTrack = player.queue.currentEntry?.title ?? "None"
            outputRoute = currentRoute
        }

        private func saveTrace() {
            guard let traceURL else { return }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            guard let data = try? encoder.encode(entries) else { return }
            try? data.write(to: traceURL, options: .atomic)
        }
    }
#endif
