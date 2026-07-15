import SamadhiAudio
import SwiftUI

public enum ApertureMode: Sendable, Equatable {
    case acquiring
    case locked
    case paused
    case interrupted
}

public struct TempoAperture: View {
    let mode: ApertureMode
    let cadenceSPM: Int?
    let progress: Double
    let reduceMotionOverride: Bool
    let increasedContrastOverride: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    public init(
        mode: ApertureMode,
        cadenceSPM: Int? = nil,
        progress: Double = 0,
        reduceMotionOverride: Bool = false,
        increasedContrastOverride: Bool = false
    ) {
        self.mode = mode
        self.cadenceSPM = cadenceSPM
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
        let bpm = Double(cadenceSPM ?? 96)
        let snapshot = BeatClockSnapshot(bpm: bpm, anchorUptime: 0)
        return snapshot.phase(atUptime: ProcessInfo.processInfo.systemUptime)
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
        case .locked: "In step"
        case .paused: "Paused"
        case .interrupted: "Music paused"
        }
    }

    private var effectiveReduceMotion: Bool {
        reduceMotion || reduceMotionOverride
    }

    private var accessibilityValue: String {
        let songProgress = "\(Int(progress * 100)) percent through song"
        guard let cadenceSPM, mode == .locked else { return songProgress }
        return "\(cadenceSPM) steps per minute, \(songProgress)"
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
            Circle()
                .fill(
                    AngularGradient(
                        colors: orbColors,
                        center: .center,
                        angle: .degrees(phase * 22)
                    )
                )
                .overlay {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    SamadhiColor.ivory.opacity(0.72),
                                    SamadhiColor.apricot.opacity(0.16),
                                    SamadhiColor.plum.opacity(0.34),
                                ],
                                center: UnitPoint(x: 0.31, y: 0.24),
                                startRadius: 3,
                                endRadius: 175
                            )
                        )
                }
                .overlay {
                    Circle()
                        .strokeBorder(
                            SamadhiColor.ivory.opacity(increasedContrast ? 0.96 : 0.64),
                            lineWidth: increasedContrast ? 3 : 1.5)
                }
                .shadow(color: SamadhiColor.apricot.opacity(0.28), radius: 30, y: 12)
                .shadow(color: SamadhiColor.ink.opacity(0.34), radius: 18, y: 14)
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

            Ellipse()
                .fill(SamadhiColor.ivory.opacity(0.36))
                .frame(width: 64, height: 22)
                .blur(radius: 8)
                .rotationEffect(.degrees(-24))
                .offset(x: -42, y: -54)
        }
    }

    private var orbColors: [Color] {
        switch mode {
        case .acquiring:
            [SamadhiColor.plum, SamadhiColor.apricot.opacity(0.82), SamadhiColor.olive, SamadhiColor.plum]
        case .locked:
            [SamadhiColor.clay, SamadhiColor.apricot, SamadhiColor.olive, SamadhiColor.plum, SamadhiColor.clay]
        case .paused:
            [SamadhiColor.plum, SamadhiColor.apricot.opacity(0.48), SamadhiColor.ink, SamadhiColor.plum]
        case .interrupted:
            [
                SamadhiColor.plum.opacity(0.72), SamadhiColor.ink, SamadhiColor.olive.opacity(0.58),
                SamadhiColor.plum.opacity(0.72),
            ]
        }
    }
}
