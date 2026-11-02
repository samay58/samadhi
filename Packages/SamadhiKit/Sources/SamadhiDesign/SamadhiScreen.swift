import SwiftUI

public struct SamadhiScreen: View {
    private let state: RunViewState
    private let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(state: RunViewState, send: @escaping @MainActor (RunAction) -> Void) {
        self.state = state
        self.send = send
    }

    public var body: some View {
        ZStack {
            // Background and foreground route independently so the atmosphere stays continuous across phases.
            atmosphere
            content
        }
        .foregroundStyle(foregroundColor)
        .animation(effectiveReduceMotion ? nil : .smooth(duration: MotionToken.transition), value: state.phase)
        .animation(effectiveReduceMotion ? nil : .smooth(duration: MotionToken.control), value: state.controlsVisible)
    }

    @ViewBuilder
    private var content: some View {
        // This switch only chooses a screen. RunReducer owns every product transition.
        switch state.phase {
        case .ready:
            ReadyScreen(state: state, send: send)
        case .permissionRecovery:
            RunRecoveryScreen(kind: .motionPermission, send: send)
        case let .routeRecovery(cause, restored):
            RunRecoveryScreen(kind: .audio(cause: cause, restored: restored), send: send)
        case let .summary(summary):
            RunSummaryScreen(summary: summary, send: send)
        case .preparing, .acquiring, .running, .paused, .confirmingFinish, .finishing:
            ActiveRunScreen(state: state, send: send)
        }
    }

    private var atmosphere: some View {
        Group {
            switch state.phase {
            case .ready:
                FluidMusicField(
                    mode: .ready,
                    usesCollectionPalette: state.hasArtwork,
                    reduceMotionOverride: state.forceReduceMotion,
                    animates: true,
                    contourLines: state.musicSelection.contourLines,
                    warmth: state.musicSelection.fieldWarmth,
                    isSettled: state.musicSelection.isReadyToRun,
                    leavesClearing: !dynamicTypeSize.isAccessibilitySize
                )
            case .permissionRecovery, .routeRecovery, .summary:
                FluidMusicField(
                    mode: .ready,
                    usesCollectionPalette: false,
                    reduceMotionOverride: true,
                    animates: false,
                    contourLines: state.musicSelection.contourLines
                )
            default:
                FluidMusicField(
                    mode: .running,
                    usesCollectionPalette: state.hasArtwork,
                    reduceMotionOverride: state.forceReduceMotion,
                    animates: state.phase == .preparing || state.phase == .acquiring,
                    contourLines: state.musicSelection.contourLines
                )
            }
        }
        .ignoresSafeArea()
    }

    private var foregroundColor: Color {
        switch state.phase {
        case .ready, .permissionRecovery, .routeRecovery, .summary:
            SamadhiColor.ink
        default:
            SamadhiColor.ivory
        }
    }

    private var effectiveReduceMotion: Bool {
        reduceMotion || state.forceReduceMotion
    }
}
