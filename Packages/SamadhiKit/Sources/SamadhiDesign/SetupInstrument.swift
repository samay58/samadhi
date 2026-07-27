import SwiftUI

enum SetupVisualStage: Hashable {
    case empty
    case openingLibrary
    case analysis
    case ready
    case failure
}

enum SetupReadinessFeedback {
    static func shouldPlay(
        from oldValue: MusicSelectionPresentation,
        to newValue: MusicSelectionPresentation
    ) -> Bool {
        guard case .analyzing = oldValue,
            case let .ready(collection) = newValue
        else { return false }
        return collection.readyTrackCount > 0
    }
}

struct SetupPlaylistIdentity: View {
    let selection: MusicSelectionPresentation

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var identityFontSize = 46.0

    var body: some View {
        Text(selection.identityTitle)
            .font(identityFont)
            .tracking(dynamicTypeSize.isAccessibilitySize ? -0.25 : -0.8)
            .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .center)
            .foregroundStyle(SamadhiColor.ink)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 520, alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .center)
            .accessibilityAddTraits(.isHeader)
            .accessibilitySortPriority(4)
            .accessibilityIdentifier("playlist-identity")
    }

    private var identityFont: Font {
        if dynamicTypeSize.isAccessibilitySize {
            return .system(.largeTitle, design: .serif).weight(.medium)
        }
        return .system(size: identityFontSize, weight: .medium, design: .serif)
    }
}

extension MusicSelectionPresentation {
    var visualStage: SetupVisualStage {
        switch self {
        case .none:
            .empty
        case .loadingPlaylists:
            .openingLibrary
        case .analyzing:
            .analysis
        case .ready:
            .ready
        case .failed:
            .failure
        }
    }

    var identityTitle: String {
        switch self {
        case .none, .loadingPlaylists(current: nil):
            "Music in stride"
        case let .loadingPlaylists(current: collection?):
            collection.name
        case let .analyzing(collection), let .ready(collection):
            collection.name
        case let .failed(failure):
            failure.playlistName ?? failure.title
        }
    }
}

extension MusicSelectionFailurePresentation {
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

func setupTransition(reduceMotion: Bool) -> AnyTransition {
    if reduceMotion { return .identity }

    let removal = AnyTransition.opacity
        .combined(with: .offset(y: -6))
        .animation(.easeOut(duration: 0.1))
    let insertion = AnyTransition.opacity
        .combined(with: .offset(y: 8))
        .animation(.easeOut(duration: 0.1).delay(0.11))

    return .asymmetric(
        insertion: insertion,
        removal: removal
    )
}
