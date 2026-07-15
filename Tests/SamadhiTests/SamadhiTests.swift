import Testing
@testable import Samadhi

@Test @MainActor func presentationStartsReadyWithDemoMusic() {
    let model = RunPresentationModel()
    #expect(model.viewState.phase == .ready)
    #expect(model.viewState.track.title == "Dawn on Valencia")
}

@Test @MainActor func startActionMovesPresentationIntoPreparation() {
    let model = RunPresentationModel()
    model.send(.start)
    #expect(model.viewState.phase == .preparing)
}
