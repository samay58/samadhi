import SwiftUI

// The app icon reduced to what survives at 38 points: four streamlines parting around one sphere. The sphere
// is the same object as the wheel's center, which lights up when the tempo matches.
public struct BrandMark: View {
    public init() {}

    public var body: some View {
        Canvas { context, size in
            let unit = min(size.width / 38, size.height / 28)
            let origin = CGPoint(x: (size.width - 38 * unit) / 2, y: (size.height - 28 * unit) / 2)
            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(x: origin.x + x * unit, y: origin.y + y * unit)
            }

            // One streamline, bowing away from the sphere and running straight behind it, so the mark moves left to right. `side` is -1 above and 1 below.
            func streamline(rest: CGFloat, peak: CGFloat, side: CGFloat) -> Path {
                var path = Path()
                path.move(to: point(1, 14 + side * rest))
                path.addCurve(
                    to: point(12, 14 + side * peak),
                    control1: point(5, 14 + side * rest),
                    control2: point(7.5, 14 + side * peak)
                )
                path.addCurve(
                    to: point(26, 14 + side * rest),
                    control1: point(16.5, 14 + side * peak),
                    control2: point(20, 14 + side * rest)
                )
                path.addLine(to: point(37, 14 + side * rest))
                return path
            }

            let style = StrokeStyle(lineWidth: 1.4 * unit, lineCap: .round)
            for side in [CGFloat(-1), 1] {
                context.stroke(
                    streamline(rest: 3.6, peak: 6.9, side: side),
                    with: .color(SamadhiColor.ink.opacity(0.9)),
                    style: style
                )
                context.stroke(
                    streamline(rest: 8.6, peak: 11, side: side),
                    with: .color(SamadhiColor.ink.opacity(0.45)),
                    style: style
                )
            }

            let center = point(12, 14)
            let radius = 4.4 * unit
            context.fill(
                Path(
                    ellipseIn: CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                ),
                with: .color(SamadhiColor.line)
            )
        }
        .accessibilityHidden(true)
    }
}
