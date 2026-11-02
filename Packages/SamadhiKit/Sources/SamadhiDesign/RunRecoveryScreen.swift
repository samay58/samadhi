import SamadhiDomain
import SwiftUI

enum RunRecoveryKind {
    case motionPermission
    case audio(cause: RouteRecoveryCause, restored: Bool)
}

struct RunRecoveryScreen: View {
    let kind: RunRecoveryKind
    let send: @MainActor (RunAction) -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize = 52
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 38

    var body: some View {
        ScrollView {
            VStack(spacing: Space.x6) {
                Spacer(minLength: Space.x12)

                Image(systemName: symbol)
                    .font(.system(size: symbolSize, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.system(size: titleSize, weight: .medium, design: .serif))
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(message)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                    .frame(maxWidth: 330)

                actions
                    .frame(minHeight: 52)

                Spacer(minLength: Space.x12)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Space.x6)
            .background {
                Ellipse()
                    .fill(SamadhiColor.parchment.opacity(0.76))
                    .frame(width: 450, height: 480)
                    .blur(radius: 58)
            }
            .padding(.horizontal, Space.x4)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(identifier)
    }

    private var symbol: String {
        switch kind {
        case .motionPermission:
            "figure.run"
        case .audio(cause: .routeLost, _):
            "airpodspro"
        case .audio(cause: .interrupted, _):
            "pause.circle"
        case .audio(cause: .playbackFailed, _):
            "music.note"
        }
    }

    private var title: String {
        switch kind {
        case .motionPermission:
            "Motion access is off"
        case .audio(cause: .routeLost, _):
            "Headphones disconnected"
        case .audio(cause: .interrupted, _):
            "Music interrupted"
        case .audio(cause: .playbackFailed, _):
            "Music stopped"
        }
    }

    private var message: String {
        switch kind {
        case .motionPermission:
            "Samadhi uses step rhythm to adapt the music. You can change access in Settings or continue at a fixed rhythm."
        case .audio(cause: .routeLost, restored: true):
            "Your headphones are connected again. Resume when you’re ready."
        case .audio(cause: .routeLost, restored: false):
            "Music paused. Reconnect your headphones to continue, or end the run."
        case .audio(cause: .interrupted, restored: true):
            "The interruption is over. Resume when you’re ready."
        case .audio(cause: .interrupted, restored: false):
            "Music paused until the interruption ends."
        case .audio(cause: .playbackFailed, _):
            "Apple Music stopped responding. Try again, or end the run."
        }
    }

    private var identifier: String {
        switch kind {
        case .motionPermission:
            "permission-recovery"
        case .audio:
            "route-recovery"
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch kind {
        case .motionPermission:
            Button("Open Settings", action: openSettings)
                .buttonStyle(.glassProminent)
                .tint(SamadhiColor.clay)
                .accessibilityIdentifier("open-settings")
            Button("Use fixed rhythm", action: useFixedRhythm)
                .buttonStyle(.glass)
                .accessibilityIdentifier("use-fixed-rhythm")
        case let .audio(cause, restored: true):
            Button(cause == .playbackFailed ? "Try again" : "Resume", action: resumeRoute)
                .buttonStyle(.glassProminent)
                .tint(SamadhiColor.clay)
                .accessibilityIdentifier("route-resume")
            endRunButton
        case let .audio(cause, restored: false):
            Text(cause == .routeLost ? "Waiting for headphones" : "Waiting")
                .font(.callout)
                .foregroundStyle(SamadhiColor.ink.opacity(0.65))
            endRunButton
        }
    }

    // The route may never come back, so no recovery may trap the runner inside it.
    private var endRunButton: some View {
        Button("End run", action: endRun)
            .buttonStyle(.glass)
            .accessibilityIdentifier("route-end-run")
    }

    private func endRun() {
        send(.endRunFromRecovery)
    }

    private func openSettings() {
        send(.openSettings)
    }

    private func useFixedRhythm() {
        send(.useFixedRhythm)
    }

    private func resumeRoute() {
        send(.routeResume)
    }
}
