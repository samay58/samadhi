import SamadhiDomain
import SwiftUI

// Transport is three separate Liquid Glass circles in one container, not a bar. Each control is its
// own lens over the field, so the material reads as glass instead of a slab, and interactive glass
// gives every press the system's own bounce and shimmer. The primary circle is larger and tinted so
// the hierarchy is clear at arm's length.
struct TransportControls: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GlassEffectContainer(spacing: metrics.blendSpacing) {
            HStack(spacing: metrics.gap) {
                TransportRegion(
                    role: .secondary,
                    systemImage: "backward.fill",
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
                    systemImage: "forward.fill",
                    title: "Skip",
                    identifier: "skip-track",
                    action: .skip,
                    metrics: metrics,
                    send: send
                )
            }
        }
        // Symbols carry this row, so growth is capped to keep three controls on one line.
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("transport-controls")
    }

    private var isPaused: Bool { state.phase == .paused }

    private var metrics: TransportMetrics {
        let accessibility = dynamicTypeSize.isAccessibilitySize
        return TransportMetrics(
            primaryDiameter: accessibility ? 96 : 88,
            secondaryDiameter: accessibility ? 74 : 68,
            gap: accessibility ? 16 : 20,
            blendSpacing: 6,
            opticalNudge: accessibility ? 2.5 : 2,
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
            horizontalPadding: armed ? 30 : 26,
            verticalPadding: armed ? 12 : 9,
            visibleHeight: armed ? (accessibility ? 58 : 46) : (accessibility ? 46 : 38)
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
    let primaryDiameter: CGFloat
    let secondaryDiameter: CGFloat
    let gap: CGFloat
    let blendSpacing: CGFloat
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
            glyph
                .frame(width: diameter, height: diameter)
                .contentShape(.circle)
        }
        .buttonStyle(TransportRegionStyle(reduceMotion: metrics.reduceMotion))
        .glassEffect(glass, in: .circle)
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier)
    }

    private var glyph: some View {
        Image(systemName: systemImage)
            .font(.system(size: diameter * (isPrimary ? 0.36 : 0.34), weight: isPrimary ? .bold : .semibold))
            .foregroundStyle(glyphColor)
            // play.fill sits left of center inside its own box. This puts it back on the optical axis.
            .offset(x: systemImage == "play.fill" ? metrics.opticalNudge : 0)
    }

    // The primary lens carries a light ivory tint so it reads as the brighter, nearer object; the
    // secondaries stay clear glass so the field shows through them.
    private var glass: Glass {
        if isPrimary {
            return .regular.tint(SamadhiColor.ivory.opacity(metrics.increasedContrast ? 0.92 : 0.5)).interactive()
        }
        return .regular.interactive()
    }

    private var glyphColor: Color {
        if isPrimary { return SamadhiColor.ink }
        return SamadhiColor.ivory.opacity(metrics.increasedContrast ? 1 : 0.92)
    }

    private var diameter: CGFloat {
        isPrimary ? metrics.primaryDiameter : metrics.secondaryDiameter
    }

    private var isPrimary: Bool {
        if case .primary = role { return true }
        return false
    }

    private func performAction() {
        send(action)
    }
}

// A press has to be seen as well as felt. Interactive glass brightens and lenses on touch; on top
// of that the whole control compresses on a quick spring and springs back on release, so the finger
// gets an answer the moment it lands, not only when the action fires. Reduce Motion swaps the scale
// for a plain dim with no animation.
private struct TransportRegionStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.88 : 1)
            .brightness(configuration.isPressed ? 0.06 : 0)
            .opacity(configuration.isPressed && reduceMotion ? 0.72 : 1)
            .animation(
                reduceMotion ? nil : .spring(response: 0.22, dampingFraction: 0.55),
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
        return SamadhiColor.ivory.opacity(increasedContrast ? 0.58 : 0.3)
    }
}
