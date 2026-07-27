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
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? nil : 100)
        .animation(
            reduceMotion ? nil : .easeOut(duration: MotionToken.feedback),
            value: selection.visualStage
        )
        .accessibilitySortPriority(2)
    }

    private var actionAlignment: Alignment {
        dynamicTypeSize.isAccessibilitySize ? .leading : .center
    }

    @ViewBuilder
    private var actions: some View {
        VStack(alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center, spacing: Space.x2) {
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
                .multilineTextAlignment(.center)
                .padding(.horizontal, Space.x4)
                .frame(
                    minWidth: dynamicTypeSize.isAccessibilitySize ? nil : 176,
                    maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 220,
                    minHeight: 50
                )
        }
        .buttonStyle(.glassProminent)
        .tint(SamadhiColor.clay)
        .accessibilityIdentifier(identifier)
    }
}

private struct SetupLoadingAction: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: Space.x3) {
            ProgressView()
                .controlSize(.small)
                .tint(SamadhiColor.clay)
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

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ title: String, identifier: String, action: @escaping @MainActor () -> Void) {
        self.title = title
        self.identifier = identifier
        self.action = action
    }

    var body: some View {
        Button(title, action: action)
            .font(.callout.weight(.semibold))
            .foregroundStyle(SamadhiColor.ink.opacity(0.82))
            .frame(
                minWidth: dynamicTypeSize.isAccessibilitySize ? nil : 176,
                maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 220,
                minHeight: 44,
                alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center
            )
            .contentShape(Rectangle())
            .accessibilitySortPriority(1)
            .accessibilityIdentifier(identifier)
    }
}
