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
            "headphones"
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
        case .audio(cause: .routeLost, restored: true):
            "Headphones connected"
        case .audio(cause: .routeLost, restored: false):
            "Headphones disconnected"
        case .audio(cause: .interrupted, restored: true):
            "Interruption over"
        case .audio(cause: .interrupted, restored: false):
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
            "Resume when you’re ready."
        case .audio(cause: .routeLost, restored: false):
            "Music paused. Reconnect your headphones to continue, or end the run."
        case .audio(cause: .interrupted, restored: true):
            "Resume when you’re ready."
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
            primaryButton("Open Settings", identifier: "open-settings", action: openSettings)
            quietButton("Use fixed rhythm", identifier: "use-fixed-rhythm", action: useFixedRhythm)
        case let .audio(cause, restored: true):
            primaryButton(
                cause == .playbackFailed ? "Try again" : "Resume",
                identifier: "route-resume",
                action: resumeRoute
            )
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
        quietButton("End run", identifier: "route-end-run", action: endRun)
    }

    // A recovery is often read mid-stride, so the way back is the same large target as Start.
    private func primaryButton(
        _ title: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(SamadhiColor.ivory)
                .padding(.horizontal, Space.x4)
                .frame(minWidth: 176, minHeight: 58)
        }
        .buttonStyle(.glassProminent)
        .tint(SamadhiColor.clay)
        .accessibilityIdentifier(identifier)
    }

    private func quietButton(
        _ title: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                .frame(minWidth: 176, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
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
