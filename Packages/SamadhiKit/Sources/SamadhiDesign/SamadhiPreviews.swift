import SamadhiDomain
import SwiftUI

private let previewSend: @MainActor (RunAction) -> Void = { _ in }

#Preview("Ready, demo pack") {
    SamadhiScreen(state: RunViewState(phase: .ready), send: previewSend)
}

#Preview("Ready, choose music") {
    SamadhiScreen(
        state: RunViewState(phase: .ready, musicSelection: .none),
        send: previewSend
    )
}

#Preview("Ready, analyzing music") {
    SamadhiScreen(
        state: RunViewState(
            phase: .ready,
            musicSelection: .analyzing(
                ImportedCollectionPresentation(
                    name: "City Pocket",
                    totalTrackCount: 8,
                    readyTrackCount: 1,
                    completedTrackCount: 2,
                    tracks: [
                        ImportedTrackPresentation(
                            id: "one",
                            title: "Soft Current",
                            status: .ready
                        ),
                        ImportedTrackPresentation(
                            id: "two",
                            title: "Afterimage",
                            status: .couldNotReadTempo
                        ),
                    ]
                )
            )
        ),
        send: previewSend
    )
}

#Preview("Ready, partially analyzed") {
    SamadhiScreen(
        state: RunViewState(
            phase: .ready,
            musicSelection: .ready(
                ImportedCollectionPresentation(
                    name: "City Pocket",
                    totalTrackCount: 3,
                    readyTrackCount: 1,
                    completedTrackCount: 3,
                    tracks: [
                        ImportedTrackPresentation(
                            id: "one",
                            title: "Soft Current",
                            status: .ready
                        ),
                        ImportedTrackPresentation(
                            id: "two",
                            title: "Afterimage",
                            status: .couldNotReadTempo
                        ),
                        ImportedTrackPresentation(
                            id: "three",
                            title: "Quiet Arcade",
                            status: .unavailable
                        ),
                    ]
                )
            )
        ),
        send: previewSend
    )
}

#Preview("Ready, music failure") {
    SamadhiScreen(
        state: RunViewState(
            phase: .ready,
            musicSelection: .failed("Your Apple Music playlist could not be analyzed.")
        ),
        send: previewSend
    )
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

#Preview("Tempo control, Auto") {
    SamadhiScreen(
        state: RunViewState(
            phase: .running,
            cadenceSPM: 168,
            trackElapsedSeconds: 91,
            trackProgress: 0.43,
            rhythmControl: RhythmControlPresentation(
                mode: .automatic,
                requestedBPM: 168,
                appliedBPM: 167,
                isVisible: true
            )
        ),
        send: previewSend
    )
}

#Preview("Tempo control, fine tune") {
    SamadhiScreen(
        state: RunViewState(
            phase: .running,
            cadenceSPM: 168,
            trackElapsedSeconds: 91,
            trackProgress: 0.43,
            rhythmControl: RhythmControlPresentation(
                mode: .automatic,
                automaticCorrectionBPM: 3,
                requestedBPM: 171,
                appliedBPM: 169,
                isVisible: true
            )
        ),
        send: previewSend
    )
}

#Preview("Tempo control, Manual") {
    SamadhiScreen(
        state: RunViewState(
            phase: .running,
            cadenceSPM: 168,
            trackElapsedSeconds: 91,
            trackProgress: 0.43,
            rhythmControl: RhythmControlPresentation(
                mode: .manual,
                manualTargetBPM: 176,
                requestedBPM: 176,
                appliedBPM: 174,
                isVisible: true
            )
        ),
        send: previewSend
    )
}

#Preview("Tempo control, safety limit") {
    SamadhiScreen(
        state: RunViewState(
            phase: .running,
            cadenceSPM: 168,
            trackElapsedSeconds: 91,
            trackProgress: 0.43,
            rhythmControl: RhythmControlPresentation(
                mode: .manual,
                manualTargetBPM: 200,
                requestedBPM: 200,
                appliedBPM: 170,
                isAtLimit: true,
                isVisible: true
            )
        ),
        send: previewSend
    )
}

#Preview("Controls visible") {
    SamadhiScreen(
        state: RunViewState(
            phase: .running, controlsVisible: true, cadenceSPM: 168, trackElapsedSeconds: 91,
            trackProgress: 0.43), send: previewSend)
}

#Preview("Paused") {
    SamadhiScreen(
        state: RunViewState(
            phase: .paused, controlsVisible: true, cadenceSPM: 168, trackElapsedSeconds: 91,
            trackProgress: 0.43), send: previewSend)
}

#Preview("Finish confirmation") {
    SamadhiScreen(
        state: RunViewState(
            phase: .confirmingFinish, cadenceSPM: 168, trackElapsedSeconds: 91, trackProgress: 0.43
        ), send: previewSend)
}

#Preview("Headphones disconnected") {
    SamadhiScreen(state: RunViewState(phase: .routeRecovery(restored: false)), send: previewSend)
}

#Preview("Route restored") {
    SamadhiScreen(state: RunViewState(phase: .routeRecovery(restored: true)), send: previewSend)
}

#Preview("Motion permission denied") {
    SamadhiScreen(state: RunViewState(phase: .permissionRecovery), send: previewSend)
}

#Preview("Summary") {
    SamadhiScreen(
        state: RunViewState(
            phase: .summary(
                RunSummary(durationSeconds: 1938, averageCadence: 171, tempoMatchedPercent: 84, songCount: 4)
            )
        ),
        send: previewSend
    )
}

#Preview("Reduce Motion, acquiring") {
    SamadhiScreen(state: RunViewState(phase: .acquiring, forceReduceMotion: true), send: previewSend)
}

#Preview("Accessibility text") {
    SamadhiScreen(
        state: RunViewState(
            phase: .running,
            cadenceSPM: 168,
            rhythmControl: RhythmControlPresentation(
                mode: .manual,
                manualTargetBPM: 176,
                requestedBPM: 176,
                appliedBPM: 174,
                isVisible: true
            )
        ),
        send: previewSend
    )
    .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("High contrast") {
    SamadhiScreen(
        state: RunViewState(phase: .running, controlsVisible: true, cadenceSPM: 168, forceIncreasedContrast: true),
        send: previewSend)
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
