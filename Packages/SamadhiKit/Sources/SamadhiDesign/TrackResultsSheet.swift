import SwiftUI

struct TrackResultsSheet: View {
    let collection: ImportedCollectionPresentation
    let retry: @MainActor () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    trackSection("Couldn't find the beat", status: .rhythmUnclear)
                    trackSection("No preview to listen to", status: .previewUnavailable)
                    trackSection("Not found on Apple Music", status: .catalogMatchUnavailable)
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
        // A full-height sheet is not system glass, and a bare material reads cold against the field.
        .presentationBackground {
            SamadhiColor.parchment.opacity(0.78).background(.ultraThinMaterial)
        }
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

                Button("Try these again") {
                    dismiss()
                    retry()
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                .frame(minHeight: 44)
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("retry-temporary-imports")
            } header: {
                sectionHeader("Didn't finish downloading")
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
