import SamadhiDomain
import SwiftUI

struct RhythmControl: View {
    let state: RunViewState
    let mode: ApertureMode
    let size: CGFloat
    let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @State private var dragOriginBPM: Int?
    @State private var lastDragDetent = 0
    @State private var frozenDisplayBPM: Int?

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
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(adjustmentGesture)
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
    }

    private var adjustmentRow: some View {
        HStack(spacing: Space.x3) {
            adjustmentButton(title: "Slower", systemImage: "minus", steps: -1)

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

            adjustmentButton(title: "Faster", systemImage: "plus", steps: 1)
        }
        .foregroundStyle(SamadhiColor.ivory)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("rhythm-controls")
    }

    private func adjustmentButton(
        title: String,
        systemImage: String,
        steps: Int
    ) -> some View {
        Button {
            send(.adjustRhythmControl(steps))
        } label: {
            Image(systemName: systemImage)
                .font(.body.weight(.bold))
                .frame(width: 52, height: 52)
                .background {
                    Circle()
                        .fill(SamadhiColor.ink.opacity(0.2))
                        .stroke(SamadhiColor.ivory.opacity(0.48), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityIdentifier(steps < 0 ? "rhythm-slower" : "rhythm-faster")
    }

    private var adjustmentGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard state.rhythmControl.isVisible,
                    abs(value.translation.width) > abs(value.translation.height)
                else { return }

                if dragOriginBPM == nil {
                    dragOriginBPM = displayBPM
                    lastDragDetent = 0
                    frozenDisplayBPM = displayBPM
                }
                let detent = Int((value.translation.width / 12).rounded(.towardZero))
                let change = detent - lastDragDetent
                guard change != 0 else { return }
                lastDragDetent = detent
                frozenDisplayBPM = boundedDisplayBPM((dragOriginBPM ?? 168) + detent)
                send(.adjustRhythmControl(change))
            }
            .onEnded { _ in
                dragOriginBPM = nil
                lastDragDetent = 0
                frozenDisplayBPM = nil
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
        let limit = state.rhythmControl.isAtLimit ? ", at safe playback limit" : ""
        return target + applied + limit
    }

    private var feedbackLabel: String {
        if let applied = state.rhythmControl.appliedBPM {
            return state.rhythmControl.isAtLimit ? "Music \(applied) · At limit" : "Music \(applied)"
        }
        return state.rhythmControl.isAtLimit ? "At limit" : "Settling"
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
            guard let origin = dragOriginBPM else { return bpm }
            let correction = state.rhythmControl.automaticCorrectionBPM
            let lowerBound = origin + RhythmControlState.automaticCorrectionRange.lowerBound - correction
            let upperBound = origin + RhythmControlState.automaticCorrectionRange.upperBound - correction
            return min(max(bpm, lowerBound), upperBound)
        case .manual:
            return min(max(bpm, 120), 200)
        }
    }
}
