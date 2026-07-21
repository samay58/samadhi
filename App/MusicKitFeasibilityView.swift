#if DEBUG
    import Foundation
    import MusicKit
    import SwiftUI

    struct MusicKitFeasibilityView: View {
        @State private var model = MusicKitFeasibilityModel()

        var body: some View {
            NavigationStack {
                List {
                    Section("Gate state") {
                        LabeledContent("Authorization", value: model.authorization)
                        LabeledContent("Analyzed previews", value: model.analyzableCoverage)
                        LabeledContent("Output route", value: model.outputRoute)
                        LabeledContent("Current track", value: model.currentTrack)
                        if model.requiresExplicitResume {
                            Label("Explicit resume required", systemImage: "pause.circle.fill")
                                .foregroundStyle(.orange)
                        }
                        if let name = model.selectedPlaylistName {
                            LabeledContent("Playlist", value: name)
                            LabeledContent("Tracks", value: "\(model.tracks.count)")
                        }
                        Button("Authorize and load playlists") {
                            model.authorizeAndLoadPlaylists()
                        }
                        .disabled(model.isWorking)
                        Button("Test catalog token") {
                            model.testCatalogToken()
                        }
                        .disabled(model.isWorking)
                    }

                    Section("Library playlists") {
                        if model.playlists.isEmpty {
                            Text("Authorize first, then choose one playlist with at least ten tracks.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(model.playlists, id: \.id) { playlist in
                                Button(playlist.name) {
                                    model.select(playlist)
                                }
                            }
                        }
                    }

                    Section("Playback") {
                        Button("Play selected playlist") { model.play() }
                            .disabled(model.tracks.isEmpty || model.isWorking)
                        HStack {
                            rateButton(0.94)
                            rateButton(1)
                            rateButton(1.06)
                        }
                        HStack {
                            Button("Pause") { model.pause() }
                            Button("Resume") { model.resume() }
                            Button("Next") { model.next() }
                            Button("Stop") { model.stop() }
                        }
                    }

                    Section("Felt change") {
                        Text(
                            "Start playback, place the phone face down, then run one comparison. Each sample lasts eight seconds."
                        )
                        Button("Run blinded 0.92 / 1.08 comparison") {
                            model.runPerceptibilityComparison()
                        }
                        .disabled(model.tracks.isEmpty || model.isWorking)
                        LabeledContent("Result", value: model.perceptibilityStatus)
                        if model.awaitingPerceptibilityAnswer {
                            HStack {
                                Button("First was faster") {
                                    model.recordPerceptibilityAnswer(secondWasFaster: false)
                                }
                                Button("Second was faster") {
                                    model.recordPerceptibilityAnswer(secondWasFaster: true)
                                }
                            }
                        }
                        HStack {
                            rateButton(0.92)
                            rateButton(1)
                            rateButton(1.08)
                        }
                        Text("Try 0.90 and 1.10 only if these endpoints remain clean.")
                            .foregroundStyle(.secondary)
                        HStack {
                            rateButton(0.90)
                            rateButton(1)
                            rateButton(1.10)
                        }
                    }

                    Section("Evidence") {
                        Text(
                            "Listen at all three rates. Lock the screen for five minutes while music plays. Return and use Next. Trigger one interruption. Disconnect and reconnect the headphones while stationary, then use explicit Resume."
                        )
                        if let url = model.traceURL {
                            ShareLink(item: url) {
                                Label("Share trace", systemImage: "square.and.arrow.up")
                            }
                        }
                        ForEach(model.entries.reversed()) { entry in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(entry.event)
                                    .font(.headline)
                                Text(entry.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("MusicKit gate")
            }
            .task {
                model.startMonitoring()
                if ProcessInfo.processInfo.arguments.contains("--catalog-token-gate") {
                    model.testCatalogToken()
                }
            }
        }

        private func rateButton(_ rate: Float) -> some View {
            Button(String(format: "%.2f", rate)) {
                model.setRate(rate)
            }
            .buttonStyle(.bordered)
        }
    }
#endif
