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
        TempoWheelDrawing(
            mode: mode,
            tempoBPM: tempoBPM,
            progress: progress,
            animatesProgress: !effectiveReduceMotion,
            increasedContrast: contrast == .increased || increasedContrastOverride,
            isPumping: !effectiveReduceMotion && mode == .locked,
            showsReadout: showsReadout
        )
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
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

private struct TempoWheelDrawing: View {
    let mode: ApertureMode
    let tempoBPM: Int?
    let progress: Double
    let animatesProgress: Bool
    let increasedContrast: Bool
    let isPumping: Bool
    let showsReadout: Bool

    var body: some View {
        ZStack {
            PumpingDriver(
                tempoBPM: tempoBPM,
                isPumping: isPumping,
                isQuiet: showsReadout || mode == .interrupted,
                isLit: mode == .locked && !showsReadout,
                light: pooledLight
            )
            .padding(18)

            Color.clear
                .glassEffect(lens, in: .circle)
                .padding(18)

            Circle()
                .stroke(
                    SamadhiColor.ink.opacity(mode == .interrupted ? 0.2 : 0.28),
                    lineWidth: increasedContrast ? 3 : 1.5
                )
                .padding(7)

            Circle()
                // The outer arc is song progress. It must remain visually separate from the beat pulse.
                .trim(from: 0, to: max(progress, 0.012))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: increasedContrast ? 4 : 2.25, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(7)
                .animation(animatesProgress ? .smooth(duration: 0.5) : nil, value: progress)

            Circle()
                // The ring opens at the bottom where the word Turn sits, so the dashes never cross it.
                .trim(from: leavesRoomForLabel ? 0.035 : 0, to: leavesRoomForLabel ? 0.965 : 1)
                .rotation(.degrees(90))
                .stroke(
                    SamadhiColor.ink.opacity(mode == .paused ? 0.14 : 0.26),
                    style: StrokeStyle(lineWidth: 1, dash: [2, 8])
                )
                .padding(38)
        }
    }

    private var leavesRoomForLabel: Bool {
        mode == .locked && !showsReadout
    }

    // The progress arc is lime only while the music is following the runner.
    private var progressColor: Color {
        switch mode {
        case .locked: SamadhiColor.lime
        case .acquiring, .paused: SamadhiColor.ink.opacity(0.72)
        case .interrupted: SamadhiColor.ink.opacity(0.36)
        }
    }

    private var lens: Glass {
        // Regular glass turns pale over this field, so it needs a dark tint for the text to hold.
        increasedContrast ? .regular.tint(SamadhiColor.paper.opacity(0.62)).interactive() : .clear.interactive()
    }

    private var pooledLight: [Color] {
        switch mode {
        case .acquiring:
            [SamadhiColor.lime.opacity(0.14), SamadhiColor.lime.opacity(0.05), .clear]
        case .locked:
            [SamadhiColor.lime.opacity(0.26), SamadhiColor.lime.opacity(0.08), .clear]
        case .paused:
            [SamadhiColor.ink.opacity(0.08), SamadhiColor.ink.opacity(0.03), .clear]
        case .interrupted:
            [SamadhiColor.ink.opacity(0.04), .clear]
        }
    }
}

// How far through a beat the music is. A tempo change alters how fast the beats come without jumping
// to another point in the beat. It keeps the music's tempo but does not know where the song's beats
// fall, because analysis measures tempo and no beat positions.
struct BeatClock: Equatable {
    private var anchorTime: TimeInterval = 0
    private var anchorPhase: Double = 0
    private var beatsPerSecond: Double

    init(bpm: Double) {
        beatsPerSecond = max(bpm, 1) / 60
    }

    func phase(at time: TimeInterval) -> Double {
        (anchorPhase + (time - anchorTime) * beatsPerSecond).truncatingRemainder(dividingBy: 1)
    }

    mutating func retime(toBPM bpm: Double, at time: TimeInterval) {
        anchorPhase = phase(at: time)
        anchorTime = time
        beatsPerSecond = max(bpm, 1) / 60
    }

    // How far the cone has pushed forward on this beat. Steps too small to see round to the same value,
    // so the driver redraws nothing during the still last third of each beat.
    static func pump(atPhase phase: Double) -> Double {
        (exp(-phase * 7.5) * 64).rounded() / 64
    }
}

// Only the parts that move with the beat sit on the clock, so the glass and the rings above them are
// not rebuilt 30 times a second. Outside a locked tempo nothing here moves, so the clock stops.
private struct PumpingDriver: View {
    let tempoBPM: Int?
    let isPumping: Bool
    let isQuiet: Bool
    let isLit: Bool
    let light: [Color]

    @State private var clock: BeatClock

    init(tempoBPM: Int?, isPumping: Bool, isQuiet: Bool, isLit: Bool, light: [Color]) {
        self.tempoBPM = tempoBPM
        self.isPumping = isPumping
        self.isQuiet = isQuiet
        self.isLit = isLit
        self.light = light
        _clock = State(initialValue: BeatClock(bpm: Double(tempoBPM ?? 96)))
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !isPumping)) { _ in
            let pump = isPumping ? BeatClock.pump(atPhase: clock.phase(at: ProcessInfo.processInfo.systemUptime)) : 0
            ZStack {
                SpeakerDriver(pump: pump, isQuiet: isQuiet, isLit: isLit)

                // A low light under the lens gives the glass something to bend. It swells on the beat.
                Circle()
                    .fill(
                        RadialGradient(
                            colors: light,
                            center: UnitPoint(x: 0.5, y: 1.04),
                            startRadius: 4,
                            endRadius: 172
                        )
                    )
                    .opacity(0.62 + 0.3 * pump)
            }
        }
        .onChange(of: tempoBPM) { _, bpm in
            clock.retime(toBPM: Double(bpm ?? 96), at: ProcessInfo.processInfo.systemUptime)
        }
    }
}

// A speaker driver seen head on: a rolled surround that stays still, a ribbed cone, and a domed
// center cap. Each piece pushes forward on the beat, the center furthest, so the wheel moves the way
// a real speaker does. It is drawn in the field's own ink so the field stays visible through it, and
// the cap turns lime only when the tempo has matched, so the one bright thing on screen means something.
private struct SpeakerDriver: View {
    let pump: Double
    let isQuiet: Bool
    let isLit: Bool

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
                        SamadhiColor.ink.opacity(light * detail),
                        SamadhiColor.paper.opacity(shade * detail),
                    ]),
                    startPoint: topLeft,
                    endPoint: bottomRight
                )
            }

            context.fill(
                circle(radius),
                with: .radialGradient(
                    Gradient(colors: [
                        SamadhiColor.paper.opacity(0.5),
                        SamadhiColor.paper.opacity(0.26),
                        SamadhiColor.paper.opacity(0.42),
                    ]),
                    center: center,
                    startRadius: radius * 0.2,
                    endRadius: radius
                )
            )

            context.stroke(
                circle(radius * 0.9),
                with: raised(0.24, 0.5),
                lineWidth: radius * 0.085
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
                    Gradient(
                        colors: isLit
                            ? [Color(hex: 0xE8F77E), SamadhiColor.lime, Color(hex: 0x7E9021)]
                            : [
                                SamadhiColor.ink.opacity(0.42 * detail),
                                SamadhiColor.ink.opacity(0.14 * detail),
                                SamadhiColor.paper.opacity(0.5 * detail),
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
