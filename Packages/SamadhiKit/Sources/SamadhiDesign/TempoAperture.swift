import SwiftUI

public enum ApertureMode: Sendable, Equatable {
    case acquiring
    case locked
    case paused
    case interrupted
}

public struct TempoAperture: View {
    let mode: ApertureMode
    let tempoBPM: Int?
    let progress: Double
    let reduceMotionOverride: Bool
    let increasedContrastOverride: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    public init(
        mode: ApertureMode,
        tempoBPM: Int? = nil,
        progress: Double = 0,
        reduceMotionOverride: Bool = false,
        increasedContrastOverride: Bool = false
    ) {
        self.mode = mode
        self.tempoBPM = tempoBPM
        self.progress = min(max(progress, 0), 1)
        self.reduceMotionOverride = reduceMotionOverride
        self.increasedContrastOverride = increasedContrastOverride
    }

    public var body: some View {
        // One beat phase drives every pulse detail. Pause and Reduce Motion freeze that same clock.
        TimelineView(
            .animation(
                minimumInterval: 1 / 30, paused: effectiveReduceMotion || mode == .paused || mode == .interrupted)
        ) { _ in
            let phase = visualPhase
            TempoOrbDrawing(
                mode: mode,
                phase: phase,
                progress: progress,
                animatesProgress: !effectiveReduceMotion,
                increasedContrast: contrast == .increased || increasedContrastOverride
            )
            .scaleEffect(orbScale(for: phase))
            .offset(y: orbLift(for: phase))
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
    }

    private var visualPhase: Double {
        guard !effectiveReduceMotion, mode != .paused, mode != .interrupted else { return 0.18 }
        let bpm = Double(tempoBPM ?? 96)
        let secondsPerBeat = 60 / max(bpm, 1)
        return (ProcessInfo.processInfo.systemUptime / secondsPerBeat).truncatingRemainder(dividingBy: 1)
    }

    private func orbScale(for phase: Double) -> CGFloat {
        guard !effectiveReduceMotion, mode == .locked else { return 1 }
        return 1 + 0.038 * beatImpulse(for: phase)
    }

    private func orbLift(for phase: Double) -> CGFloat {
        guard !effectiveReduceMotion, mode == .locked else { return 0 }
        return -5 * beatImpulse(for: phase)
    }

    private func beatImpulse(for phase: Double) -> CGFloat {
        CGFloat(exp(-phase * 7.5))
    }

    private var accessibilityLabel: String {
        switch mode {
        case .acquiring: "Listening for your stride"
        case .locked: "Tempo matched"
        case .paused: "Paused"
        case .interrupted: "Music paused"
        }
    }

    private var effectiveReduceMotion: Bool {
        reduceMotion || reduceMotionOverride
    }

    private var accessibilityValue: String {
        let songProgress = "\(Int(progress * 100)) percent through song"
        guard let tempoBPM, mode == .locked else { return songProgress }
        return "Music at \(tempoBPM) beats per minute, \(songProgress)"
    }
}

private struct TempoOrbDrawing: View {
    let mode: ApertureMode
    let phase: Double
    let progress: Double
    let animatesProgress: Bool
    let increasedContrast: Bool

    var body: some View {
        ZStack {
            // A sunrise under the lens gives the glass something to bend. It swells on the beat.
            Circle()
                .fill(
                    RadialGradient(
                        colors: pooledLight,
                        center: UnitPoint(x: 0.5, y: 1.04),
                        startRadius: 4,
                        endRadius: 172
                    )
                )
                .opacity(0.72 + 0.28 * exp(-phase * 7.5))
                .padding(18)

            Color.clear
                .glassEffect(lens, in: .circle)
                .padding(18)

            Circle()
                .stroke(
                    SamadhiColor.ivory.opacity(mode == .interrupted ? 0.2 : 0.28),
                    lineWidth: increasedContrast ? 3 : 1.5
                )
                .padding(7)

            Circle()
                // The outer arc is song progress. It must remain visually separate from the beat pulse.
                .trim(from: 0, to: max(progress, 0.012))
                .stroke(
                    SamadhiColor.ivory.opacity(mode == .interrupted ? 0.36 : 0.9),
                    style: StrokeStyle(lineWidth: increasedContrast ? 4 : 2.25, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(7)
                .animation(animatesProgress ? .smooth(duration: 0.5) : nil, value: progress)

            Circle()
                .stroke(
                    SamadhiColor.apricot.opacity(mode == .paused ? 0.22 : 0.52),
                    style: StrokeStyle(lineWidth: 1, dash: [2, 8])
                )
                .padding(38)
        }
    }

    private var lens: Glass {
        // Regular glass turns pale over this field, so it needs a dark tint for ivory text to hold.
        increasedContrast ? .regular.tint(SamadhiColor.ink.opacity(0.62)).interactive() : .clear.interactive()
    }

    private var pooledLight: [Color] {
        switch mode {
        case .acquiring:
            [SamadhiColor.apricot.opacity(0.45), SamadhiColor.clay.opacity(0.18), .clear]
        case .locked:
            [SamadhiColor.apricot.opacity(0.9), SamadhiColor.clay.opacity(0.42), .clear]
        case .paused:
            [SamadhiColor.ivory.opacity(0.14), SamadhiColor.apricot.opacity(0.08), .clear]
        case .interrupted:
            [SamadhiColor.plum.opacity(0.4), .clear]
        }
    }
}
