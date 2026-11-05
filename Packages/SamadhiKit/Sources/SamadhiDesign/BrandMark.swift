import SwiftUI

// The app icon at 38 points: one lilac sphere with four bold lines streaming away behind it and swaying. The
// lines are lime on dark and ink on light, the same pairing the two icons use.
public struct BrandMark: View {
    private static let lineColor = Color(light: Swatch.inkLight, dark: Swatch.lime)

    public init() {}

    public var body: some View {
        Canvas { context, size in
            let unit = min(size.width / 38, size.height / 28)
            let origin = CGPoint(x: (size.width - 38 * unit) / 2, y: (size.height - 28 * unit) / 2)
            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(x: origin.x + x * unit, y: origin.y + y * unit)
            }

            // One line, leaving the sphere, settling, then swaying. `side` is -1 above and 1 below.
            func streamline(startX: CGFloat, start: CGFloat, settled: CGFloat, side: CGFloat) -> Path {
                let rest = 14 + side * settled
                var path = Path()
                path.move(to: point(startX, 14 + side * start))
                path.addCurve(
                    to: point(24, rest),
                    control1: point(startX + 5, 14 + side * start),
                    control2: point(19, rest)
                )
                path.addCurve(
                    to: point(36.8, rest + 1.3),
                    control1: point(28, rest + 2.8),
                    control2: point(32, rest + 2.8)
                )
                return path
            }

            let style = StrokeStyle(lineWidth: 1.8 * unit, lineCap: .round)
            for side in [CGFloat(-1), 1] {
                let inner = streamline(startX: 15.5, start: 2.7, settled: 3, side: side)
                let outer = streamline(startX: 7.5, start: 9.3, settled: 7.8, side: side)
                context.stroke(inner, with: .color(Self.lineColor), style: style)
                context.stroke(outer, with: .color(Self.lineColor), style: style)
            }

            let center = point(8, 14)
            let radius = 6.2 * unit
            context.fill(
                Path(
                    ellipseIn: CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                ),
                with: .color(SamadhiColor.lilac)
            )
        }
        .accessibilityHidden(true)
    }
}
