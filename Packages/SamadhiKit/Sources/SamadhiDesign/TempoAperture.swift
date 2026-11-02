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
    let showsReadout: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    public init(
        mode: ApertureMode,
        tempoBPM: Int? = nil,
        progress: Double = 0,
        reduceMotionOverride: Bool = false,
        increasedContrastOverride: Bool = false,
        showsReadout: Bool = false
    ) {
        self.showsReadout = showsReadout
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
                increasedContrast: contrast == .increased || increasedContrastOverride,
                pump: conePump(for: phase),
                showsReadout: showsReadout
            )
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

    // How far the cone has pushed forward on this beat. The surround stays still, as on a real driver.
    private func conePump(for phase: Double) -> Double {
        guard !effectiveReduceMotion, mode == .locked else { return 0 }
        return exp(-phase * 7.5)
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
    let pump: Double
    let showsReadout: Bool

    var body: some View {
        ZStack {
            SpeakerDriver(pump: pump, isQuiet: showsReadout || mode == .interrupted)
                .padding(18)

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
                .opacity(0.62 + 0.3 * pump)
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

// A speaker driver seen head on: a rolled surround that stays still, a ribbed cone, and a domed
// center cap. Each piece pushes forward on the beat, the center furthest, so the wheel moves the way
// a real speaker does. It is drawn in the field's own ink so the field stays visible through it.
private struct SpeakerDriver: View {
    let pump: Double
    let isQuiet: Bool

    private static let ribCount = 6

    var body: some View {
        Canvas { context, size in
            let radius = Double(min(size.width, size.height)) / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let topLeft = CGPoint(x: 0, y: 0)
            let bottomRight = CGPoint(x: size.width, y: size.height)
            let detail: Double = isQuiet ? 0.5 : 1

            func circle(_ ringRadius: Double) -> Path {
                Path(
                    ellipseIn: CGRect(
                        x: center.x - ringRadius,
                        y: center.y - ringRadius,
                        width: ringRadius * 2,
                        height: ringRadius * 2
                    )
                )
            }

            // Light falls from the top left, so a raised ring is bright there and dark opposite.
            func raised(_ light: Double, _ shade: Double) -> GraphicsContext.Shading {
                .linearGradient(
                    Gradient(colors: [
                        SamadhiColor.ivory.opacity(light * detail),
                        SamadhiColor.ink.opacity(shade * detail),
                    ]),
                    startPoint: topLeft,
                    endPoint: bottomRight
                )
            }

            context.fill(
                circle(radius),
                with: .radialGradient(
                    Gradient(colors: [
                        SamadhiColor.ink.opacity(0.5),
                        SamadhiColor.ink.opacity(0.26),
                        SamadhiColor.ink.opacity(0.42),
                    ]),
                    center: center,
                    startRadius: radius * 0.2,
                    endRadius: radius
                )
            )

            context.stroke(
                circle(radius * 0.9),
                with: raised(0.42, 0.58),
                lineWidth: radius * 0.1
            )

            for index in 0..<Self.ribCount {
                let position = Double(index) / Double(Self.ribCount)
                let travel: Double = 1 + pump * 0.04 * (1 - position)
                let ribRadius: Double = radius * (0.36 + position * 0.44) * travel
                context.stroke(
                    circle(ribRadius),
                    with: raised(0.26 - position * 0.08, 0.32),
                    lineWidth: 0.8
                )
            }

            let capRadius: Double = radius * 0.27 * (1 + pump * 0.07)
            context.fill(
                circle(capRadius),
                with: .radialGradient(
                    Gradient(colors: [
                        SamadhiColor.ivory.opacity(0.42 * detail),
                        SamadhiColor.apricot.opacity(0.2 * detail),
                        SamadhiColor.ink.opacity(0.5 * detail),
                    ]),
                    center: CGPoint(x: center.x - capRadius * 0.34, y: center.y - capRadius * 0.4),
                    startRadius: 0,
                    endRadius: capRadius * 1.5
                )
            )
            context.stroke(circle(capRadius), with: raised(0.3, 0.4), lineWidth: 0.8)
        }
        .clipShape(.circle)
    }
}
