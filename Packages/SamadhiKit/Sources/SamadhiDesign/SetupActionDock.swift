import SwiftUI

struct SetupActionDock: View {
    let selection: MusicSelectionPresentation
    let reduceMotion: Bool
    let send: @MainActor (RunAction) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: actionAlignment) {
            actions
                .id(selection.visualStage)
                .transition(setupTransition(reduceMotion: reduceMotion))
        }
        // The dock keeps one height through every stage, so the playlist name never moves.
        .frame(
            maxWidth: .infinity,
            minHeight: dynamicTypeSize.isAccessibilitySize ? nil : 128,
            alignment: actionAlignment
        )
        .animation(
            reduceMotion ? nil : .easeOut(duration: MotionToken.feedback),
            value: selection.visualStage
        )
        .accessibilitySortPriority(2)
    }

    private var actionAlignment: Alignment {
        if dynamicTypeSize.isAccessibilitySize { return .leading }
        // While reading, the way out sits exactly where Change playlist will appear.
        if case .analyzing = selection { return .bottom }
        return .top
    }

    @ViewBuilder
    private var actions: some View {
        VStack(alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center, spacing: Space.x3) {
            switch selection {
            case .none:
                SetupPrimaryButton("Choose music", identifier: "choose-music") {
                    send(.chooseMusic)
                }
                .accessibilityHint("Opens your Apple Music playlists")
            case .loadingPlaylists:
                SetupLoadingAction()
            case .analyzing:
                SetupSecondaryButton("Choose another", identifier: "choose-another-music") {
                    send(.changeMusic)
                }
            case let .ready(collection):
                readyActions(collection)
            case let .failed(failure):
                failureActions(failure)
            }
        }
        .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: actionAlignment)
    }

    @ViewBuilder
    private func readyActions(_ collection: ImportedCollectionPresentation) -> some View {
        if collection.readyTrackCount > 0 {
            SetupPrimaryButton("Start", identifier: "start-run") {
                send(.start)
            }
            .accessibilityHint("Starts the music and listens for your stride")
            SetupSecondaryButton("Change playlist", identifier: "change-music") {
                send(.changeMusic)
            }
        } else if collection.hasTemporaryFailures {
            SetupPrimaryButton("Retry playlist", identifier: "retry-music-import") {
                send(.retryMusicImport)
            }
            SetupSecondaryButton("Choose another", identifier: "choose-another-music") {
                send(.changeMusic)
            }
        } else {
            SetupPrimaryButton("Choose another", identifier: "choose-another-music") {
                send(.changeMusic)
            }
        }
    }

    @ViewBuilder
    private func failureActions(_ failure: MusicSelectionFailurePresentation) -> some View {
        switch failure {
        case .authorizationDenied:
            SetupPrimaryButton("Open Settings", identifier: "open-settings") {
                send(.openSettings)
            }
            SetupSecondaryButton("Try again", identifier: "retry-playlist-library") {
                send(.chooseMusic)
            }
        case .savedCollectionUnavailable:
            SetupPrimaryButton("Choose music", identifier: "choose-music") {
                send(.chooseMusic)
            }
        case .playlistLibraryUnavailable:
            SetupPrimaryButton("Try again", identifier: "retry-playlist-library") {
                send(.chooseMusic)
            }
        case .emptyPlaylist:
            SetupPrimaryButton("Choose another", identifier: "choose-another-music") {
                send(.changeMusic)
            }
        case .playlistUnavailable, .importFailed:
            SetupPrimaryButton("Retry playlist", identifier: "retry-music-import") {
                send(.retryMusicImport)
            }
            SetupSecondaryButton("Choose another", identifier: "choose-another-music") {
                send(.changeMusic)
            }
        }
    }
}

private struct SetupPrimaryButton: View {
    let title: String
    let identifier: String
    let action: @MainActor () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ title: String, identifier: String, action: @escaping @MainActor () -> Void) {
        self.title = title
        self.identifier = identifier
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(SamadhiColor.onLime)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Space.x4)
                .frame(
                    minWidth: dynamicTypeSize.isAccessibilitySize ? nil : 176,
                    maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 220,
                    minHeight: 50
                )
        }
        .buttonStyle(.glassProminent)
        .tint(SamadhiColor.lime)
        .accessibilityIdentifier(identifier)
    }
}

private struct SetupLoadingAction: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: Space.x3) {
            ProgressView()
                .controlSize(.small)
                .tint(SamadhiColor.line)
            Text("Opening playlists")
                .font(.headline)
        }
        .foregroundStyle(SamadhiColor.ink.opacity(0.78))
        .frame(
            minWidth: dynamicTypeSize.isAccessibilitySize ? nil : 176,
            maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 220,
            minHeight: 50,
            alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Opening Apple Music playlists")
        .accessibilityIdentifier("music-loading")
    }
}

private struct SetupSecondaryButton: View {
    let title: String
    let identifier: String
    let action: @MainActor () -> Void

    init(_ title: String, identifier: String, action: @escaping @MainActor () -> Void) {
        self.title = title
        self.identifier = identifier
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(SamadhiColor.ink.opacity(0.86))
                // A capsule cannot hold two lines, so the largest text sizes shrink slightly to stay on one.
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, Space.x2)
                .frame(minHeight: 36)
        }
        .buttonStyle(.glass)
        .accessibilitySortPriority(1)
        .accessibilityIdentifier(identifier)
    }
}
