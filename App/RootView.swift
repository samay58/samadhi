import SamadhiDesign
import SamadhiDomain
import SwiftUI

struct RootView: View {
    // RootView owns the app's one presentation model. Screens receive rendered state and send intent back.
    @State private var runModel = RunPresentationModel()
    @State private var musicModel = MusicSelectionModel()
    #if DEBUG
        @State private var showingCoreDiagnostics = false
    #endif

    var body: some View {
        @Bindable var musicModel = musicModel

        rootContent
            .sheet(item: $musicModel.playlistSheet) { sheet in
                PlaylistPickerView(
                    presentation: sheet,
                    select: self.musicModel.selectPlaylist,
                    reload: self.musicModel.beginChoosing
                )
            }
            #if DEBUG
                .sheet(isPresented: $showingCoreDiagnostics) {
                    CoreLoopDiagnosticsView(presentation: runModel.coreLoopDiagnostics)
                }
            #endif
            .task {
                await self.musicModel.restore()
                installSelectedCollection()
            }
            .onChange(of: self.musicModel.selectedCollection) {
                installSelectedCollection()
            }
    }

    @ViewBuilder
    private var rootContent: some View {
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--music-feasibility") {
                MusicKitFeasibilityView()
            } else if let status = diagnosticFixtureStatus {
                CoreLoopDiagnosticsView(presentation: .fixture(status))
            } else if ProcessInfo.processInfo.arguments.contains("--core-diagnostics") {
                CoreLoopDiagnosticsView(presentation: runModel.coreLoopDiagnostics)
            } else {
                samadhiScreen
            }
        #else
            samadhiScreen
        #endif
    }

    private var samadhiScreen: some View {
        var state = runModel.viewState
        state.musicSelection = musicModel.presentation

        return ZStack(alignment: .topLeading) {
            SamadhiScreen(state: state) { action in
                send(action)
            }

            #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--apple-music-core-loop") {
                    CoreLoopDiagnosticsOverlay(
                        presentation: runModel.coreLoopDiagnostics,
                        open: { showingCoreDiagnostics = true }
                    )
                }
            #endif
        }
    }

    private func send(_ action: RunAction) {
        switch action {
        case .chooseMusic, .changeMusic:
            musicModel.beginChoosing()
        case .retryMusicImport:
            musicModel.retryLastImport()
        default:
            runModel.send(action)
        }
    }

    private func installSelectedCollection() {
        guard let collection = musicModel.selectedCollection?.adaptiveReadyCollection,
            !collection.tracks.isEmpty
        else { return }
        runModel = RunPresentationModel(musicCollection: collection)
    }

    #if DEBUG
        private var diagnosticFixtureStatus: TempoDiagnosticStatus? {
            let prefix = "--diagnostic-scenario="
            guard let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix(prefix) })
            else { return nil }
            return TempoDiagnosticStatus(rawValue: String(argument.dropFirst(prefix.count)))
        }
    #endif
}

#if DEBUG
    private struct CoreLoopDiagnosticsOverlay: View {
        let presentation: CoreLoopDiagnosticPresentation
        let open: () -> Void

        var body: some View {
            Button(action: open) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("What Samadhi saw")
                        .fontWeight(.semibold)
                    Text(presentation.status.label)
                    Text("Sent \(formatted(presentation.sentRate))")
                    Text("Apple Music \(formatted(presentation.reportedRate))")
                }
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(Color.black.opacity(0.82))
                .padding(8)
                .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.leading, 12)
            .padding(.top, 54)
            .accessibilityLabel("Open what Samadhi saw and changed")
        }

        private func formatted(_ value: Double?) -> String {
            value.map { String(format: "%.3f", $0) } ?? "--"
        }
    }
#endif
