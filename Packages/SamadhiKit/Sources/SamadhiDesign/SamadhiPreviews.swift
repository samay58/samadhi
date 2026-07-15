import SamadhiDomain
import SwiftUI

private let previewSend: @MainActor (RunAction) -> Void = { _ in }

#Preview("Ready, demo pack") {
    SamadhiScreen(state: RunViewState(phase: .ready), send: previewSend)
}

#Preview("Start transformation") {
    SamadhiScreen(state: RunViewState(phase: .preparing), send: previewSend)
}

#Preview("Listening for stride") {
    SamadhiScreen(state: RunViewState(phase: .acquiring), send: previewSend)
}

#Preview("Locked, low cadence") {
    SamadhiScreen(state: RunViewState(phase: .running, cadenceSPM: 142, showLockBrief: true), send: previewSend)
}

#Preview("Locked, high cadence") {
    SamadhiScreen(state: RunViewState(phase: .running, cadenceSPM: 194), send: previewSend)
}

#Preview("Controls visible") {
    SamadhiScreen(state: RunViewState(phase: .running, controlsVisible: true, cadenceSPM: 168, elapsedSeconds: 428, trackElapsedSeconds: 91, trackProgress: 0.43), send: previewSend)
}

#Preview("Paused") {
    SamadhiScreen(state: RunViewState(phase: .paused, controlsVisible: true, cadenceSPM: 168, elapsedSeconds: 428, trackElapsedSeconds: 91, trackProgress: 0.43), send: previewSend)
}

#Preview("Finish confirmation") {
    SamadhiScreen(state: RunViewState(phase: .confirmingFinish, cadenceSPM: 168, elapsedSeconds: 428, trackElapsedSeconds: 91, trackProgress: 0.43), send: previewSend)
}

#Preview("Headphones disconnected") {
    SamadhiScreen(state: RunViewState(phase: .routeRecovery(restored: false), elapsedSeconds: 428), send: previewSend)
}

#Preview("Route restored") {
    SamadhiScreen(state: RunViewState(phase: .routeRecovery(restored: true), elapsedSeconds: 428), send: previewSend)
}

#Preview("Motion permission denied") {
    SamadhiScreen(state: RunViewState(phase: .permissionRecovery), send: previewSend)
}

#Preview("Summary") {
    SamadhiScreen(
        state: RunViewState(phase: .summary(RunSummary(durationSeconds: 1938, averageCadence: 171, timeInStepPercent: 84, songCount: 4))),
        send: previewSend
    )
}

#Preview("Reduce Motion, acquiring") {
    SamadhiScreen(state: RunViewState(phase: .acquiring, forceReduceMotion: true), send: previewSend)
}

#Preview("Accessibility text") {
    SamadhiScreen(state: RunViewState(phase: .running, controlsVisible: true, cadenceSPM: 168, elapsedSeconds: 428), send: previewSend)
        .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("High contrast") {
    SamadhiScreen(state: RunViewState(phase: .running, controlsVisible: true, cadenceSPM: 168, forceIncreasedContrast: true), send: previewSend)
}

#Preview("Long metadata") {
    SamadhiScreen(
        state: RunViewState(
            phase: .running,
            controlsVisible: true,
            cadenceSPM: 168,
            track: TrackMetadata(
                title: "The Streetlights Kept Time All the Way Home",
                artist: "A Particularly Long Artist Name and the Night Windows"
            )
        ),
        send: previewSend
    )
}

#Preview("Missing artwork") {
    SamadhiScreen(state: RunViewState(phase: .ready, hasArtwork: false), send: previewSend)
}
