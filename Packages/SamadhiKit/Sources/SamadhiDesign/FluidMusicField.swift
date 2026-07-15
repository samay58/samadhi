import SwiftUI

public enum FluidFieldMode: Sendable, Equatable {
    case ready
    case running
}

public struct FluidMusicField: View {
    let mode: FluidFieldMode
    let usesCollectionPalette: Bool
    let reduceMotionOverride: Bool
    let animates: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        mode: FluidFieldMode,
        usesCollectionPalette: Bool = true,
        reduceMotionOverride: Bool = false,
        animates: Bool = true
    ) {
        self.mode = mode
        self.usesCollectionPalette = usesCollectionPalette
        self.reduceMotionOverride = reduceMotionOverride
        self.animates = animates
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 20, paused: !shouldAnimate)) { timeline in
            let time = shouldAnimate ? timeline.date.timeIntervalSinceReferenceDate : 0
            ZStack {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: meshPoints(at: time),
                    colors: palette,
                    background: mode == .ready ? SamadhiColor.parchment : SamadhiColor.plum,
                    smoothsColors: true
                )

                contourLines(at: time)

                readabilityWash
            }
        }
        .accessibilityHidden(true)
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

    private var palette: [Color] {
        guard usesCollectionPalette else {
            return mode == .ready
                ? [
                    SamadhiColor.parchment, Color(red: 0.78, green: 0.75, blue: 0.69), SamadhiColor.ivory,
                    Color(red: 0.63, green: 0.58, blue: 0.53), Color(red: 0.44, green: 0.43, blue: 0.39), Color(red: 0.72, green: 0.68, blue: 0.61),
                    SamadhiColor.ivory, Color(red: 0.58, green: 0.61, blue: 0.55), SamadhiColor.parchment,
                ]
                : [
                    SamadhiColor.plum, Color(red: 0.37, green: 0.35, blue: 0.32), SamadhiColor.ink,
                    Color(red: 0.34, green: 0.32, blue: 0.29), Color(red: 0.26, green: 0.28, blue: 0.25), Color(red: 0.35, green: 0.31, blue: 0.29),
                    SamadhiColor.ink, Color(red: 0.32, green: 0.35, blue: 0.31), SamadhiColor.plum,
                ]
        }

        switch mode {
        case .ready:
            return [
                SamadhiColor.parchment, Color(red: 0.95, green: 0.73, blue: 0.48), SamadhiColor.ivory,
                Color(red: 0.82, green: 0.43, blue: 0.27), Color(red: 0.48, green: 0.29, blue: 0.31), Color(red: 0.91, green: 0.58, blue: 0.35),
                Color(red: 0.58, green: 0.64, blue: 0.48), Color(red: 0.87, green: 0.73, blue: 0.53), SamadhiColor.parchment,
            ]
        case .running:
            return [
                SamadhiColor.plum, Color(red: 0.55, green: 0.28, blue: 0.24), Color(red: 0.28, green: 0.18, blue: 0.22),
                Color(red: 0.62, green: 0.31, blue: 0.22), Color(red: 0.39, green: 0.28, blue: 0.28), Color(red: 0.45, green: 0.24, blue: 0.24),
                Color(red: 0.31, green: 0.38, blue: 0.28), Color(red: 0.42, green: 0.39, blue: 0.27), SamadhiColor.ink,
            ]
        }
    }

    private func contourLines(at time: TimeInterval) -> some View {
        Canvas { context, size in
            let slow = time * 0.13
            let color = mode == .ready
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
        LinearGradient(
            colors: mode == .ready
                ? [SamadhiColor.parchment.opacity(0.34), .clear, SamadhiColor.parchment.opacity(0.42)]
                : [SamadhiColor.ink.opacity(0.18), .clear, SamadhiColor.ink.opacity(0.32)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
