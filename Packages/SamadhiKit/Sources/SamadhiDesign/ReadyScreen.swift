import SwiftUI

struct ReadyScreen: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var trackDetails: TrackDetailsPresentation?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: contentAlignment, spacing: 0) {
                    BrandMark()
                        .frame(width: 38, height: 28)
                        .frame(maxWidth: .infinity, alignment: brandAlignment)
                        .padding(.top, dynamicTypeSize.isAccessibilitySize ? Space.x6 : Space.x8)

                    if dynamicTypeSize.isAccessibilitySize {
                        accessibilityComposition
                    } else {
                        standardComposition
                    }
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .top)
                .padding(.horizontal, Space.x6)
            }
            .scrollIndicators(.hidden)
        }
        .accessibilityIdentifier("ready-screen")
        .sensoryFeedback(.success, trigger: state.musicSelection) { oldValue, newValue in
            SetupReadinessFeedback.shouldPlay(from: oldValue, to: newValue)
        }
        .sheet(item: $trackDetails) { details in
            TrackResultsSheet(collection: details.collection) {
                send(.retryMusicImport)
            }
        }
    }

    private var contentAlignment: HorizontalAlignment {
        dynamicTypeSize.isAccessibilitySize ? .leading : .center
    }

    private var brandAlignment: Alignment {
        dynamicTypeSize.isAccessibilitySize ? .leading : .center
    }

    private var standardComposition: some View {
        VStack(spacing: 0) {
            Spacer(minLength: Space.x12)

            SetupPlaylistIdentity(selection: state.musicSelection)

            SetupStatusRail(
                selection: state.musicSelection,
                reduceMotion: effectiveReduceMotion,
                presentTrackDetails: presentTrackDetails
            )
            .padding(.top, Space.x6)

            Spacer(minLength: Space.x12)

            SetupActionDock(
                selection: state.musicSelection,
                reduceMotion: effectiveReduceMotion,
                send: send
            )
            .padding(.bottom, Space.x8)
        }
        .frame(maxWidth: .infinity, minHeight: 700)
    }

    private var accessibilityComposition: some View {
        VStack(alignment: .leading, spacing: 0) {
            SetupPlaylistIdentity(selection: state.musicSelection)
                .padding(.top, Space.x8)

            SetupStatusRail(
                selection: state.musicSelection,
                reduceMotion: true,
                presentTrackDetails: presentTrackDetails
            )
            .padding(.top, Space.x6)

            SetupActionDock(
                selection: state.musicSelection,
                reduceMotion: true,
                send: send
            )
            .padding(.top, Space.x8)
            .padding(.bottom, Space.x8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var effectiveReduceMotion: Bool {
        reduceMotion || state.forceReduceMotion
    }

    private func presentTrackDetails(_ collection: ImportedCollectionPresentation) {
        trackDetails = TrackDetailsPresentation(collection: collection)
    }
}

struct TrackDetailsPresentation: Identifiable {
    let id = UUID()
    let collection: ImportedCollectionPresentation
}
