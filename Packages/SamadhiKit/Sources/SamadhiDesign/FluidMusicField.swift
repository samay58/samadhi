import SwiftUI

public enum FluidFieldMode: Sendable, Equatable {
    case ready
    case running
}

// The field's own time. Stopping it holds every line and color where it is, and starting it continues
// from there, so the field never jumps when the tempo locks or a pause ends.
struct FieldClock: Equatable {
    private var offset: TimeInterval = 0
    private var stoppedAt: TimeInterval?

    func time(at date: TimeInterval) -> TimeInterval {
        stoppedAt ?? date - offset
    }

    var restingTime: TimeInterval {
        stoppedAt ?? 0
    }

    mutating func stop(at date: TimeInterval) {
        guard stoppedAt == nil else { return }
        stoppedAt = date - offset
    }

    mutating func start(at date: TimeInterval) {
        guard let stoppedAt else { return }
        offset = date - stoppedAt
        self.stoppedAt = nil
    }
}

public struct FluidMusicField: View {
    let mode: FluidFieldMode
    let usesCollectionPalette: Bool
    let reduceMotionOverride: Bool
    let animates: Bool
    let playlistLines: [PlaylistContourLine]?
    let warmth: Double
    let isSettled: Bool
    let leavesClearing: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lineBirths: [String: TimeInterval] = [:]
    @State private var settledAt: TimeInterval?
    @State private var drawingUntil: TimeInterval?
    @State private var clock = FieldClock()

    public init(
        mode: FluidFieldMode,
        usesCollectionPalette: Bool = true,
        reduceMotionOverride: Bool = false,
        animates: Bool = true,
        contourLines: [PlaylistContourLine]? = nil,
        warmth: Double = 1,
        isSettled: Bool = false,
        leavesClearing: Bool = false
    ) {
        self.leavesClearing = leavesClearing
        self.playlistLines = contourLines
        self.warmth = warmth
        self.isSettled = isSettled
        self.mode = mode
        self.usesCollectionPalette = usesCollectionPalette
        self.reduceMotionOverride = reduceMotionOverride
        self.animates = animates
    }

    public var body: some View {
        // The field rests at 20 fps and stops once the tempo aperture becomes the motion owner. The
        // map alone runs faster, and only while a line is being drawn, because a pen stroke shows every
        // dropped frame and the slow color drift behind it does not.
        let colors = palette
        ZStack {
            TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !shouldAnimate)) { timeline in
                let time = fieldTime(at: timeline.date)
                ZStack {
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: meshPoints(at: time),
                        colors: colors,
                        background: mode == .ready ? SamadhiColor.parchment : SamadhiColor.plum,
                        smoothsColors: true
                    )
                    .animation(shouldAnimate ? .easeInOut(duration: 0.9) : nil, value: warmth)

                    if playlistLines == nil {
                        contourLines(at: time)
                            .transition(.opacity)
                    }
                }
                .animation(shouldAnimate ? .easeOut(duration: 0.4) : nil, value: playlistLines == nil)
            }

            if let playlistLines {
                TimelineView(.animation(minimumInterval: mapFrameInterval, paused: !shouldAnimate)) { timeline in
                    PlaylistContourCanvas(
                        lines: playlistLines,
                        births: lineBirths,
                        settledAt: settledAt,
                        now: fieldTime(at: timeline.date),
                        isAnimated: shouldAnimate,
                        ink: mode == .ready ? SamadhiColor.ink : SamadhiColor.ivory,
                        accent: mode == .ready ? SamadhiColor.clay : SamadhiColor.apricot,
                        leavesClearing: leavesClearing
                    )
                }
            }

            readabilityWash
        }
        .accessibilityHidden(true)
        .onChange(of: playlistLines?.map(\.id) ?? []) { oldIDs, newIDs in
            recordBirths(of: newIDs, excluding: oldIDs)
        }
        .onChange(of: isSettled) { _, settled in
            settledAt = settled && shouldAnimate ? Date.timeIntervalSinceReferenceDate : nil
        }
        .task(id: settledAt) {
            guard settledAt != nil else { return }
            try? await Task.sleep(for: .seconds(PlaylistContourCanvas.settleDuration))
            if !Task.isCancelled { settledAt = nil }
        }
        .task(id: drawingUntil) {
            guard let drawingUntil else { return }
            let remaining = drawingUntil - Date.timeIntervalSinceReferenceDate
            try? await Task.sleep(for: .seconds(max(remaining, 0)))
            if !Task.isCancelled { self.drawingUntil = nil }
        }
        .onChange(of: shouldAnimate) { _, animating in
            let now = Date.timeIntervalSinceReferenceDate
            if animating { clock.start(at: now) } else { clock.stop(at: now) }
        }
    }

    private var mapFrameInterval: TimeInterval {
        drawingUntil != nil || settledAt != nil ? 1.0 / 60.0 : 1.0 / 20.0
    }

    private func fieldTime(at date: Date) -> TimeInterval {
        shouldAnimate ? clock.time(at: date.timeIntervalSinceReferenceDate) : clock.restingTime
    }

    // Lines that were already there when the screen appeared stay still. Only a song read now draws.
    // Songs arrive in batches of three, so each waits a beat for the one before it.
    private func recordBirths(of ids: [String], excluding existing: [String]) {
        guard shouldAnimate else { return }
        let now = Date.timeIntervalSinceReferenceDate
        var next = max(now, (lineBirths.values.max() ?? 0) + PlaylistContourCanvas.drawStagger)
        for id in ids where !existing.contains(id) {
            lineBirths[id] = next
            next += PlaylistContourCanvas.drawStagger
        }
        if !ids.allSatisfy(existing.contains) {
            drawingUntil = next + PlaylistContourCanvas.drawDuration
        }
    }

    private var effectiveReduceMotion: Bool {
        reduceMotion || reduceMotionOverride
    }

    private var shouldAnimate: Bool {
        animates && !effectiveReduceMotion
    }

    private func meshPoints(at time: TimeInterval) -> [SIMD2<Float>] {
        let slow = time * 0.11
        let driftX = Float(sin(slow) * 0.09)
        let driftY = Float(cos(slow * 0.83) * 0.08)
        let lowerDrift = Float(sin(slow * 0.67 + 1.4) * 0.07)

        return [
            SIMD2(0, 0), SIMD2(0.5 + driftX * 0.22, 0), SIMD2(1, 0),
            SIMD2(0, 0.46 + driftY * 0.18), SIMD2(0.5 + driftX, 0.5 + driftY), SIMD2(1, 0.54 - driftY * 0.18),
            SIMD2(0, 1), SIMD2(0.5 + lowerDrift * 0.3, 1), SIMD2(1, 1),
        ]
    }

    private static let paleField = [
        SamadhiColor.parchment, Color(red: 0.94, green: 0.86, blue: 0.75), SamadhiColor.ivory,
        Color(red: 0.91, green: 0.79, blue: 0.65), Color(red: 0.93, green: 0.83, blue: 0.70),
        Color(red: 0.94, green: 0.85, blue: 0.73),
        SamadhiColor.ivory, Color(red: 0.86, green: 0.84, blue: 0.72), SamadhiColor.parchment,
    ]

    private var palette: [Color] {
        guard usesCollectionPalette else {
            return mode == .ready
                ? Self.paleField
                : [
                    SamadhiColor.plum, Color(red: 0.37, green: 0.35, blue: 0.32), SamadhiColor.ink,
                    Color(red: 0.34, green: 0.32, blue: 0.29), Color(red: 0.26, green: 0.28, blue: 0.25),
                    Color(red: 0.35, green: 0.31, blue: 0.29),
                    SamadhiColor.ink, Color(red: 0.32, green: 0.35, blue: 0.31), SamadhiColor.plum,
                ]
        }

        switch mode {
        case .ready:
            let sunrise = [
                SamadhiColor.parchment, Color(red: 0.95, green: 0.73, blue: 0.48), SamadhiColor.ivory,
                Color(red: 0.82, green: 0.43, blue: 0.27), Color(red: 0.94, green: 0.66, blue: 0.43),
                Color(red: 0.91, green: 0.58, blue: 0.35),
                Color(red: 0.58, green: 0.64, blue: 0.48), Color(red: 0.87, green: 0.73, blue: 0.53),
                SamadhiColor.parchment,
            ]
            guard warmth < 1 else { return sunrise }
            return zip(sunrise, Self.paleField).map { warm, pale in
                warm.mix(with: pale, by: 1 - warmth)
            }
        case .running:
            return [
                SamadhiColor.plum, Color(red: 0.55, green: 0.28, blue: 0.24), Color(red: 0.28, green: 0.18, blue: 0.22),
                Color(red: 0.62, green: 0.31, blue: 0.22), Color(red: 0.39, green: 0.28, blue: 0.28),
                Color(red: 0.45, green: 0.24, blue: 0.24),
                Color(red: 0.31, green: 0.38, blue: 0.28), Color(red: 0.42, green: 0.39, blue: 0.27), SamadhiColor.ink,
            ]
        }
    }

    private func contourLines(at time: TimeInterval) -> some View {
        Canvas { context, size in
            let slow = time * 0.13
            let color =
                mode == .ready
                ? SamadhiColor.ink.opacity(0.10)
                : SamadhiColor.ivory.opacity(0.12)

            for index in 0..<8 {
                let fraction = CGFloat(index) / 7
                let baseY = size.height * (0.16 + fraction * 0.72)
                let offset = sin(slow + Double(index) * 0.62) * size.height * 0.025
                var path = Path()
                path.move(to: CGPoint(x: -12, y: baseY + offset))
                path.addCurve(
                    to: CGPoint(x: size.width + 12, y: baseY - offset * 0.48),
                    control1: CGPoint(
                        x: size.width * 0.29,
                        y: baseY - size.height * (0.045 + fraction * 0.02) + offset
                    ),
                    control2: CGPoint(
                        x: size.width * 0.68,
                        y: baseY + size.height * (0.05 - fraction * 0.018) - offset
                    )
                )
                context.stroke(path, with: .color(color), lineWidth: index == 3 ? 1.2 : 0.75)
            }
        }
    }

    private var readabilityWash: some View {
        // This wash protects text contrast while the mesh moves underneath it.
        LinearGradient(
            colors: mode == .ready
                ? [SamadhiColor.parchment.opacity(0.34), .clear, SamadhiColor.parchment.opacity(0.42)]
                : [SamadhiColor.ink.opacity(0.18), .clear, SamadhiColor.ink.opacity(0.32)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
