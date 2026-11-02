import SwiftUI

// Reading progress as a plucked string. Each song read plucks it, and the ripple that follows takes
// its tightness from that song's measured tempo, so a fast song visibly shivers and a slow one
// rolls. The string is only as long as the songs really read, and the rest of the way stays still.
struct PluckedString: View {
    let progress: Double
    let crests: Double
    let plucks: Int
    let reduceMotion: Bool

    @State private var pluckedAt: TimeInterval = 0

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            PluckedStringCanvas(
                progress: progress,
                crests: crests,
                now: reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate,
                pluckedAt: pluckedAt,
                isAnimated: !reduceMotion
            )
            .animation(reduceMotion ? nil : .spring(duration: 0.6, bounce: 0.22), value: progress)
            .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: crests)
        }
        .frame(height: 30)
        .onChange(of: plucks) {
            pluckedAt = Date.timeIntervalSinceReferenceDate
        }
        .accessibilityHidden(true)
    }
}

private struct PluckedStringCanvas: View, @preconcurrency Animatable {
    var progress: Double
    var crests: Double
    let now: TimeInterval
    let pluckedAt: TimeInterval
    let isAnimated: Bool

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(progress, crests) }
        set {
            progress = newValue.first
            crests = newValue.second
        }
    }

    var body: some View {
        Canvas { context, size in
            let inset = 7.0
            let width = max(size.width - inset * 2, 1)
            let middle = size.height / 2
            let head = inset + width * min(max(progress, 0), 1)
            let end = inset + width
            let sincePluck = max(now - pluckedAt, 0)

            var rest = Path()
            rest.move(to: CGPoint(x: head, y: middle))
            rest.addLine(to: CGPoint(x: end, y: middle))
            context.stroke(
                rest,
                with: .color(SamadhiColor.ink.opacity(0.2)),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
            )
            context.fill(
                Path(ellipseIn: CGRect(x: end - 1.75, y: middle - 1.75, width: 3.5, height: 3.5)),
                with: .color(SamadhiColor.ink.opacity(0.32))
            )

            // Pinned at both ends. A quick decaying bow is the pluck, and the ripple is the song.
            let length = max(head - inset, 0.001)
            let ripple = isAnimated ? 1.5 + 3.5 * exp(-2.2 * sincePluck) : 0
            let bow = isAnimated ? 5 * exp(-3 * sincePluck) * cos(20 * sincePluck) : 0
            var drawn = Path()
            drawn.move(to: CGPoint(x: inset, y: middle))
            var x = inset + 2.5
            while x < head {
                let along = (x - inset) / length
                let pinned = sin(.pi * along)
                let wave = sin(2 * .pi * crests * (x - inset) / width - now * 4)
                drawn.addLine(to: CGPoint(x: x, y: middle + pinned * (bow + ripple * wave)))
                x += 2.5
            }
            drawn.addLine(to: CGPoint(x: head, y: middle))
            context.stroke(
                drawn,
                with: .color(SamadhiColor.clay),
                style: StrokeStyle(lineWidth: 2.25, lineCap: .round, lineJoin: .round)
            )

            let radius = isAnimated ? 4.5 + 2 * exp(-7 * sincePluck) : 4.5
            context.fill(
                Path(ellipseIn: CGRect(x: head - radius, y: middle - radius, width: radius * 2, height: radius * 2)),
                with: .color(SamadhiColor.clay)
            )
        }
    }
}

// The playlist name arrives letter by letter out of a soft blur. It runs only when a playlist is
// chosen, because a name that is already there when the app opens has nothing to announce.
struct TitleRiseTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content.textRenderer(TitleRiseRenderer(progress: phase.isIdentity ? 1 : 0))
    }
}

private struct TitleRiseRenderer: TextRenderer, Animatable {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let slices = layout.flatMap { $0 }.flatMap { $0 }
        let count = max(slices.count, 1)
        for (index, slice) in slices.enumerated() {
            let start = Double(index) / Double(count) * 0.55
            let local = min(max((progress - start) / 0.45, 0), 1)
            let eased = 1 - pow(1 - local, 3)
            var copy = context
            copy.opacity = eased
            copy.translateBy(x: 0, y: (1 - eased) * 14)
            if eased < 1 {
                copy.addFilter(.blur(radius: (1 - eased) * 5))
            }
            copy.draw(slice)
        }
    }
}
