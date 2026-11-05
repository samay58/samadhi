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
            minHeight: dynamicTypeSize.isAccessibilitySize ? nil : 100,
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

    @ScaledMetric(relativeTo: .title3) private var songSize = 21.0

    var body: some View {
        if collection.totalTrackCount > 0 {
            VStack(spacing: Space.x3) {
                PluckedString(
                    progress: progress,
                    crests: stringCrests,
                    plucks: collection.completedTrackCount,
                    reduceMotion: reduceMotion
                )
                .frame(maxWidth: 264)

                VStack(spacing: Space.x1) {
                    songName
                    readings
                }
            }
            .frame(maxWidth: 320)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Playlist analysis progress")
            .accessibilityValue(
                "\(collection.completedTrackCount) of \(collection.totalTrackCount) songs read"
            )
            .accessibilityIdentifier("music-analysis-progress")
        } else {
            HStack(spacing: Space.x3) {
                ProgressView()
                    .controlSize(.small)
                    .tint(SamadhiColor.line)
                Text("Opening playlist")
                    .font(.body.weight(.medium))
            }
            .foregroundStyle(SamadhiColor.ink.opacity(0.78))
            .frame(minHeight: 44)
            .accessibilityElement(children: .combine)
        }
    }

    // Your own songs pass through here as they are read.
    private var songName: some View {
        let name = collection.latestReadTitle ?? "Reading rhythm"
        return ZStack {
            Text(name)
                .font(.system(size: songSize, design: .serif).italic())
                .foregroundStyle(SamadhiColor.ink.opacity(0.92))
                .lineLimit(1)
                .id(name)
                .transition(songTransition)
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: name)
    }

    private var songTransition: AnyTransition {
        if reduceMotion { return .identity }
        return .asymmetric(
            insertion: AnyTransition(.blurReplace(.downUp)).combined(with: .offset(y: 8)),
            removal: .opacity.combined(with: .offset(y: -6))
        )
    }

    private var readings: some View {
        HStack(spacing: 6) {
            if let bpm = collection.latestReadBPM {
                Text("\(bpm) BPM")
                    .contentTransition(.numericText(value: Double(bpm)))
                Text("·")
            }
            Text("\(collection.completedTrackCount) of \(collection.totalTrackCount)")
                .contentTransition(.numericText(value: Double(collection.completedTrackCount)))
        }
        .font(.footnote.weight(.medium).monospacedDigit())
        .foregroundStyle(SamadhiColor.ink.opacity(0.74))
        .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: collection.completedTrackCount)
    }

    private var stringCrests: Double {
        Double(collection.latestReadBPM ?? 120) / 60 * PlaylistContourMap.secondsShown
    }

    private var progress: Double {
        guard collection.totalTrackCount > 0 else { return 0 }
        return min(max(Double(collection.completedTrackCount) / Double(collection.totalTrackCount), 0), 1)
    }
}

private struct ReadinessStatus: View {
    let collection: ImportedCollectionPresentation
    let presentTrackDetails: @MainActor (ImportedCollectionPresentation) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var readySize = 21.0

    var body: some View {
        VStack(
            alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center,
            spacing: collection.skippedTrackCount > 0 ? 0 : Space.x2
        ) {
            Text(readyTrackCount)
                .font(.system(size: readySize, design: .serif).italic())
                .foregroundStyle(SamadhiColor.ink.opacity(0.92))
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
                .accessibilityLabel("Review \(collection.skippedTrackCount) skipped songs")
                .accessibilityHint("Shows the result for every imported song")
                .accessibilityIdentifier("review-skipped-tracks")
            }
        }
        .frame(maxWidth: .infinity, alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center)
        .accessibilityElement(children: .contain)
    }

    private var readyTrackCount: String {
        collection.readyTrackCount == 1
            ? "1 song ready"
            : "\(collection.readyTrackCount) songs ready"
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
