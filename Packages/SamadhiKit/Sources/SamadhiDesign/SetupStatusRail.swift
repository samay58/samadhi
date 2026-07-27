import SwiftUI

struct SetupStatusRail: View {
    let selection: MusicSelectionPresentation
    let reduceMotion: Bool
    let presentTrackDetails: @MainActor (ImportedCollectionPresentation) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: statusAlignment) {
            status
                .id(selection.visualStage)
                .transition(setupTransition(reduceMotion: reduceMotion))
        }
        .frame(
            maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 320,
            minHeight: dynamicTypeSize.isAccessibilitySize ? nil : 76,
            alignment: statusAlignment
        )
        .animation(
            reduceMotion ? nil : .easeOut(duration: MotionToken.feedback),
            value: selection.visualStage
        )
        .accessibilitySortPriority(3)
    }

    private var statusAlignment: Alignment {
        dynamicTypeSize.isAccessibilitySize ? .leading : .center
    }

    @ViewBuilder
    private var status: some View {
        switch selection {
        case .none, .loadingPlaylists:
            EmptyView()
        case let .analyzing(collection):
            AnalysisProgressRail(collection: collection, reduceMotion: reduceMotion)
                .accessibilityIdentifier("music-analyzing")
        case let .ready(collection):
            ReadinessStatus(collection: collection, presentTrackDetails: presentTrackDetails)
                .accessibilityIdentifier("music-ready")
        case let .failed(failure):
            SetupFailureStatus(failure: failure)
                .accessibilityIdentifier("music-import-failed")
        }
    }
}

private struct AnalysisProgressRail: View {
    let collection: ImportedCollectionPresentation
    let reduceMotion: Bool

    var body: some View {
        if collection.totalTrackCount > 0 {
            VStack(alignment: .leading, spacing: Space.x3) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Reading rhythm")
                    Spacer(minLength: Space.x6)
                    Text("\(collection.completedTrackCount) / \(collection.totalTrackCount)")
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .accessibilityHidden(true)
                }
                .font(.body.weight(.medium))
                .foregroundStyle(SamadhiColor.ink.opacity(0.8))

                TruthfulProgressRail(progress: progress, reduceMotion: reduceMotion)
            }
            .frame(maxWidth: 320)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Playlist analysis progress")
            .accessibilityValue(
                "\(collection.completedTrackCount) of \(collection.totalTrackCount) tracks analyzed"
            )
            .accessibilityIdentifier("music-analysis-progress")
        } else {
            HStack(spacing: Space.x3) {
                ProgressView()
                    .controlSize(.small)
                    .tint(SamadhiColor.clay)
                Text("Opening playlist")
                    .font(.body.weight(.medium))
            }
            .foregroundStyle(SamadhiColor.ink.opacity(0.78))
            .frame(minHeight: 44)
            .accessibilityElement(children: .combine)
        }
    }

    private var progress: Double {
        guard collection.totalTrackCount > 0 else { return 0 }
        return min(max(Double(collection.completedTrackCount) / Double(collection.totalTrackCount), 0), 1)
    }
}

private struct TruthfulProgressRail: View {
    let progress: Double
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 0)
            let fillWidth = width * progress

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(SamadhiColor.ink.opacity(0.12))
                    .frame(height: 3)
                Capsule()
                    .fill(SamadhiColor.clay)
                    .frame(width: fillWidth, height: 3)
                if progress > 0 {
                    Circle()
                        .fill(SamadhiColor.clay)
                        .frame(width: 7, height: 7)
                        .offset(x: min(max(fillWidth - 3.5, 0), max(width - 7, 0)))
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 9)
        .animation(reduceMotion ? nil : .easeOut(duration: MotionToken.feedback), value: progress)
        .accessibilityHidden(true)
    }
}

private struct ReadinessStatus: View {
    let collection: ImportedCollectionPresentation
    let presentTrackDetails: @MainActor (ImportedCollectionPresentation) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(
            alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center,
            spacing: collection.skippedTrackCount > 0 ? 0 : Space.x2
        ) {
            Text(readyTrackCount)
                .font(.body.weight(.medium))
                .foregroundStyle(SamadhiColor.ink.opacity(0.78))
                .frame(minHeight: 34)
                .accessibilityIdentifier("ready-track-count")

            if collection.skippedTrackCount > 0 {
                Button {
                    presentTrackDetails(collection)
                } label: {
                    Text("Review \(collection.skippedTrackCount) skipped")
                        .font(.callout.weight(.semibold))
                        .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .center)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
                .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                .accessibilityLabel("Review \(collection.skippedTrackCount) skipped tracks")
                .accessibilityHint("Shows the result for every imported track")
                .accessibilityIdentifier("review-skipped-tracks")
            }
        }
        .frame(maxWidth: .infinity, alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center)
        .accessibilityElement(children: .contain)
    }

    private var readyTrackCount: String {
        collection.readyTrackCount == 1
            ? "1 track ready"
            : "\(collection.readyTrackCount) tracks ready"
    }
}

private struct SetupFailureStatus: View {
    let failure: MusicSelectionFailurePresentation

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(
            alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center,
            spacing: Space.x3
        ) {
            if failure.playlistName != nil {
                Text(failure.title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .center)
            }
            if let message = failure.message {
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .center)
                    .foregroundStyle(SamadhiColor.ink.opacity(0.76))
                    .frame(maxWidth: 360, alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center)
            }
        }
    }
}
