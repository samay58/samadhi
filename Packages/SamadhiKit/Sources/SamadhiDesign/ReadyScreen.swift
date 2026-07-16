import SwiftUI

struct ReadyScreen: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Space.x6) {
                    BrandMark()
                        .frame(width: 40, height: 30)
                        .padding(.top, Space.x8)

                    Spacer(minLength: Space.x8)

                    musicSetup

                    Spacer(minLength: Space.x8)

                    primaryAction
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                .padding(.horizontal, Space.x6)
            }
            .scrollIndicators(.hidden)
        }
        .accessibilityIdentifier("ready-screen")
    }

    @ViewBuilder
    private var musicSetup: some View {
        switch state.musicSelection {
        case .none:
            VStack(spacing: Space.x4) {
                Text("Music in stride")
                    .font(
                        .system(
                            size: dynamicTypeSize.isAccessibilitySize ? 42 : 52,
                            weight: .medium,
                            design: .serif
                        )
                    )
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text("Choose one Apple Music playlist. Samadhi reads its rhythm before you move.")
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SamadhiColor.ink.opacity(0.8))
            }
            .setupIdentityBackground()

        case .loadingPlaylists:
            ProgressView("Opening your music…")
                .font(.body.weight(.medium))
                .setupIdentityBackground()
                .accessibilityIdentifier("music-loading")

        case let .analyzing(collection):
            collectionIdentity(collection, analyzing: true)

        case let .ready(collection):
            collectionIdentity(collection, analyzing: false)

        case let .failed(message):
            VStack(spacing: Space.x4) {
                Text("Music unavailable")
                    .font(.title2.weight(.semibold))
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .setupIdentityBackground()
            .accessibilityIdentifier("music-import-failed")
        }
    }

    private func collectionIdentity(
        _ collection: ImportedCollectionPresentation,
        analyzing: Bool
    ) -> some View {
        VStack(spacing: Space.x4) {
            Text(analyzing ? "Reading the rhythm" : "Run with")
                .font(.callout.weight(.semibold))
                .foregroundStyle(SamadhiColor.ink.opacity(0.78))
            Text(collection.name)
                .font(
                    .system(
                        size: dynamicTypeSize.isAccessibilitySize ? 42 : 52,
                        weight: .medium,
                        design: .serif
                    )
                )
                .tracking(-1.2)
                .lineSpacing(-4)
                .multilineTextAlignment(.center)
                .foregroundStyle(SamadhiColor.ink)
                .shadow(color: SamadhiColor.ivory.opacity(0.78), radius: 16)
                .accessibilityAddTraits(.isHeader)
            Text(
                analyzing
                    ? "\(collection.completedTrackCount) of \(collection.totalTrackCount) tracks"
                    : "\(collection.readyTrackCount) of \(collection.totalTrackCount) ready"
            )
            .font(.body.weight(.medium))
            .foregroundStyle(SamadhiColor.ink.opacity(0.8))

            if analyzing {
                ProgressView(
                    value: Double(collection.completedTrackCount),
                    total: Double(max(collection.totalTrackCount, 1))
                )
                .tint(SamadhiColor.clay)
                .accessibilityIdentifier("music-analysis-progress")
            }

            if !collection.tracks.isEmpty {
                VStack(alignment: .leading, spacing: Space.x2) {
                    ForEach(collection.tracks.prefix(5)) { track in
                        HStack(spacing: Space.x2) {
                            Image(systemName: statusSymbol(track.status))
                                .foregroundStyle(statusColor(track.status))
                            Text(track.title)
                                .lineLimit(1)
                            Spacer(minLength: Space.x2)
                            Text(statusText(track.status))
                                .foregroundStyle(SamadhiColor.ink.opacity(0.68))
                        }
                        .font(.caption)
                    }
                }
                .frame(maxWidth: 320)
            }
        }
        .setupIdentityBackground()
        .accessibilityIdentifier(analyzing ? "music-analyzing" : "music-ready")
    }

    @ViewBuilder
    private var primaryAction: some View {
        switch state.musicSelection {
        case .none, .failed:
            chooseMusicButton
        case .loadingPlaylists, .analyzing:
            EmptyView()
        case let .ready(collection):
            if collection.readyTrackCount > 0 {
                Button(action: start) {
                    Text("Start")
                        .font(.title3.weight(.bold))
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        .frame(width: 184, height: 64)
                }
                .buttonStyle(.glassProminent)
                .tint(SamadhiColor.clay)
                .shadow(color: SamadhiColor.clay.opacity(0.3), radius: 20, y: 10)
                .accessibilityIdentifier("start-run")
                .accessibilityHint("Starts the music and listens for your stride")

                Text("Start moving. The music will find your stride.")
                    .font(.callout.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                    .padding(.horizontal, Space.x8)
            }

            Button("Change") {
                send(.changeMusic)
            }
            .font(.callout.weight(.semibold))
            .accessibilityLabel("Change music playlist")
            .padding(.bottom, Space.x6)
        }
    }

    private var chooseMusicButton: some View {
        Button {
            send(.chooseMusic)
        } label: {
            Text("Choose music")
                .font(.title3.weight(.bold))
                .frame(minWidth: 184, minHeight: 64)
        }
        .buttonStyle(.glassProminent)
        .tint(SamadhiColor.clay)
        .accessibilityIdentifier("choose-music")
        .accessibilityHint("Opens your Apple Music playlists")
    }

    private func statusText(_ status: MusicTrackImportPresentation) -> String {
        switch status {
        case .pending: "Waiting"
        case .ready: "Ready"
        case .couldNotReadTempo: "Could not read tempo"
        case .unavailable: "Unavailable"
        }
    }

    private func statusSymbol(_ status: MusicTrackImportPresentation) -> String {
        switch status {
        case .pending: "clock"
        case .ready: "checkmark.circle.fill"
        case .couldNotReadTempo, .unavailable: "minus.circle"
        }
    }

    private func statusColor(_ status: MusicTrackImportPresentation) -> Color {
        switch status {
        case .ready: SamadhiColor.olive
        case .pending, .couldNotReadTempo, .unavailable: SamadhiColor.ink.opacity(0.58)
        }
    }

    private func start() {
        send(.start)
    }
}

private extension View {
    func setupIdentityBackground() -> some View {
        padding(.horizontal, Space.x6)
            .padding(.vertical, Space.x8)
            .frame(maxWidth: 360)
            .background {
                Ellipse()
                    .fill(SamadhiColor.parchment.opacity(0.78))
                    .frame(width: 430, height: 250)
                    .blur(radius: 46)
            }
    }
}
