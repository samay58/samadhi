import Foundation
import Observation
import SamadhiDesign
import SamadhiDomain
import SamadhiMotion
import UIKit

@MainActor
@Observable
final class RunPresentationModel {
    private(set) var state: RunState = .ready
    private(set) var showLockBrief = false

    @ObservationIgnored private let reducer = RunReducer(trackCount: TrackMetadata.demoTracks.count)
    @ObservationIgnored private let configuration: SimulationConfiguration
    @ObservationIgnored private let cadenceProvider: SimulatedCadenceProvider
    @ObservationIgnored private let taskStore = RunTaskStore()
    @ObservationIgnored private var nextToken = 1
    @ObservationIgnored private var currentHoldID: Int?

    init() {
        let configuration = SimulationConfiguration.current
        self.configuration = configuration
        let cadenceDelay: Duration =
            configuration.extendedAcquisitionWindow
            ? .milliseconds(1_400)
            : (configuration.fastMode ? .milliseconds(340) : .milliseconds(420))
        cadenceProvider = SimulatedCadenceProvider(
            sampleDelay: cadenceDelay
        )
    }

    var viewState: RunViewState {
        let session = state.session
        let trackIndex = session?.trackIndex ?? 0
        let track = TrackMetadata.demoTracks[trackIndex % TrackMetadata.demoTracks.count]
        var phase: RunVisualPhase = .ready
        var controlsVisible = false
        var cadence: Int?

        switch state {
        case .ready:
            phase = .ready
        case .preparing:
            phase = .preparing
        case .permissionRecovery:
            phase = .permissionRecovery
        case let .active(active):
            switch active.activity {
            case let .playing(rhythm, controls):
                controlsVisible = controls != .hidden
                switch rhythm {
                case .acquiring:
                    phase = .acquiring
                case let .locked(spm):
                    phase = .running
                    cadence = spm
                case .fixed:
                    phase = .running
                }
            case let .paused(rhythm):
                phase = .paused
                controlsVisible = true
                if case let .locked(spm) = rhythm { cadence = spm }
            }
        case let .confirmingFinish(confirmation):
            phase = .confirmingFinish
            if case let .locked(spm) = confirmation.origin.rhythm { cadence = spm }
        case let .routeRecovery(recovery):
            phase = .routeRecovery(restored: recovery.availability == .restored)
        case .finishing:
            phase = .finishing
        case let .summary(summary):
            phase = .summary(summary)
        }

        return RunViewState(
            phase: phase,
            controlsVisible: controlsVisible,
            cadenceSPM: cadence,
            trackElapsedSeconds: session?.trackElapsedSeconds ?? 0,
            trackProgress: min(Double(session?.trackElapsedSeconds ?? 0) / Double(track.durationSeconds), 1),
            track: track,
            hasArtwork: !configuration.missingArtwork,
            showLockBrief: showLockBrief
        )
    }

    func send(_ action: RunAction) {
        switch action {
        case .start:
            dispatch(.startTapped(sessionID: token()))
        case .revealControls:
            dispatch(.surfaceTapped(timeoutID: token()))
        case let .controlsFocusChanged(isFocused):
            dispatch(isFocused ? .controlsFocusEntered : .controlsFocusExited(timeoutID: token()))
        case .previous:
            dispatch(.previousTapped)
        case .pause:
            dispatch(.pauseTapped)
        case .resume:
            dispatch(.resumeTapped(acquisitionID: token(), timeoutID: token()))
        case .skip:
            dispatch(.skipTapped)
        case .finishTapped:
            dispatch(.finishTapped)
        case .finishHoldBegan:
            guard currentHoldID == nil else { return }
            let holdID = token()
            currentHoldID = holdID
            dispatch(.finishHoldBegan(holdID: holdID))
        case .finishHoldCancelled:
            guard let holdID = currentHoldID else { return }
            currentHoldID = nil
            dispatch(.finishHoldCancelled(holdID: holdID))
        case .finishHoldCompleted:
            guard let holdID = currentHoldID else { return }
            currentHoldID = nil
            dispatch(.finishHoldCompleted(holdID: holdID))
        case .useFixedRhythm:
            dispatch(.useFixedRhythmTapped)
        case .openSettings:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        case .routeResume:
            dispatch(.routeResumeTapped(acquisitionID: token(), timeoutID: token()))
        case .done:
            dispatch(.summaryDismissed)
        }
    }

    private func token() -> Int {
        defer { nextToken += 1 }
        return nextToken
    }

    private func dispatch(_ event: RunEvent) {
        let oldState = state
        let (newState, effects) = reducer.reduce(state: state, event: event)
        if newState != oldState {
            state = newState
        }

        if case .cadenceLocked = event, newState != oldState {
            showLockBrief = true
            taskStore.replace(.lockBrief) { [weak self] in
                try? await Task.sleep(for: .milliseconds(1_200))
                guard !Task.isCancelled else { return }
                self?.showLockBrief = false
            }
        }

        for effect in effects {
            execute(effect)
        }
    }

    private func execute(_ effect: RunEffect) {
        switch effect {
        case let .requestMotionAuthorization(sessionID):
            let delay: Duration = configuration.fastMode ? .milliseconds(60) : .milliseconds(260)
            let authorization: MotionAuthorization = configuration.permissionDenied ? .denied : .authorized
            taskStore.replace(.authorization) { [weak self] in
                try? await Task.sleep(for: delay)
                guard !Task.isCancelled else { return }
                guard let self else { return }
                dispatch(
                    .authorizationResolved(
                        sessionID: sessionID,
                        authorization
                    ))
            }

        case let .preparePlayback(sessionID, _):
            let delay: Duration = configuration.fastMode ? .milliseconds(70) : .milliseconds(280)
            taskStore.replace(.preparation) { [weak self] in
                try? await Task.sleep(for: delay)
                guard !Task.isCancelled else { return }
                guard let self else { return }
                dispatch(.playbackPrepared(sessionID: sessionID))
            }

        case let .beginPlayback(sessionID):
            startTicker(sessionID: sessionID)
            if configuration.simulateRouteLoss {
                let routeLossDelay: Duration = configuration.fastMode ? .milliseconds(650) : .seconds(2)
                let restoreDelay: Duration = configuration.fastMode ? .milliseconds(350) : .seconds(1)
                taskStore.replace(.simulatedRoute) { [weak self] in
                    try? await Task.sleep(for: routeLossDelay)
                    guard !Task.isCancelled else { return }
                    guard let self else { return }
                    dispatch(.audioRouteLost)
                    taskStore.replace(.simulatedRoute) { [weak self] in
                        try? await Task.sleep(for: restoreDelay)
                        guard !Task.isCancelled else { return }
                        self?.dispatch(.audioRouteRestored)
                    }
                }
            }

        case let .beginCadenceAcquisition(sessionID, acquisitionID, _):
            taskStore.replace(.acquisition) { [weak self, cadenceProvider] in
                for await sample in cadenceProvider.samples() {
                    guard !Task.isCancelled else { return }
                    if case let .locked(spm) = sample {
                        self?.dispatch(.cadenceLocked(sessionID: sessionID, acquisitionID: acquisitionID, spm: spm))
                    }
                }
            }

        case let .pausePlayback(sessionID):
            taskStore.cancel(.ticker)
            _ = sessionID

        case let .resumePlayback(sessionID):
            startTicker(sessionID: sessionID)

        case .previousTrack, .skipTrack:
            break

        case let .scheduleControlsTimeout(_, timeoutID):
            let delay: Duration = configuration.fastMode ? .seconds(3) : .seconds(5)
            taskStore.replace(.controlsTimeout) { [weak self] in
                try? await Task.sleep(for: delay)
                guard !Task.isCancelled else { return }
                guard let self else { return }
                dispatch(.controlsTimedOut(timeoutID: timeoutID))
            }

        case let .scheduleFinishHold(_, holdID):
            taskStore.replace(.finishHold) { [weak self] in
                try? await Task.sleep(for: .milliseconds(900))
                guard !Task.isCancelled else { return }
                self?.dispatch(.finishHoldCompleted(holdID: holdID))
            }

        case let .fadeAndStop(sessionID):
            taskStore.replace(.finishing) { [weak self] in
                try? await Task.sleep(for: .milliseconds(420))
                guard !Task.isCancelled else { return }
                self?.dispatch(.finishCompleted(sessionID: sessionID))
            }

        case let .emitHaptic(event):
            emitHaptic(event)

        case let .cancelTask(_, kind):
            taskStore.cancel(kind)

        case .cancelAllTasks:
            taskStore.cancelAll()
        }
    }

    private func startTicker(sessionID: Int) {
        taskStore.replace(.ticker) { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                guard self?.state.session?.id == sessionID else { return }
                self?.dispatch(.activeSecond)
            }
        }
    }

    private func emitHaptic(_ event: HapticEvent) {
        switch event {
        case .start, .resume:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .lock:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .pause:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .finish:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
