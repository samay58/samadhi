import SamadhiDesign
import SamadhiDomain
import SwiftUI

struct RootView: View {
    // RootView owns the app's one presentation model. Screens receive rendered state and send intent back.
    @State private var runModel = RunPresentationModel()
    @State private var musicModel = MusicSelectionModel()

    var body: some View {
        @Bindable var musicModel = musicModel

        rootContent
            .sheet(item: $musicModel.playlistSheet) { sheet in
                PlaylistPickerView(
                    presentation: sheet,
                    select: self.musicModel.selectPlaylist
                )
            }
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
                    CoreLoopDiagnosticsView(
                        cadenceSPM: runModel.viewState.cadenceSPM,
                        targetRate: runModel.state.session?.adaptationState.targetRate,
                        appliedRate: runModel.state.session?.appliedPlaybackRate,
                        awaitingFeedback: runModel.state.session?.pendingRateRequestID != nil
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
}

#if DEBUG
    private struct CoreLoopDiagnosticsView: View {
        let cadenceSPM: Int?
        let targetRate: Double?
        let appliedRate: Double?
        let awaitingFeedback: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text("Core loop")
                    .fontWeight(.semibold)
                Text("cadence \(cadenceSPM.map(String.init) ?? "--")")
                Text("target \(formatted(targetRate))")
                Text("applied \(formatted(appliedRate))")
                Text(awaitingFeedback ? "feedback pending" : "feedback settled")
            }
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(Color.black.opacity(0.82))
            .padding(8)
            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 8))
            .padding(.leading, 12)
            .padding(.top, 54)
            .allowsHitTesting(false)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Core loop diagnostics, cadence \(cadenceSPM.map(String.init) ?? "unavailable"), "
                    + "target rate \(formatted(targetRate)), applied rate \(formatted(appliedRate))"
            )
        }

        private func formatted(_ value: Double?) -> String {
            value.map { String(format: "%.3f", $0) } ?? "--"
        }
    }
#endif
