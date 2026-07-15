import SwiftUI

struct TransportControls: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    var body: some View {
        HStack(spacing: Space.x2) {
            TransportButton(
                title: "Previous",
                systemImage: "backward.end.fill",
                action: .previous,
                identifier: "previous-track",
                send: send
            )
            TransportButton(
                title: state.phase == .paused ? "Resume" : "Pause",
                systemImage: state.phase == .paused ? "play.fill" : "pause.fill",
                action: state.phase == .paused ? .resume : .pause,
                identifier: state.phase == .paused ? "resume-run" : "pause-run",
                send: send
            )
            TransportButton(
                title: "Skip",
                systemImage: "forward.end.fill",
                action: .skip,
                identifier: "skip-track",
                send: send
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("transport-controls")
    }
}

struct HoldToFinishControl: View {
    let send: @MainActor (RunAction) -> Void
    let reduceMotionOverride: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var pressing = false

    var body: some View {
        Button {
        } label: {
            Text("Hold to finish")
                .font(.body.weight(.semibold))
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .frame(width: dynamicTypeSize.isAccessibilitySize ? 220 : 190, height: 54)
        }
        .background(alignment: .leading) {
            Capsule()
                .fill(SamadhiColor.clay.opacity(0.56))
                .scaleEffect(x: pressing ? 1 : 0, y: 1, anchor: .leading)
                .animation(
                    reduceMotion || reduceMotionOverride ? nil : .linear(duration: 0.9),
                    value: pressing
                )
        }
        .buttonStyle(.glassProminent)
        .tint(SamadhiColor.clay)
        // The visible fill mirrors the reducer's hold window. Hold IDs make duplicate completions harmless.
        .onLongPressGesture(
            minimumDuration: 0.9,
            maximumDistance: 24,
            perform: completeHold,
            onPressingChanged: updateHold
        )
        .accessibilityIdentifier("hold-to-finish")
        .accessibilityHint("Press and hold to end the run")
        .accessibilityAction(named: "Finish run", finishWithAccessibilityAction)
    }

    private func updateHold(_ isPressing: Bool) {
        pressing = isPressing
        send(isPressing ? .finishHoldBegan : .finishHoldCancelled)
    }

    private func completeHold() {
        send(.finishHoldCompleted)
    }

    private func finishWithAccessibilityAction() {
        send(.finishHoldBegan)
        send(.finishHoldCompleted)
    }
}

private struct TransportButton: View {
    let title: String
    let systemImage: String
    let action: RunAction
    let identifier: String
    let send: @MainActor (RunAction) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: performAction) {
            if dynamicTypeSize.isAccessibilitySize {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 58)
            } else {
                VStack(spacing: Space.x1) {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, minHeight: 58)
            }
        }
        .buttonStyle(.glass)
        .tint(SamadhiColor.ivory.opacity(0.12))
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier)
    }

    private func performAction() {
        send(action)
    }
}
