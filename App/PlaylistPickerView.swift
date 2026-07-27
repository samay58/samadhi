import SamadhiDesign
import SwiftUI

struct PlaylistPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let presentation: PlaylistSheetPresentation
    let select: @MainActor (LibraryPlaylistChoice) -> Void
    let reload: @MainActor () -> Void

    @State private var selectionFeedback = 0

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

                VStack(alignment: .leading, spacing: 0) {
                    BrandMark()
                        .frame(width: 34, height: 25)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Space.x2)
                        .padding(.bottom, Space.x4)

                    Text("Choose music")
                        .font(.system(.largeTitle, design: .serif).weight(.medium))
                        .foregroundStyle(SamadhiColor.ink)
                        .padding(.horizontal, Space.x6)
                        .padding(.bottom, Space.x3)

                    playlistList
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.visible)
        .presentationDetents(presentationDetents)
        .presentationContentInteraction(.scrolls)
        .sensoryFeedback(.selection, trigger: selectionFeedback)
        .accessibilityIdentifier("playlist-picker")
    }

    private var presentationDetents: Set<PresentationDetent> {
        guard !dynamicTypeSize.isAccessibilitySize, presentation.playlists.count <= 4 else {
            return [.large]
        }
        let contentHeight = min(max(CGFloat(presentation.playlists.count) * 66 + 250, 350), 520)
        return [.height(contentHeight), .large]
    }

    private var playlistList: some View {
        List {
            ForEach(presentation.playlists) { playlist in
                playlistRow(playlist)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 58)
        .overlay {
            if presentation.playlists.isEmpty {
                VStack(alignment: .leading, spacing: Space.x3) {
                    Text("No playlists yet")
                        .font(.title3.weight(.semibold))
                    Text("Create one in Apple Music, then try again.")
                        .font(.body)
                        .foregroundStyle(SamadhiColor.ink.opacity(0.72))

                    Button("Try again", action: retryPlaylistLibrary)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                        .frame(minHeight: 44)
                        .accessibilityIdentifier("reload-playlist-library")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Space.x6)
            }
        }
    }

    private func playlistRow(_ playlist: LibraryPlaylistChoice) -> some View {
        let isSelected = presentation.selectedPlaylistID == playlist.id

        return Button {
            selectionFeedback += 1
            select(playlist)
            dismiss()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: Space.x3) {
                Circle()
                    .fill(SamadhiColor.clay)
                    .frame(width: 6, height: 6)
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(true)

                Text(playlist.name)
                    .font(.system(.title3, design: .serif).weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(SamadhiColor.ink)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: Space.x3)

                if isSelected {
                    Text("Current")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SamadhiColor.ink.opacity(0.72))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlaylistRowButtonStyle(reduceMotion: reduceMotion))
        .listRowInsets(
            EdgeInsets(
                top: Space.x1,
                leading: Space.x6,
                bottom: Space.x1,
                trailing: Space.x6
            )
        )
        .listRowBackground(isSelected ? SamadhiColor.clay.opacity(0.1) : Color.clear)
        .listRowSeparatorTint(SamadhiColor.ink.opacity(0.14))
        .accessibilityLabel(
            isSelected ? "\(playlist.name), Current playlist" : playlist.name
        )
        .accessibilityValue(isSelected ? "Current playlist" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Selects and analyzes this playlist")
        .accessibilityIdentifier("playlist-choice-\(playlist.id)")
    }

    private func retryPlaylistLibrary() {
        dismiss()
        reload()
    }
}

private struct PlaylistRowButtonStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.985 : 1))
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

#Preview("Playlist picker") {
    PlaylistPickerView(
        presentation: PlaylistSheetPresentation(
            id: 1,
            playlists: [
                LibraryPlaylistChoice(id: "city-pocket", name: "City Pocket"),
                LibraryPlaylistChoice(id: "soft-miles", name: "Soft Miles"),
                LibraryPlaylistChoice(id: "long-light", name: "Long Light"),
            ],
            selectedPlaylistID: "city-pocket"
        ),
        select: { _ in },
        reload: {}
    )
}
