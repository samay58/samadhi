import SamadhiDomain
import SwiftUI

struct RhythmControl: View {
    let state: RunViewState
    let mode: ApertureMode
    let size: CGFloat
    let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @State private var dragAutomaticBaseBPM: Int?
    @State private var dragOriginBPM: Int?
    @State private var frozenDisplayBPM: Int?
    @State private var rotaryTracker = RotaryDetentTracker()
    @State private var wheelIndicatorAngle: Double?

    var body: some View {
        VStack(spacing: Space.x3) {
            apertureSurface

            if state.rhythmControl.isVisible {
                adjustmentRow
                    .transition(.opacity)
            }
        }
        .animation(
            effectiveReduceMotion ? nil : .easeOut(duration: MotionToken.control), value: state.rhythmControl.isVisible
        )
        // This compact direct-manipulation surface stays legible at 200 percent while VoiceOver carries full detail.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    @ViewBuilder
    private var apertureSurface: some View {
        if state.rhythmControl.isVisible {
            ZStack {
                aperture
                    .accessibilityHidden(true)

                readout
                    .transition(.opacity)

                wheelIndicator
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(adjustmentGesture)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(accessibilityValue)
            .accessibilityHint("Swipe up or down to adjust by one beat per minute")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    send(.adjustRhythmControl(1))
                case .decrement:
                    send(.adjustRhythmControl(-1))
                @unknown default:
                    break
                }
            }
            .accessibilityIdentifier("rhythm-dial")
        } else {
            Button(action: reveal) {
                aperture
                    .frame(width: size, height: size)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Tempo control")
            .accessibilityHint("Opens automatic and manual tempo adjustment")
            .accessibilityIdentifier("tempo-control")
        }
    }

    private var aperture: some View {
        TempoAperture(
            mode: mode,
            tempoBPM: state.rhythmControl.appliedBPM,
            progress: state.trackProgress,
            reduceMotionOverride: state.forceReduceMotion,
            increasedContrastOverride: state.forceIncreasedContrast
        )
    }

    private var readout: some View {
        VStack(spacing: Space.x1) {
            Text(modeLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SamadhiColor.ivory.opacity(0.88))

            HStack(alignment: .firstTextBaseline, spacing: Space.x1) {
                Text(displayBPM.map(String.init) ?? "--")
                    .font(.system(size: 46, weight: .medium, design: .rounded).monospacedDigit())
                Text("BPM")
                    .font(.caption.weight(.bold))
            }

            Text(feedbackLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(
                    state.rhythmControl.isAtLimit
                        ? SamadhiColor.ivory
                        : SamadhiColor.ivory.opacity(0.76)
                )
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var wheelIndicator: some View {
        if let wheelIndicatorAngle {
            Capsule()
                .fill(SamadhiColor.ivory.opacity(0.94))
                .frame(width: 3, height: 18)
                .shadow(color: SamadhiColor.ivory.opacity(0.5), radius: 6)
                .offset(y: -(size * 0.41))
                .rotationEffect(.radians(wheelIndicatorAngle + .pi / 2))
                .transition(.opacity)
                .accessibilityHidden(true)
        }
    }

    private var adjustmentRow: some View {
        VStack(spacing: Space.x1) {
            HStack(spacing: Space.x3) {
                Button("Auto") { send(.resetRhythmControl) }
                    .font(.callout.weight(state.rhythmControl.mode == .automatic ? .bold : .medium))
                    .accessibilityIdentifier("rhythm-auto")
                    .accessibilityAddTraits(
                        state.rhythmControl.mode == .automatic ? .isSelected : []
                    )

                Rectangle()
                    .fill(SamadhiColor.ivory.opacity(0.34))
                    .frame(width: 1, height: 18)
                    .accessibilityHidden(true)

                Button("Manual") { send(.useManualRhythm) }
                    .font(.callout.weight(state.rhythmControl.mode == .manual ? .bold : .medium))
                    .accessibilityIdentifier("rhythm-manual")
                    .accessibilityAddTraits(
                        state.rhythmControl.mode == .manual ? .isSelected : []
                    )
            }
            .buttonStyle(.plain)
            .frame(minHeight: 48)

            Text("Turn the ring to tune")
                .font(.caption.weight(.medium))
                .foregroundStyle(SamadhiColor.ivory.opacity(0.68))
                .accessibilityHidden(true)
        }
        .foregroundStyle(SamadhiColor.ivory)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("rhythm-controls")
    }

    private var adjustmentGesture: some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .local)
            .onChanged { value in
                guard state.rhythmControl.isVisible else { return }
                let center = CGPoint(x: size / 2, y: size / 2)
                let x = value.location.x - center.x
                let y = value.location.y - center.y
                let angle = atan2(y, x)
                let startX = value.startLocation.x - center.x
                let startY = value.startLocation.y - center.y
                let startRadius = hypot(startX, startY)
                let startAngle = atan2(startY, startX)

                guard rotaryTracker.isTracking || startRadius >= size * 0.28 else { return }
                guard rotaryTracker.isTracking else {
                    dragOriginBPM = displayBPM
                    if state.rhythmControl.mode == .automatic, let displayBPM {
                        dragAutomaticBaseBPM =
                            displayBPM - state.rhythmControl.automaticCorrectionBPM
                    }
                    frozenDisplayBPM = displayBPM
                    rotaryTracker.begin(at: startAngle)
                    wheelIndicatorAngle = angle
                    _ = rotaryTracker.update(to: angle)
                    applyTrackedDetent()
                    return
                }

                _ = rotaryTracker.update(to: angle)
                wheelIndicatorAngle = angle
                applyTrackedDetent()
            }
            .onEnded { _ in
                dragAutomaticBaseBPM = nil
                dragOriginBPM = nil
                frozenDisplayBPM = nil
                rotaryTracker.reset()
                withAnimation(effectiveReduceMotion ? nil : .easeOut(duration: MotionToken.control)) {
                    wheelIndicatorAngle = nil
                }
            }
    }

    private var displayBPM: Int? {
        frozenDisplayBPM ?? state.rhythmControl.requestedBPM
    }

    private var modeLabel: String {
        switch state.rhythmControl.mode {
        case .automatic:
            let correction = state.rhythmControl.automaticCorrectionBPM
            guard correction != 0 else { return "Auto" }
            return correction > 0 ? "Auto +\(correction)" : "Auto \(correction)"
        case .manual:
            return "Manual"
        }
    }

    private var accessibilityLabel: String {
        state.rhythmControl.mode == .automatic ? "Automatic tempo target" : "Manual tempo target"
    }

    private var accessibilityValue: String {
        let target = displayBPM.map { "\($0) beats per minute" } ?? "Waiting for cadence"
        let applied = state.rhythmControl.appliedBPM.map { ", music at \($0) beats per minute" } ?? ""
        let fit =
            state.rhythmControl.isFindingBetterFit
            ? ", finding a better fitting song"
            : (state.rhythmControl.isAtLimit ? ", music holding steady" : "")
        return target + applied + fit
    }

    private var feedbackLabel: String {
        if state.rhythmControl.isFindingBetterFit { return "Finding a better fit" }
        if let applied = state.rhythmControl.appliedBPM {
            return state.rhythmControl.isAtLimit ? "Music \(applied) · Steady" : "Music \(applied)"
        }
        return state.rhythmControl.isAtLimit ? "Music steady" : "Settling"
    }

    private var effectiveReduceMotion: Bool {
        reduceMotion || state.forceReduceMotion
    }

    private func reveal() {
        guard state.rhythmControl.isAvailable else { return }
        if !state.rhythmControl.isVisible { send(.revealRhythmControl) }
        if voiceOverEnabled { send(.controlsFocusChanged(true)) }
    }

    private func boundedDisplayBPM(_ bpm: Int) -> Int {
        switch state.rhythmControl.mode {
        case .automatic:
            guard let base = dragAutomaticBaseBPM else { return bpm }
            let lowerBound = base + RhythmControlState.automaticCorrectionRange.lowerBound
            let upperBound = base + RhythmControlState.automaticCorrectionRange.upperBound
            return min(max(bpm, lowerBound), upperBound)
        case .manual:
            return min(max(bpm, 120), 200)
        }
    }

    private func applyTrackedDetent() {
        let origin = dragOriginBPM ?? 168
        let nextDisplayBPM = boundedDisplayBPM(origin + rotaryTracker.currentDetent)
        let change = nextDisplayBPM - (frozenDisplayBPM ?? origin)
        guard change != 0 else { return }
        frozenDisplayBPM = nextDisplayBPM

        // Each crossed detent gets one state change and one haptic click.
        let step = change > 0 ? 1 : -1
        for _ in 0..<abs(change) {
            send(.adjustRhythmControl(step))
        }
    }
}

final class RotaryDetentTracker {
    static let radiansPerDetent = Double.pi / 22.5

    private(set) var currentDetent = 0
    private var lastAngle: Double?
    private var accumulatedRotation = 0.0

    var isTracking: Bool { lastAngle != nil }

    func begin(at angle: Double) {
        currentDetent = 0
        accumulatedRotation = 0
        lastAngle = angle
    }

    func update(to angle: Double) -> Int {
        guard let priorAngle = lastAngle else {
            begin(at: angle)
            return currentDetent
        }

        var delta = angle - priorAngle
        if delta > .pi { delta -= 2 * .pi }
        if delta < -.pi { delta += 2 * .pi }
        accumulatedRotation += delta
        lastAngle = angle
        currentDetent = Int(
            (accumulatedRotation / Self.radiansPerDetent).rounded(.towardZero)
        )
        return currentDetent
    }

    func reset() {
        currentDetent = 0
        accumulatedRotation = 0
        lastAngle = nil
    }
}
