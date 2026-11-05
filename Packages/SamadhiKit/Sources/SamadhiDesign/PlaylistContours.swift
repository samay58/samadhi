import SwiftUI

// One contour line per song that was read. Each line shows two seconds of that song's measured
// beat, so a faster song ripples tighter and no two playlists draw the same map. A song that could
// not be read leaves a gap where it would have been. This is real data, not decoration.
public struct PlaylistContourLine: Equatable, Identifiable, Sendable {
    public let id: String
    let position: Double
    let crests: Double
    let seed: Double
}

enum PlaylistContourMap {
    static let maximumLines = 28
    static let secondsShown = 2.0

    static func lines(
        for tracks: [ImportedTrackPresentation],
        totalCount: Int
    ) -> [PlaylistContourLine] {
        let total = max(totalCount, tracks.count)
        guard total > 0 else { return [] }

        // A long playlist keeps one song per band, so the map thins out instead of turning solid.
        let bandCount = min(total, maximumLines)
        return (0..<bandCount).compactMap { band in
            let range = (band * total / bandCount)..<((band + 1) * total / bandCount)
            let song = range.lazy
                .filter { $0 < tracks.count }
                .compactMap { index -> (ImportedTrackPresentation, Double)? in
                    guard tracks[index].status == .ready,
                        let bpm = tracks[index].pulseBPM,
                        bpm > 0
                    else { return nil }
                    return (tracks[index], bpm)
                }
                .first
            guard let (track, bpm) = song else { return nil }
            return PlaylistContourLine(
                id: track.id,
                position: bandCount == 1 ? 0.5 : Double(band) / Double(bandCount - 1),
                crests: bpm / 60 * secondsShown,
                // The golden ratio spreads the peaks so neighboring lines never line up in a column.
                seed: (Double(band) * 0.618_034).truncatingRemainder(dividingBy: 1)
            )
        }
    }
}

extension ImportedCollectionPresentation {
    var latestReadTitle: String? {
        tracks.last { $0.status != .pending }?.title
    }

    var latestReadBPM: Int? {
        tracks.last { $0.status != .pending }?.pulseBPM.map { Int($0.rounded()) }
    }
}

extension MusicSelectionPresentation {
    private var contourCollection: ImportedCollectionPresentation? {
        switch self {
        case let .analyzing(collection), let .ready(collection):
            collection
        case let .loadingPlaylists(current):
            current
        case .none, .failed:
            nil
        }
    }

    // Nil means no playlist yet, and the field shows its plain resting lines.
    var contourLines: [PlaylistContourLine]? {
        contourCollection.map {
            PlaylistContourMap.lines(for: $0.tracks, totalCount: $0.totalTrackCount)
        }
    }

    // The field stills when reading begins and its color comes up with each song, reaching full bloom only
    // when the work is really done. Progress is the count of songs read, never a timer.
    var fieldBloom: Double {
        switch self {
        case .none, .failed, .loadingPlaylists(current: nil):
            return 0.55
        case .loadingPlaylists(current: .some), .ready:
            return 1
        case let .analyzing(collection):
            guard collection.totalTrackCount > 0 else { return 0.25 }
            let progress = Double(collection.completedTrackCount) / Double(collection.totalTrackCount)
            return 0.25 + 0.75 * min(max(progress, 0), 1)
        }
    }

    var isReadyToRun: Bool {
        guard case let .ready(collection) = self else { return false }
        return collection.readyTrackCount > 0
    }
}

struct PlaylistContourCanvas: View {
    static let drawStagger: TimeInterval = 0.14
    static let settleDuration: TimeInterval = 1.7

    static let drawDuration: TimeInterval = 0.95
    private static let heatFade: TimeInterval = 1.6
    private static let swellDuration: TimeInterval = 1.1
    private static let swellSpread: TimeInterval = 0.55

    let lines: [PlaylistContourLine]
    let births: [String: TimeInterval]
    let settledAt: TimeInterval?
    let now: TimeInterval
    let isAnimated: Bool
    let ink: Color
    let accent: Color
    // Setup leaves a clearing for the playlist name, so the map frames it and never crosses it.
    let leavesClearing: Bool

    var body: some View {
        Canvas { context, size in
            for line in lines {
                draw(line, in: &context, size: size)
            }
        }
    }

    private func draw(_ line: PlaylistContourLine, in context: inout GraphicsContext, size: CGSize) {
        let age: Double? = isAnimated ? births[line.id].map { now - $0 } : nil
        if let age, age < 0 { return }

        let drawn: Double = age.map(Self.drawnFraction) ?? 1
        let heat: Double = age.map(Self.heat) ?? 0
        let swell = swellAmount(for: line)

        let width = Double(size.width)
        let baseY: Double = Double(size.height) * screenFraction(for: line.position)
        let amplitude: Double = 8 + swell * 10
        let drift: Double = now * line.crests * 0.11
        let peak: Double = 0.5 + (line.seed - 0.5) * 0.4

        func y(atFraction fraction: Double) -> Double {
            // Calm at the edges and tallest near one peak, like a ridgeline.
            let distance: Double = (fraction - peak) / 0.26
            let envelope: Double = 0.16 + 0.84 * exp(-(distance * distance))
            let cycles: Double = line.crests * fraction + line.seed
            let phase: Double = 2 * Double.pi * cycles - drift
            return baseY + amplitude * envelope * sin(phase)
        }

        let end: Double = width * drawn
        var path = Path()
        path.move(to: CGPoint(x: 0, y: y(atFraction: 0)))
        var x = 6.0
        while x < end {
            path.addLine(to: CGPoint(x: x, y: y(atFraction: x / width)))
            x += 6
        }
        let tip = CGPoint(x: end, y: y(atFraction: end / width))
        path.addLine(to: tip)

        let base = heat > 0 ? ink.mix(with: accent, by: heat) : ink
        let color = base.opacity(0.15 + swell * 0.2 + heat * 0.55)
        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle(lineWidth: 0.85 + heat * 0.5, lineCap: .round, lineJoin: .round)
        )

        if drawn < 1 {
            let radius = 2.4
            context.fill(
                Path(ellipseIn: CGRect(x: tip.x - radius, y: tip.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(accent)
            )
        }
    }

    private static func drawnFraction(age: Double) -> Double {
        let remaining: Double = 1 - min(age / drawDuration, 1)
        return 1 - remaining * remaining * remaining
    }

    private static func heat(age: Double) -> Double {
        let cooling: Double = max(age - drawDuration * 0.5, 0) / heatFade
        return max(0, 1 - cooling)
    }

    private func screenFraction(for position: Double) -> Double {
        // The first band starts below the mark, so no line ever runs through it.
        guard leavesClearing else { return 0.18 + position * 0.71 }
        // Two bands, one between the logo and the name and one below the status.
        let upper = 0.20
        let lower = 0.29
        let travelled = position * (upper + lower)
        return travelled < upper ? 0.16 + travelled : 0.60 + (travelled - upper)
    }

    // When the last song is read, one soft swell passes down the map from top to bottom.
    private func swellAmount(for line: PlaylistContourLine) -> Double {
        guard isAnimated, let settledAt else { return 0 }
        let elapsed = now - settledAt - line.position * Self.swellSpread
        guard elapsed > 0, elapsed < Self.swellDuration else { return 0 }
        return sin(.pi * elapsed / Self.swellDuration)
    }
}
