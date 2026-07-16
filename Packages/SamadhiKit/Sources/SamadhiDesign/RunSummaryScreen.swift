import SamadhiDomain
import SwiftUI

struct RunSummaryScreen: View {
    let summary: RunSummary
    let send: @MainActor (RunAction) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                BrandMark()
                    .frame(width: 40, height: 30)
                    .padding(.top, Space.x8)

                Spacer(minLength: Space.x8)

                Text("Run complete")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(SamadhiColor.ink.opacity(0.72))
                Text(RunDurationText.formatted(summary.durationSeconds))
                    .font(.system(size: 68, weight: .medium, design: .serif).monospacedDigit())
                    .tracking(-2)
                    .accessibilityLabel(RunDurationText.spoken(summary.durationSeconds))
                    .accessibilityAddTraits(.isHeader)
                Text("total time")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(SamadhiColor.ink.opacity(0.62))

                SummaryRhythmGauge(percent: summary.tempoMatchedPercent)
                    .frame(maxWidth: 330)
                    .padding(.top, Space.x8)

                SummaryMetricRail(summary: summary)
                    .frame(maxWidth: 330)
                    .padding(.top, Space.x6)

                Spacer(minLength: Space.x8)

                Button(action: done) {
                    Text("Done")
                        .font(.headline)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        .frame(width: 164, height: 58)
                }
                .buttonStyle(.glassProminent)
                .tint(SamadhiColor.clay)
                .accessibilityIdentifier("summary-done")

                Spacer(minLength: Space.x8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Space.x8)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("run-summary")
    }

    private func done() {
        send(.done)
    }
}

private struct SummaryMetricRail: View {
    let summary: RunSummary

    private var cadence: String {
        summary.averageCadence.map(String.init) ?? "Fixed"
    }

    private var cadenceLabel: String {
        summary.averageCadence == nil ? "rhythm" : "avg cadence"
    }

    private var cadenceSpoken: String {
        summary.averageCadence.map { "\($0) steps per minute" } ?? "Fixed rhythm"
    }

    private var songsLabel: String {
        summary.songCount == 1 ? "song" : "songs"
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) {
                SummaryMetric(
                    value: cadence,
                    label: cadenceLabel,
                    spokenValue: cadenceSpoken,
                    layout: .column
                )
                Rectangle()
                    .fill(SamadhiColor.ink.opacity(0.14))
                    .frame(width: 1, height: 46)
                SummaryMetric(
                    value: "\(summary.songCount)",
                    label: songsLabel,
                    spokenValue: "\(summary.songCount) \(songsLabel)",
                    layout: .column
                )
            }

            VStack(spacing: Space.x4) {
                SummaryMetric(
                    value: cadence,
                    label: cadenceLabel,
                    spokenValue: cadenceSpoken,
                    layout: .row
                )
                SummaryMetric(
                    value: "\(summary.songCount)",
                    label: songsLabel,
                    spokenValue: "\(summary.songCount) \(songsLabel)",
                    layout: .row
                )
            }
        }
    }
}

private struct SummaryMetric: View {
    enum Layout {
        case row
        case column
    }

    let value: String
    let label: String
    let spokenValue: String
    let layout: Layout

    var body: some View {
        Group {
            switch layout {
            case .column:
                VStack(spacing: Space.x1) {
                    valueText
                    labelText.font(.caption.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
            case .row:
                HStack(alignment: .firstTextBaseline, spacing: Space.x2) {
                    valueText
                    labelText.font(.body.weight(.medium))
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenValue)
    }

    private var valueText: some View {
        Text(value)
            .font(.title2.monospacedDigit().weight(.bold))
    }

    private var labelText: some View {
        Text(label)
            .foregroundStyle(SamadhiColor.ink.opacity(0.68))
    }
}

private struct SummaryRhythmGauge: View {
    let percent: Int?

    private var progress: Double {
        Double(percent ?? 0) / 100
    }

    var body: some View {
        VStack(spacing: Space.x2) {
            HStack(alignment: .firstTextBaseline) {
                Text("Tempo matched")
                    .font(.callout.weight(.semibold))
                Spacer()
                Text(percent.map { "\($0)%" } ?? "Not measured")
                    .font(.title3.monospacedDigit().weight(.bold))
            }

            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 3, y: size.height * 0.58))
                path.addCurve(
                    to: CGPoint(x: size.width - 3, y: size.height * 0.42),
                    control1: CGPoint(x: size.width * 0.3, y: -size.height * 0.08),
                    control2: CGPoint(x: size.width * 0.7, y: size.height * 1.08)
                )

                context.stroke(
                    path,
                    with: .color(SamadhiColor.ink.opacity(0.14)),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                context.stroke(
                    path.trimmedPath(from: 0, to: min(max(progress, 0), 1)),
                    with: .linearGradient(
                        Gradient(
                            colors: [
                                SamadhiColor.clay,
                                SamadhiColor.apricot,
                                SamadhiColor.olive,
                            ]
                        ),
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: size.height)
                    ),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
            }
            .frame(height: 42)
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            percent.map { "Tempo matched for \($0) percent of the run" }
                ?? "Tempo matching not measured"
        )
    }
}
