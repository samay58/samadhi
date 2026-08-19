import SamadhiDomain
import SwiftUI

// One instrument. Previous, Pause or Resume, and Next share a single glass capsule, so the bar
// reads as one object rather than three floating pills. Only the pressed region responds.
struct TransportControls: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 0) {
                TransportRegion(
                    role: .secondary,
                    systemImage: "backward.end.fill",
                    title: "Previous",
                    identifier: "previous-track",
                    action: .previous,
                    metrics: metrics,
                    send: send
                )

                TransportRegion(
                    role: .primary(isPaused: isPaused),
                    systemImage: isPaused ? "play.fill" : "pause.fill",
                    title: isPaused ? "Resume" : "Pause",
                    identifier: isPaused ? "resume-run" : "pause-run",
                    action: isPaused ? .resume : .pause,
                    metrics: metrics,
                    send: send
                )

                TransportRegion(
                    role: .secondary,
                    systemImage: "forward.end.fill",
                    title: "Skip",
                    identifier: "skip-track",
                    action: .skip,
                    metrics: metrics,
                    send: send
                )
            }
            .frame(height: metrics.barHeight)
            .clipShape(.capsule)
            .glassEffect(.regular, in: .capsule)
            .overlay {
                if metrics.increasedContrast {
                    Capsule()
                        .strokeBorder(SamadhiColor.ivory.opacity(0.36), lineWidth: 1)
                }
            }
        }
        // Symbols carry this bar, so growth is capped to keep three regions on one line.
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("transport-controls")
    }

    private var isPaused: Bool { state.phase == .paused }

    private var metrics: TransportMetrics {
        let accessibility = dynamicTypeSize.isAccessibilitySize
        let barHeight: CGFloat = accessibility ? 84 : 60
        return TransportMetrics(
            barHeight: barHeight,
            primaryMinWidth: accessibility ? 140 : 132,
            secondaryMinWidth: accessibility ? 78 : 72,
            keyDiameter: barHeight - 16,
            opticalNudge: accessibility ? 1.5 : 1,
            reduceMotion: reduceMotion || state.forceReduceMotion,
            increasedContrast: colorSchemeContrast == .increased || state.forceIncreasedContrast
        )
    }
}

// The resting Finish button and the armed hold control are the same view. Content and width
// change in place, so the two states can never be on screen together.
struct FinishControl: View {
    let armed: Bool
    let send: @MainActor (RunAction) -> Void
    let reduceMotionOverride: Bool
    let increasedContrastOverride: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var pressing = false
    @State private var completed = false

    var body: some View {
        Button(action: armFinish) {
            Text(armed ? "Hold to finish" : "Finish")
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .contentTransition(.identity)
        }
        .buttonStyle(
            FinishControlStyle(
                armed: armed,
                filled: pressing || completed,
                reduceMotion: effectiveReduceMotion,
                increasedContrast: effectiveIncreasedContrast,
                metrics: metrics
            )
        )
        // One gesture chain for both states. The armed guard leaves the resting tap alone.
        .onLongPressGesture(
            minimumDuration: FinishHold.durationSeconds,
            maximumDistance: 24,
            perform: completeHold,
            onPressingChanged: updateHold
        )
        .accessibilityIdentifier(armed ? "hold-to-finish" : "finish-run")
        .accessibilityHint(
            armed
                ? "Press and hold to end the run"
                : "Changes to a hold control so the run cannot end accidentally"
        )
        .accessibilityActions {
            if armed {
                Button("Finish run", action: finishWithAccessibilityAction)
            }
        }
        .onChange(of: armed) { _, isArmed in
            guard !isArmed else { return }
            pressing = false
            completed = false
        }
        // Bounded growth keeps the hold control on one line and inside the screen at every size.
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    private var metrics: FinishMetrics {
        let accessibility = dynamicTypeSize.isAccessibilitySize
        return FinishMetrics(
            horizontalPadding: armed ? 30 : 22,
            verticalPadding: armed ? 12 : 8,
            visibleHeight: armed ? (accessibility ? 58 : 46) : (accessibility ? 44 : 34)
        )
    }

    private var effectiveReduceMotion: Bool {
        reduceMotion || reduceMotionOverride
    }

    private var effectiveIncreasedContrast: Bool {
        colorSchemeContrast == .increased || increasedContrastOverride
    }

    private func armFinish() {
        guard !armed else { return }
        send(.finishTapped)
    }

    private func updateHold(_ isPressing: Bool) {
        guard armed else { return }
        pressing = isPressing
        send(isPressing ? .finishHoldBegan : .finishHoldCancelled)
    }

    private func completeHold() {
        guard armed else { return }
        completed = true
        send(.finishHoldCompleted)
    }

    private func finishWithAccessibilityAction() {
        send(.finishHoldBegan)
        send(.finishHoldCompleted)
    }
}

private struct TransportMetrics {
    let barHeight: CGFloat
    let primaryMinWidth: CGFloat
    let secondaryMinWidth: CGFloat
    let keyDiameter: CGFloat
    let opticalNudge: CGFloat
    let reduceMotion: Bool
    let increasedContrast: Bool
}

private struct FinishMetrics {
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let visibleHeight: CGFloat
}

private struct TransportRegion: View {
    enum Role: Equatable {
        case primary(isPaused: Bool)
        case secondary
    }

    let role: Role
    let systemImage: String
    let title: String
    let identifier: String
    let action: RunAction
    let metrics: TransportMetrics
    let send: @MainActor (RunAction) -> Void

    var body: some View {
        Button(action: performAction) {
            symbol
        }
        .buttonStyle(
            TransportRegionStyle(
                minWidth: isPrimary ? metrics.primaryMinWidth : metrics.secondaryMinWidth,
                reduceMotion: metrics.reduceMotion
            )
        )
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier)
    }

    @ViewBuilder
    private var symbol: some View {
        switch role {
        case let .primary(isPaused):
            // The raised key names the primary action without a divider and carries the paused state.
            ZStack {
                Circle()
                    .fill(SamadhiColor.ivory.opacity(keyFill(isPaused: isPaused)))
                    .overlay {
                        Circle()
                            .strokeBorder(
                                SamadhiColor.ivory.opacity(metrics.increasedContrast ? 0.46 : 0.24),
                                lineWidth: 0.75
                            )
                    }
                    .frame(width: metrics.keyDiameter, height: metrics.keyDiameter)
                glyph(font: .title2.weight(.semibold))
            }
        case .secondary:
            glyph(font: .title3.weight(.medium))
        }
    }

    private func glyph(font: Font) -> some View {
        Image(systemName: systemImage)
            .font(font)
            .foregroundStyle(SamadhiColor.ivory)
            // play.fill sits left of center inside its own box. This puts it back on the optical axis.
            .offset(x: systemImage == "play.fill" ? metrics.opticalNudge : 0)
    }

    private func keyFill(isPaused: Bool) -> Double {
        if metrics.increasedContrast { return isPaused ? 0.34 : 0.24 }
        return isPaused ? 0.2 : 0.12
    }

    private var isPrimary: Bool {
        if case .primary = role { return true }
        return false
    }

    private func performAction() {
        send(action)
    }
}

private struct TransportRegionStyle: ButtonStyle {
    let minWidth: CGFloat
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .frame(minWidth: minWidth, maxWidth: .infinity, maxHeight: .infinity)
            .background(SamadhiColor.ink.opacity(configuration.isPressed ? 0.08 : 0))
            .contentShape(.rect)
            .animation(
                reduceMotion ? nil : .easeOut(duration: MotionToken.press),
                value: configuration.isPressed
            )
    }
}

private struct FinishControlStyle: ButtonStyle {
    let armed: Bool
    let filled: Bool
    let reduceMotion: Bool
    let increasedContrast: Bool
    let metrics: FinishMetrics

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(SamadhiColor.ivory.opacity(labelOpacity))
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .frame(minHeight: metrics.visibleHeight)
            // Arming swaps the word and the width in one frame. Crossfading them showed both
            // words and both widths at once, which is the overlap this control used to have.
            .transaction { $0.animation = nil }
            // Progress sits behind the label inside the same capsule clip, so it moves and clips
            // with the pressed shape and can never leave the border.
            .background(alignment: .leading) { progress }
            .clipShape(.capsule)
            .glassEffect(armed ? .regular.tint(SamadhiColor.clay.opacity(0.45)) : .identity, in: .capsule)
            .overlay {
                Capsule().strokeBorder(strokeColor, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(
                reduceMotion ? nil : .easeOut(duration: MotionToken.press),
                value: configuration.isPressed
            )
            .frame(minHeight: 44)
            .contentShape(.capsule)
    }

    @ViewBuilder
    private var progress: some View {
        if armed {
            GeometryReader { proxy in
                SamadhiColor.clay
                    .opacity(increasedContrast ? 1 : 0.92)
                    .frame(width: filled ? proxy.size.width : 0)
            }
            // Filling shares one duration with the reducer. Release resets with no animation.
            .animation(filled ? .linear(duration: FinishHold.durationSeconds) : nil, value: filled)
        }
    }

    private var labelOpacity: Double {
        if armed { return 1 }
        return increasedContrast ? 1 : 0.86
    }

    private var strokeColor: Color {
        if armed { return SamadhiColor.ivory.opacity(increasedContrast ? 0.62 : 0.34) }
        return SamadhiColor.ivory.opacity(increasedContrast ? 0.58 : 0.24)
    }
}
