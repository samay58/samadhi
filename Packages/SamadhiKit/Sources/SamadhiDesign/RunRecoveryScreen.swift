import SwiftUI

enum RunRecoveryKind {
    case motionPermission
    case audioRoute(restored: Bool)
}

struct RunRecoveryScreen: View {
    let kind: RunRecoveryKind
    let send: @MainActor (RunAction) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Space.x6) {
                Spacer(minLength: Space.x12)

                Image(systemName: symbol)
                    .font(.system(size: 52, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.system(size: 38, weight: .medium, design: .serif))
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
        case .audioRoute:
            "airpodspro"
        }
    }

    private var title: String {
        switch kind {
        case .motionPermission:
            "Motion access is off"
        case .audioRoute:
            "Headphones disconnected"
        }
    }

    private var message: String {
        switch kind {
        case .motionPermission:
            "Samadhi uses step rhythm to adapt the music. You can change access in Settings or continue at a fixed rhythm."
        case .audioRoute(restored: true):
            "Your headphones are connected again. Resume when you’re ready."
        case .audioRoute(restored: false):
            "Music paused. Reconnect your headphones to continue safely."
        }
    }

    private var identifier: String {
        switch kind {
        case .motionPermission:
            "permission-recovery"
        case .audioRoute:
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
        case .audioRoute(restored: true):
            Button("Resume", action: resumeRoute)
                .buttonStyle(.glassProminent)
                .tint(SamadhiColor.clay)
                .accessibilityIdentifier("route-resume")
        case .audioRoute(restored: false):
            Text("Waiting for headphones")
                .font(.callout)
                .foregroundStyle(SamadhiColor.ink.opacity(0.65))
        }
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
