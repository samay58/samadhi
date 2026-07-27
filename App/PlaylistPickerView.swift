import SamadhiDesign
import SwiftUI

struct PlaylistPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let presentation: PlaylistSheetPresentation
    let select: @MainActor (LibraryPlaylistChoice) -> Void

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
        .accessibilityIdentifier("playlist-picker")
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
                VStack(spacing: Space.x3) {
                    Text("No playlists")
                        .font(.title3.weight(.semibold))
                    Text("Create one in Apple Music, then return here.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(SamadhiColor.ink.opacity(0.72))
                }
                .padding(.horizontal, Space.x8)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func playlistRow(_ playlist: LibraryPlaylistChoice) -> some View {
        let isSelected = presentation.selectedPlaylistID == playlist.id

        return Button {
            select(playlist)
            dismiss()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: Space.x4) {
                Text(playlist.name)
                    .font(.system(.title3, design: .serif).weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(SamadhiColor.ink)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: Space.x3)

                if isSelected {
                    Text("Current")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SamadhiColor.clay)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
        select: { _ in }
    )
}
