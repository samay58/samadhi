import SwiftUI

struct ReadyScreen: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var identityFontSize = 46.0
    @State private var trackDetails: TrackDetailsPresentation?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    BrandMark()
                        .frame(width: 38, height: 28)
                        .padding(.top, Space.x8)

                    Spacer(minLength: dynamicTypeSize.isAccessibilitySize ? Space.x8 : Space.x12)

                    setupCenterpiece

                    Spacer(minLength: dynamicTypeSize.isAccessibilitySize ? Space.x8 : Space.x12)

                    setupActions
                        .padding(.bottom, Space.x8)
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                .padding(.horizontal, Space.x6)
            }
            .scrollIndicators(.hidden)
        }
        .accessibilityIdentifier("ready-screen")
        .sheet(item: $trackDetails) { details in
            TrackResultsSheet(collection: details.collection) {
                send(.retryMusicImport)
            }
        }
    }

    private var setupCenterpiece: some View {
        VStack(spacing: Space.x6) {
            identity
            stateDetail
        }
        .frame(maxWidth: 420)
    }

    @ViewBuilder
    private var identity: some View {
        switch state.musicSelection {
        case .none, .loadingPlaylists(current: nil):
            identityText("Music in stride")
        case let .loadingPlaylists(current: collection?):
            identityText(collection.name)
        case let .analyzing(collection), let .ready(collection):
            identityText(collection.name)
        case let .failed(failure):
            if let playlistName = failure.playlistName {
                identityText(playlistName)
            } else {
                identityText(failure.title)
            }
        }
    }

    private func identityText(_ text: String) -> some View {
        Text(text)
            .font(
                .system(
                    size: min(identityFontSize, dynamicTypeSize.isAccessibilitySize ? 64 : 54),
                    weight: .medium,
                    design: .serif
                )
            )
            .tracking(-0.8)
            .multilineTextAlignment(.center)
            .foregroundStyle(SamadhiColor.ink)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var stateDetail: some View {
        switch state.musicSelection {
        case .none:
            EmptyView()
        case .loadingPlaylists:
            EmptyView()
        case let .analyzing(collection):
            VStack {
                AnalysisProgressView(collection: collection, reduceMotion: reduceMotion)
            }
            .accessibilityIdentifier("music-analyzing")
        case let .ready(collection):
            VStack {
                readinessStatus(collection)
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("music-ready")
        case let .failed(failure):
            VStack {
                failureStatus(failure)
            }
            .accessibilityIdentifier("music-import-failed")
        }
    }

    @ViewBuilder
    private func readinessStatus(
        _ collection: ImportedCollectionPresentation
    ) -> some View {
        if collection.skippedTrackCount > 0 {
            let summary =
                "\(collection.readyTrackCount) ready · Review \(collection.skippedTrackCount) skipped"
            let accessibilitySummary =
                "\(collection.readyTrackCount) ready, \(collection.skippedTrackCount) skipped"
            Button {
                presentTrackDetails(collection)
            } label: {
                Text(summary)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .foregroundStyle(SamadhiColor.ink.opacity(0.8))
            .accessibilityLabel(accessibilitySummary)
            .accessibilityHint("Shows the result for every imported track")
            .accessibilityIdentifier("all-imported-tracks")
        } else {
            Text(readyTrackCount(collection.readyTrackCount))
                .font(.body.weight(.medium))
                .foregroundStyle(SamadhiColor.ink.opacity(0.78))
                .frame(minHeight: 44)
        }
    }

    private func failureStatus(
        _ failure: MusicSelectionFailurePresentation
    ) -> some View {
        VStack(spacing: Space.x3) {
            if failure.playlistName != nil {
                Text(failure.title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
            }
            if let message = failure.message {
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SamadhiColor.ink.opacity(0.76))
                    .frame(maxWidth: 330)
            }
        }
    }

    @ViewBuilder
    private var setupActions: some View {
        VStack(spacing: Space.x2) {
            switch state.musicSelection {
            case .none:
                primaryButton("Choose music", identifier: "choose-music") {
                    send(.chooseMusic)
                }
                .accessibilityHint("Opens your Apple Music playlists")

            case .loadingPlaylists:
                loadingButton

            case .analyzing:
                secondaryButton("Choose another", identifier: "choose-another-music") {
                    send(.changeMusic)
                }

            case let .ready(collection):
                if collection.readyTrackCount > 0 {
                    primaryButton("Start", identifier: "start-run", action: start)
                        .accessibilityHint("Starts the music and listens for your stride")
                    secondaryButton("Change playlist", identifier: "change-music") {
                        send(.changeMusic)
                    }
                } else if collection.hasTemporaryFailures {
                    primaryButton("Retry playlist", identifier: "retry-music-import") {
                        send(.retryMusicImport)
                    }
                    secondaryButton("Choose another", identifier: "choose-another-music") {
                        send(.changeMusic)
                    }
                } else {
                    primaryButton("Choose another", identifier: "choose-another-music") {
                        send(.changeMusic)
                    }
                }

            case let .failed(failure):
                failureActions(failure)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func failureActions(
        _ failure: MusicSelectionFailurePresentation
    ) -> some View {
        switch failure {
        case .authorizationDenied:
            primaryButton("Open Settings", identifier: "open-settings") {
                send(.openSettings)
            }
            secondaryButton("Try again", identifier: "retry-playlist-library") {
                send(.chooseMusic)
            }
        case .savedCollectionUnavailable:
            primaryButton("Choose music", identifier: "choose-music") {
                send(.chooseMusic)
            }
        case .playlistLibraryUnavailable:
            primaryButton("Try again", identifier: "retry-playlist-library") {
                send(.chooseMusic)
            }
        case .emptyPlaylist:
            primaryButton("Choose another", identifier: "choose-another-music") {
                send(.changeMusic)
            }
        case .playlistUnavailable, .importFailed:
            primaryButton("Retry playlist", identifier: "retry-music-import") {
                send(.retryMusicImport)
            }
            secondaryButton("Choose another", identifier: "choose-another-music") {
                send(.changeMusic)
            }
        }
    }

    private func primaryButton(
        _ title: String,
        identifier: String,
        action: @escaping @MainActor () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                .padding(.horizontal, Space.x2)
                .frame(minWidth: 132, minHeight: 48)
        }
        .buttonStyle(.glassProminent)
        .tint(SamadhiColor.clay)
        .accessibilityIdentifier(identifier)
    }

    private var loadingButton: some View {
        Button {
        } label: {
            HStack(spacing: Space.x3) {
                ProgressView()
                    .controlSize(.small)
                    .tint(SamadhiColor.ink.opacity(0.66))
                Text("Opening playlists")
                    .font(.headline)
            }
            .padding(.horizontal, Space.x2)
            .frame(minWidth: 164, minHeight: 48)
        }
        .buttonStyle(.glassProminent)
        .tint(SamadhiColor.clay)
        .disabled(true)
        .accessibilityLabel("Opening Apple Music playlists")
        .accessibilityIdentifier("music-loading")
    }

    private func secondaryButton(
        _ title: String,
        identifier: String,
        action: @escaping @MainActor () -> Void
    ) -> some View {
        Button(title, action: action)
            .font(.callout.weight(.semibold))
            .foregroundStyle(SamadhiColor.ink.opacity(0.82))
            .frame(minWidth: 152, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityIdentifier(identifier)
    }

    private func presentTrackDetails(_ collection: ImportedCollectionPresentation) {
        trackDetails = TrackDetailsPresentation(collection: collection)
    }

    private func readyTrackCount(_ count: Int) -> String {
        count == 1 ? "1 track ready" : "\(count) tracks ready"
    }

    private func start() {
        send(.start)
    }
}

private struct AnalysisProgressView: View {
    let collection: ImportedCollectionPresentation
    let reduceMotion: Bool

    var body: some View {
        if collection.totalTrackCount > 0 {
            VStack(spacing: Space.x3) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Reading rhythm")
                    Spacer()
                    Text("\(collection.completedTrackCount) / \(collection.totalTrackCount)")
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                .font(.body.weight(.medium))
                .foregroundStyle(SamadhiColor.ink.opacity(0.8))

                ProgressView(
                    value: Double(collection.completedTrackCount),
                    total: Double(collection.totalTrackCount)
                )
                .tint(SamadhiColor.clay)
                .animation(
                    reduceMotion ? nil : .easeOut(duration: MotionToken.feedback),
                    value: collection.completedTrackCount
                )
                .accessibilityLabel("Playlist analysis progress")
                .accessibilityValue(
                    "\(collection.completedTrackCount) of \(collection.totalTrackCount) tracks analyzed"
                )
                .accessibilityIdentifier("music-analysis-progress")
            }
            .frame(maxWidth: 300)
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
}

private struct TrackDetailsPresentation: Identifiable {
    let id = UUID()
    let collection: ImportedCollectionPresentation
}

private struct TrackResultsSheet: View {
    let collection: ImportedCollectionPresentation
    let retry: @MainActor () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                FluidMusicField(
                    mode: .ready,
                    usesCollectionPalette: false,
                    reduceMotionOverride: true,
                    animates: false
                )
                .ignoresSafeArea()

                List {
                    trackSection("Ready", status: .ready)
                    trackSection("Rhythm unclear", status: .rhythmUnclear)
                    trackSection("Preview unavailable", status: .previewUnavailable)
                    trackSection("Could not match Apple Music item", status: .catalogMatchUnavailable)
                    trackSection("Temporary download or decode failure", status: .temporaryFailure)
                    trackSection("Waiting", status: .pending)

                    if collection.hasTemporaryFailures {
                        Section {
                            Button("Retry temporary failures") {
                                dismiss()
                                retry()
                            }
                            .frame(minHeight: 44)
                            .accessibilityIdentifier("retry-temporary-imports")
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 52)
            }
            .navigationTitle(collection.name)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationBackground(SamadhiColor.parchment)
        .accessibilityIdentifier("track-results-sheet")
    }

    @ViewBuilder
    private func trackSection(
        _ title: String,
        status: MusicTrackImportPresentation
    ) -> some View {
        let tracks = collection.tracks.filter { $0.status == status }
        if !tracks.isEmpty {
            Section {
                ForEach(tracks) { track in
                    Text(track.title)
                        .font(.body)
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(SamadhiColor.ink.opacity(0.14))
                }
            } header: {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(SamadhiColor.ink.opacity(0.7))
                    .textCase(nil)
            }
        }
    }
}

private extension MusicSelectionFailurePresentation {
    var playlistName: String? {
        switch self {
        case let .emptyPlaylist(name), let .playlistUnavailable(name), let .importFailed(name):
            name
        case .authorizationDenied, .savedCollectionUnavailable, .playlistLibraryUnavailable:
            nil
        }
    }

    var title: String {
        switch self {
        case .authorizationDenied:
            "Apple Music access is off"
        case .savedCollectionUnavailable:
            "Saved music did not open"
        case .playlistLibraryUnavailable:
            "Playlists did not open"
        case .emptyPlaylist:
            "This playlist is empty"
        case .playlistUnavailable:
            "Playlist did not open"
        case .importFailed:
            "Analysis stopped"
        }
    }

    var message: String? {
        switch self {
        case .authorizationDenied:
            "Allow Apple Music access in Settings, then try again."
        case .savedCollectionUnavailable, .playlistLibraryUnavailable, .emptyPlaylist,
            .playlistUnavailable, .importFailed:
            nil
        }
    }
}

private extension View {
    @ViewBuilder
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
            navigationBarTitleDisplayMode(.inline)
        #else
            self
        #endif
    }
}

#Preview("Track results") {
    TrackResultsSheet(
        collection: ImportedCollectionPresentation(
            name: "City Pocket",
            totalTrackCount: 4,
            readyTrackCount: 1,
            completedTrackCount: 4,
            tracks: [
                ImportedTrackPresentation(id: "ready", title: "Soft Current", status: .ready),
                ImportedTrackPresentation(
                    id: "rhythm",
                    title: "Afterimage",
                    status: .rhythmUnclear
                ),
                ImportedTrackPresentation(
                    id: "catalog",
                    title: "Distant Signal",
                    status: .catalogMatchUnavailable
                ),
                ImportedTrackPresentation(
                    id: "temporary",
                    title: "Warm Static",
                    status: .temporaryFailure
                ),
            ]
        ),
        retry: {}
    )
}
