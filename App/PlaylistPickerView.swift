import SwiftUI

struct PlaylistPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let presentation: PlaylistSheetPresentation
    let select: @MainActor (LibraryPlaylistChoice) -> Void

    var body: some View {
        NavigationStack {
            List(presentation.playlists) { playlist in
                Button {
                    select(playlist)
                    dismiss()
                } label: {
                    Label(playlist.name, systemImage: "music.note.list")
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel("Choose \(playlist.name)")
            }
            .overlay {
                if presentation.playlists.isEmpty {
                    ContentUnavailableView(
                        "No playlists",
                        systemImage: "music.note.list",
                        description: Text("Create a playlist in Apple Music, then try again.")
                    )
                }
            }
            .navigationTitle("Choose music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
