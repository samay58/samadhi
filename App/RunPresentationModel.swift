import Foundation
import Observation
import SamadhiAudio
import SamadhiDesign
import SamadhiDomain
import SamadhiMotion
import UIKit

@MainActor
@Observable
final class RunPresentationModel {
    // This is the boundary between the pure run state machine and iOS. Follow send -> dispatch -> execute.
    private(set) var state: RunState = .ready
    private(set) var showLockBrief = false

    @ObservationIgnored private let reducer: RunReducer
    @ObservationIgnored private let configuration: SimulationConfiguration
    @ObservationIgnored private let cadenceProvider: any CadenceProviding
    @ObservationIgnored private let musicPlayer: any MusicPlaybackProviding
    @ObservationIgnored private let musicCollection: MusicCollection
    @ObservationIgnored private let taskStore = RunTaskStore()
    @ObservationIgnored private var nextToken = 1
    @ObservationIgnored private var currentHoldID: Int?
    @ObservationIgnored private var playbackEventTask: Task<Void, Never>?

    init() {
        let configuration = SimulationConfiguration.current
        self.configuration = configuration
        musicCollection =
            configuration.useAppleMusicCoreLoop
            ? AppMusicCollection.appleMusicCoreLoop
            : AppMusicCollection.simulated
        musicPlayer =
            configuration.useAppleMusicCoreLoop
            ? AppleMusicPlaybackController()
            : SimulatedMusicPlayer()
        reducer = RunReducer(tracks: musicCollection.tracks)
        let cadenceDelay: Duration =
            configuration.extendedAcquisitionWindow
            ? .milliseconds(1_400)
            : (configuration.fastMode ? .milliseconds(340) : .milliseconds(420))
        cadenceProvider =
            configuration.useAppleMusicCoreLoop
            ? CoreMotionCadenceProvider()
            : SimulatedCadenceProvider(sampleDelay: cadenceDelay)
        startPlaybackEventMonitoring()
    }

    var viewState: RunViewState {
        // UI-only choices live here so the domain module never needs SwiftUI.
        let session = state.session
        let trackIndex = session?.trackIndex ?? 0
        let domainTrack = musicCollection.tracks[trackIndex % musicCollection.tracks.count]
        let track = TrackMetadata(
            title: domainTrack.title,
            artist: domainTrack.artist ?? "",
            durationSeconds: max(Int(domainTrack.durationSeconds.rounded()), 1)
        )
        let trackDuration = session?.trackDurationSeconds ?? track.durationSeconds
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
            trackProgress: min(
                Double(session?.trackElapsedSeconds ?? 0) / Double(max(trackDuration, 1)),
                1
            ),
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
        // Every input crosses the reducer once. New state is applied before its returned work starts.
        let oldState = state
        let (newState, effects) = reducer.reduce(state: state, event: event)
        if newState != oldState {
            state = newState
        }

        if case .cadenceUpdated = event,
            case let .active(oldActive) = oldState,
            case .playing(.acquiring, _) = oldActive.activity,
            case let .active(newActive) = newState,
            case .playing(.locked, _) = newActive.activity
        {
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
        // Platform services execute reducer effects and return identified events through dispatch.
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
            taskStore.replace(.preparation) { [weak self, musicPlayer, musicCollection] in
                try? await Task.sleep(for: delay)
                guard !Task.isCancelled else { return }
                guard let self else { return }
                do {
                    try await musicPlayer.prepare(musicCollection, operationID: sessionID)
                    guard !Task.isCancelled else { return }
                    guard let firstTrackID = musicCollection.tracks.first?.id else { return }
                    dispatch(.playbackPrepared(sessionID: sessionID, trackID: firstTrackID))
                } catch {
                    dispatch(.playbackFailed(sessionID: sessionID, operationID: sessionID))
                }
            }

        case let .beginPlayback(sessionID):
            taskStore.replace(.playbackCommand) { [weak self, musicPlayer] in
                do {
                    try await musicPlayer.play(operationID: sessionID)
                    guard !Task.isCancelled, let self else { return }
                    startTicker(sessionID: sessionID)
                    if configuration.simulateRouteLoss {
                        let routeLossDelay: Duration =
                            configuration.fastMode ? .milliseconds(650) : .seconds(2)
                        let restoreDelay: Duration =
                            configuration.fastMode ? .milliseconds(350) : .seconds(1)
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
                } catch {
                    self?.dispatch(.playbackFailed(sessionID: sessionID, operationID: sessionID))
                }
            }

        case let .beginCadenceAcquisition(sessionID, acquisitionID, priorSPM):
            taskStore.replace(.acquisition) { [weak self, cadenceProvider] in
                var filter = CadenceFilter(priorSPM: priorSPM.map(Double.init))
                var lastElapsedSeconds: Double?
                var hasLocked = false

                for await event in cadenceProvider.events() {
                    guard !Task.isCancelled else { return }
                    guard let self else { return }

                    switch event {
                    case let .observation(observation):
                        let rawDelta =
                            lastElapsedSeconds.map {
                                observation.elapsedSeconds - $0
                            } ?? 1
                        let deltaSeconds =
                            rawDelta > 0
                            ? min(rawDelta, 2)
                            : 1
                        lastElapsedSeconds = observation.elapsedSeconds

                        switch filter.ingest(observation) {
                        case let .locked(stepsPerMinute):
                            hasLocked = true
                            dispatch(
                                .cadenceUpdated(
                                    sessionID: sessionID,
                                    acquisitionID: acquisitionID,
                                    stepsPerMinute: stepsPerMinute,
                                    deltaSeconds: deltaSeconds,
                                    rateRequestID: token()
                                )
                            )
                        case .acquiring where hasLocked:
                            dispatch(
                                .cadenceConfidenceLost(
                                    sessionID: sessionID,
                                    acquisitionID: acquisitionID,
                                    deltaSeconds: deltaSeconds,
                                    rateRequestID: token()
                                )
                            )
                        case .acquiring:
                            break
                        }

                    case .unavailable:
                        dispatch(
                            .cadenceAcquisitionFailed(
                                sessionID: sessionID,
                                acquisitionID: acquisitionID
                            )
                        )
                        return
                    }
                }
            }

        case let .pausePlayback(sessionID):
            taskStore.cancel(.ticker)
            musicPlayer.pause(operationID: sessionID)

        case let .resumePlayback(sessionID):
            taskStore.replace(.playbackCommand) { [weak self, musicPlayer] in
                do {
                    try await musicPlayer.resume(operationID: sessionID)
                    guard !Task.isCancelled else { return }
                    self?.startTicker(sessionID: sessionID)
                } catch {
                    self?.dispatch(.playbackFailed(sessionID: sessionID, operationID: sessionID))
                }
            }

        case let .previousTrack(sessionID):
            taskStore.replace(.playbackCommand) { [weak self, musicPlayer] in
                do {
                    try await musicPlayer.skipToPrevious(operationID: sessionID)
                } catch {
                    self?.dispatch(.playbackFailed(sessionID: sessionID, operationID: sessionID))
                }
            }

        case let .skipTrack(sessionID):
            taskStore.replace(.playbackCommand) { [weak self, musicPlayer] in
                do {
                    try await musicPlayer.skipToNext(operationID: sessionID)
                } catch {
                    self?.dispatch(.playbackFailed(sessionID: sessionID, operationID: sessionID))
                }
            }

        case let .setPlaybackRate(
            sessionID,
            operationID,
            requestID,
            trackID,
            rate
        ):
            guard state.session?.id == sessionID else { return }
            musicPlayer.setPlaybackRate(
                rate,
                operationID: operationID,
                requestID: requestID,
                trackID: trackID
            )

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
            musicPlayer.stop(operationID: sessionID)
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

    private func startPlaybackEventMonitoring() {
        let events = musicPlayer.events()
        playbackEventTask = Task { [weak self] in
            for await event in events {
                guard !Task.isCancelled else { return }
                self?.handlePlaybackEvent(event)
            }
        }
    }

    private func handlePlaybackEvent(_ event: MusicPlaybackEvent) {
        guard let session = state.session else { return }

        switch event {
        case let .progress(operationID, progress):
            guard operationID == session.playbackOperationID,
                let trackIndex = musicCollection.tracks.firstIndex(where: { $0.id == progress.trackID })
            else { return }
            dispatch(
                .playbackProgress(
                    sessionID: session.id,
                    operationID: operationID,
                    trackIndex: trackIndex,
                    elapsedSeconds: Int(progress.elapsedSeconds),
                    durationSeconds: Int(progress.durationSeconds)
                )
            )

        case let .routeLost(operationID):
            dispatch(.playbackRouteLost(sessionID: session.id, operationID: operationID))

        case let .routeRestored(operationID):
            dispatch(.playbackRouteRestored(sessionID: session.id, operationID: operationID))

        case let .interruptionBegan(operationID):
            dispatch(.playbackInterrupted(sessionID: session.id, operationID: operationID))

        case let .interruptionEnded(operationID):
            dispatch(.playbackInterruptionEnded(sessionID: session.id, operationID: operationID))

        case let .failed(operationID, _):
            dispatch(.playbackFailed(sessionID: session.id, operationID: operationID))

        case let .rateChanged(operationID, requestID, trackID, rate):
            guard let requestID, let trackID else { return }
            dispatch(
                .playbackRateApplied(
                    sessionID: session.id,
                    operationID: operationID,
                    requestID: requestID,
                    trackID: trackID,
                    rate: rate
                )
            )

        case let .trackChanged(operationID, trackID):
            guard let trackIndex = musicCollection.tracks.firstIndex(where: { $0.id == trackID })
            else { return }
            dispatch(
                .playbackTrackChanged(
                    sessionID: session.id,
                    operationID: operationID,
                    trackID: trackID,
                    trackIndex: trackIndex
                )
            )

        case .prepared, .stateChanged:
            break
        }
    }

    private func startTicker(sessionID: Int) {
        taskStore.replace(.ticker) { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                guard self?.state.session?.id == sessionID else { return }
                guard let self else { return }
                let tempoMatched = currentTempoMatch()
                dispatch(.activeSecond(tempoMatched: tempoMatched))
            }
        }
    }

    private func currentTempoMatch() -> Bool? {
        guard case let .active(active) = state,
            case let .playing(.locked(spm), _) = active.activity,
            let trackID = active.session.currentTrackID,
            let tempo = musicCollection.tracks.first(where: { $0.id == trackID })?.tempo
        else { return nil }

        return TempoMatchEvaluator.measure(
            cadenceSPM: Double(spm),
            cadenceReliable: true,
            baseTempoBPM: tempo.baseBPM,
            appliedRate: active.session.appliedPlaybackRate,
            playbackActive: true
        )
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
