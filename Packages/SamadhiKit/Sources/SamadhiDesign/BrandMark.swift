import SwiftUI

public struct BrandMark: View {
    let inverted: Bool

    public init(inverted: Bool = false) {
        self.inverted = inverted
    }

    public var body: some View {
        Canvas { context, size in
            let scaleX = size.width / 38
            let scaleY = size.height / 28

            var ribbon = Path()
            ribbon.move(to: CGPoint(x: 3 * scaleX, y: 18 * scaleY))
            ribbon.addCurve(
                to: CGPoint(x: 22 * scaleX, y: 11 * scaleY),
                control1: CGPoint(x: 10 * scaleX, y: 5 * scaleY),
                control2: CGPoint(x: 13 * scaleX, y: 28 * scaleY)
            )
            ribbon.addCurve(
                to: CGPoint(x: 35 * scaleX, y: 13 * scaleY),
                control1: CGPoint(x: 27 * scaleX, y: 4 * scaleY),
                control2: CGPoint(x: 32 * scaleX, y: 7 * scaleY)
            )

            context.stroke(
                ribbon,
                with: .linearGradient(
                    Gradient(colors: inverted
                        ? [SamadhiColor.ivory, SamadhiColor.apricot, SamadhiColor.ivory]
                        : [SamadhiColor.plum, SamadhiColor.clay, SamadhiColor.olive]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: size.width, y: size.height)
                ),
                style: StrokeStyle(lineWidth: 4.2 * min(scaleX, scaleY), lineCap: .round, lineJoin: .round)
            )

            let sparkRect = CGRect(x: 28 * scaleX, y: 2 * scaleY, width: 4.2 * scaleX, height: 4.2 * scaleY)
            context.fill(Path(ellipseIn: sparkRect), with: .color(inverted ? SamadhiColor.ivory : SamadhiColor.clay))
        }
        .shadow(color: inverted ? SamadhiColor.ink.opacity(0.34) : SamadhiColor.ivory.opacity(0.68), radius: 8, y: 3)
        .accessibilityHidden(true)
    }
}
