import Testing

@testable import SamadhiDesign

@Test func readinessFeedbackOnlyFiresForANewRunnableImport() {
    let analyzing = MusicSelectionPresentation.analyzing(collection(readyCount: 0))
    let ready = MusicSelectionPresentation.ready(collection(readyCount: 1))

    #expect(SetupReadinessFeedback.shouldPlay(from: analyzing, to: ready))
    #expect(!SetupReadinessFeedback.shouldPlay(from: ready, to: ready))
    #expect(!SetupReadinessFeedback.shouldPlay(from: .none, to: ready))
}

@Test func readinessFeedbackStaysQuietWhenNoTrackCanStart() {
    let analyzing = MusicSelectionPresentation.analyzing(collection(readyCount: 0))
    let unavailable = MusicSelectionPresentation.ready(collection(readyCount: 0))

    #expect(!SetupReadinessFeedback.shouldPlay(from: analyzing, to: unavailable))
}

private func collection(readyCount: Int) -> ImportedCollectionPresentation {
    ImportedCollectionPresentation(
        name: "Fixture",
        totalTrackCount: 1,
        readyTrackCount: readyCount,
        completedTrackCount: 1,
        tracks: []
    )
}
