import SwiftUI

struct TrackResultsSheet: View {
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
                    trackSection("Rhythm unclear", status: .rhythmUnclear)
                    trackSection("Preview unavailable", status: .previewUnavailable)
                    trackSection("Could not match Apple Music item", status: .catalogMatchUnavailable)
                    temporaryFailureSection
                    trackSection("Waiting", status: .pending)
                    trackSection("Ready", status: .ready)
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
    private var temporaryFailureSection: some View {
        let tracks = collection.tracks.filter { $0.status == .temporaryFailure }
        if !tracks.isEmpty {
            Section {
                ForEach(tracks) { track in
                    trackRow(track)
                }

                Button("Retry temporary failures") {
                    dismiss()
                    retry()
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                .frame(minHeight: 44)
                .accessibilityIdentifier("retry-temporary-imports")
            } header: {
                sectionHeader("Temporary download or decode failure")
                    .accessibilityIdentifier("temporary-failure-section")
            }
        }
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
                    trackRow(track)
                }
            } header: {
                sectionHeader(title)
            }
        }
    }

    private func trackRow(_ track: ImportedTrackPresentation) -> some View {
        Text(track.title)
            .font(.body)
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(SamadhiColor.ink.opacity(0.14))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.callout.weight(.semibold))
            .foregroundStyle(SamadhiColor.ink.opacity(0.7))
            .textCase(nil)
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
