#if DEBUG
    import AVFoundation
    import Foundation
    @preconcurrency import MusicKit
    import Observation
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

        private let player = ApplicationMusicPlayer.shared
        private var monitoringTasks: [Task<Void, Never>] = []
        private var lastPlayerState = ""

        var traceURL: URL? {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appending(path: "samadhi-apple-music-feasibility.json")
        }

        func startMonitoring() {
            guard monitoringTasks.isEmpty else { return }
            record("harness_started", "MusicKit feasibility harness opened")

            monitoringTasks.append(
                Task { [weak self] in
                    for await _ in NotificationCenter.default.notifications(
                        named: AVAudioSession.interruptionNotification)
                    {
                        guard !Task.isCancelled else { return }
                        self?.record("audio_interruption", "Audio session interruption observed")
                    }
                }
            )
            monitoringTasks.append(
                Task { [weak self] in
                    for await _ in NotificationCenter.default.notifications(
                        named: AVAudioSession.routeChangeNotification)
                    {
                        guard !Task.isCancelled else { return }
                        self?.record("route_changed", "Audio route notification observed")
                    }
                }
            )
            monitoringTasks.append(
                Task { [weak self] in
                    while !Task.isCancelled {
                        guard let self else { return }
                        let snapshot =
                            "\(String(describing: player.state.playbackStatus)) @ \(player.state.playbackRate)"
                        if snapshot != lastPlayerState {
                            lastPlayerState = snapshot
                            record("player_state", snapshot)
                        }
                        try? await Task.sleep(for: .milliseconds(500))
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

        func select(_ playlist: Playlist) {
            run {
                let hydrated = try await playlist.with(.tracks)
                let tracks = Array(hydrated.tracks ?? [])
                self.selectedPlaylistName = hydrated.name
                self.tracks = tracks

                let sample = Array(tracks.prefix(10))
                var analyzable = 0
                for track in sample where await self.previewYieldsPCM(track) {
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
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)
                self.player.queue = ApplicationMusicPlayer.Queue(for: self.tracks)
                try await self.player.play()
                self.record("playback_started", "Queue contains \(self.tracks.count) tracks")
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
                self.record("resume", "Resume requested")
            }
        }

        func next() {
            run {
                try await self.player.skipToNextEntry()
                self.record("next_track", "Skip requested")
            }
        }

        func stop() {
            player.stop()
            record("stop", "Stop requested")
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

        private func previewYieldsPCM(_ track: Track) async -> Bool {
            guard let url = track.previewAssets?.compactMap({ $0.url ?? $0.hlsURL }).first else {
                record("preview_unavailable", track.title)
                return false
            }

            do {
                let asset = AVURLAsset(url: url)
                guard try await asset.load(.isPlayable),
                    let audioTrack = try await asset.loadTracks(withMediaType: .audio).first
                else {
                    record("preview_unreadable", track.title)
                    return false
                }

                let reader = try AVAssetReader(asset: asset)
                let output = AVAssetReaderTrackOutput(
                    track: audioTrack,
                    outputSettings: [
                        AVFormatIDKey: kAudioFormatLinearPCM,
                        AVLinearPCMBitDepthKey: 32,
                        AVLinearPCMIsFloatKey: true,
                        AVLinearPCMIsNonInterleaved: false,
                    ]
                )
                guard reader.canAdd(output) else {
                    record("preview_undecodable", track.title)
                    return false
                }
                reader.add(output)
                guard reader.startReading() else {
                    record("preview_undecodable", track.title)
                    return false
                }

                let yieldedPCM = output.copyNextSampleBuffer() != nil
                reader.cancelReading()
                record(yieldedPCM ? "preview_decoded" : "preview_empty", track.title)
                return yieldedPCM
            } catch {
                record("preview_error", "\(track.title); \(error)")
                return false
            }
        }

        private func record(_ event: String, _ detail: String) {
            let device = UIDevice.current
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
            let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
            guard !outputs.isEmpty else { return "none" }
            return outputs.map { "\($0.portType.rawValue):\($0.portName)" }.joined(separator: ", ")
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
