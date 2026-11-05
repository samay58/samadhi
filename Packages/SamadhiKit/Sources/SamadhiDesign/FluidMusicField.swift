import Foundation
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
    let usesFullLight: Bool
    let reduceMotionOverride: Bool
    let animates: Bool
    let playlistLines: [PlaylistContourLine]?
    let bloom: Double
    let isSettled: Bool
    let leavesClearing: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lineBirths: [String: TimeInterval] = [:]
    @State private var settledAt: TimeInterval?
    @State private var drawingUntil: TimeInterval?
    @State private var clock = FieldClock()

    public init(
        mode: FluidFieldMode,
        usesFullLight: Bool = true,
        reduceMotionOverride: Bool = false,
        animates: Bool = true,
        contourLines: [PlaylistContourLine]? = nil,
        bloom: Double = 1,
        isSettled: Bool = false,
        leavesClearing: Bool = false
    ) {
        self.leavesClearing = leavesClearing
        self.playlistLines = contourLines
        self.bloom = bloom
        self.isSettled = isSettled
        self.mode = mode
        self.usesFullLight = usesFullLight
        self.reduceMotionOverride = reduceMotionOverride
        self.animates = animates
    }

    public var body: some View {
        // The field rests at 20 fps and stops once the tempo aperture becomes the motion owner. The
        // map alone runs faster, and only while a line is being drawn, because a pen stroke shows every
        // dropped frame and the slow color drift behind it does not.
        ZStack {
            TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !shouldAnimate)) { timeline in
                let time = fieldTime(at: timeline.date)
                ZStack {
                    // Drawn together at high precision, so the noise lands before the colors are rounded to
                    // the display's 8 bits. That is true dithering. Noise added afterward only masks the bands.
                    ZStack {
                        SamadhiColor.paper

                        fieldLights(at: time)
                            .animation(shouldAnimate ? .easeInOut(duration: 0.9) : nil, value: bloom)

                        readabilityWash

                        FieldGrain()
                    }
                    .drawingGroup(opaque: true, colorMode: .linear)

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
                        ink: SamadhiColor.ink,
                        accent: SamadhiColor.line,
                        leavesClearing: leavesClearing
                    )
                }
            }
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

    // Two soft lights over the ground: lime low on the left and lilac high on the right. Radial light has no
    // seams, which matters on a surface this dark.
    private func fieldLights(at time: TimeInterval) -> some View {
        let slow = time * 0.11
        let driftX = sin(slow) * 0.05
        let driftY = cos(slow * 0.83) * 0.04
        return ZStack {
            FieldLight(
                color: Self.limeLight(mode),
                center: UnitPoint(x: 0.1 + driftX, y: 1.02 + driftY),
                reach: 0.92
            )
            FieldLight(
                color: Self.lilacLight(mode),
                center: UnitPoint(x: 1.02 - driftX, y: 0 - driftY),
                reach: 0.66
            )
        }
        .opacity(lightStrength)
    }

    private var lightStrength: Double {
        guard usesFullLight else { return 0.34 }
        return mode == .ready ? bloom : 1
    }

    private static func limeLight(_ mode: FluidFieldMode) -> Color {
        mode == .ready ? Color(light: 0xDAEA84, dark: 0x2D3C0F) : Color(hex: 0x27340E)
    }

    private static func lilacLight(_ mode: FluidFieldMode) -> Color {
        mode == .ready ? Color(light: 0xE0D8F0, dark: 0x191629) : Color(hex: 0x161326)
    }

    private func contourLines(at time: TimeInterval) -> some View {
        Canvas { context, size in
            let slow = time * 0.13
            let color = SamadhiColor.ink.opacity(mode == .ready ? 0.09 : 0.1)

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
        // This wash protects text contrast while the lights move underneath it.
        LinearGradient(
            colors: mode == .ready
                ? [SamadhiColor.paper.opacity(0.34), .clear, SamadhiColor.paper.opacity(0.42)]
                : [SamadhiColor.paper.opacity(0.18), .clear, SamadhiColor.paper.opacity(0.32)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// A light that eases out over its whole reach, so no ring marks where it ends.
private struct FieldLight: View {
    let color: Color
    let center: UnitPoint
    let reach: CGFloat

    private static let falloff: [(location: CGFloat, strength: Double)] = (0...32).map { step in
        let location = CGFloat(step) / 32
        let eased = 1 - location * location * (3 - 2 * location)
        return (location, Double(eased))
    }

    var body: some View {
        EllipticalGradient(
            stops: Self.falloff.map { .init(color: color.opacity($0.strength), location: $0.location) },
            center: center,
            startRadiusFraction: 0,
            endRadiusFraction: reach
        )
    }
}

// Dark gradients move a few color steps across a whole screen, and an 8-bit display shows each step as a
// visible band. A still layer of noise about one step tall dithers those edges away. It is too faint to
// read as texture, and it never moves.
private struct FieldGrain: View {
    @Environment(\.displayScale) private var displayScale
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if let tile = Self.tile {
            Image(decorative: tile, scale: displayScale)
                .resizable(resizingMode: .tile)
                // The layer composites in linear light, where the same noise is far stronger on near-black.
                .opacity(colorScheme == .dark ? 0.28 : 1)
                .allowsHitTesting(false)
        }
    }

    // A fixed seed draws the same tile on every launch, so two frames of one screen compare exactly.
    private static let tile: CGImage? = {
        let side = 256
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        var seed: UInt32 = 0x5EED_1234
        for index in 0..<(side * side) {
            // Xorshift, because a simple multiplying generator leaves a visible grid in the low bits.
            seed ^= seed << 13
            seed ^= seed >> 17
            seed ^= seed << 5
            // Premultiplied: white lifts dark ground, black lowers paper, each at about one percent.
            let alpha = UInt8(1 + (seed >> 8) % 3)
            let channel: UInt8 = seed >> 31 == 0 ? alpha : 0
            pixels[index * 4] = channel
            pixels[index * 4 + 1] = channel
            pixels[index * 4 + 2] = channel
            pixels[index * 4 + 3] = alpha
        }
        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else { return nil }
        return CGImage(
            width: side,
            height: side,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: side * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }()
}
