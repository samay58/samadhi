// Product behavior lives here as value-state transitions. The reducer returns outside work but never performs it.
public struct RunReducer: Sendable {
    private let trackCount: Int

    public init(trackCount: Int = 3) {
        self.trackCount = max(trackCount, 1)
    }

    public func reduce(state: RunState, event: RunEvent) -> (RunState, [RunEffect]) {
        switch (state, event) {
        case let (.ready, .startTapped(sessionID)):
            let session = RunSession(id: sessionID)
            return (
                .preparing(Preparation(session: session, stage: .authorization)),
                [.emitHaptic(.start), .requestMotionAuthorization(sessionID: sessionID)]
            )

        case let (.preparing(preparation), .authorizationResolved(sessionID, authorization))
        where preparation.session.id == sessionID && preparation.stage == .authorization:
            switch authorization {
            case .authorized:
                var next = preparation
                next.stage = .playback(.adaptive)
                return (.preparing(next), [.preparePlayback(sessionID: sessionID, mode: .adaptive)])
            case .denied, .unavailable:
                return (.permissionRecovery(preparation.session), [])
            }

        case let (.permissionRecovery(session), .useFixedRhythmTapped):
            var fixedSession = session
            fixedSession.mode = .fixed
            return (
                .preparing(Preparation(session: fixedSession, stage: .playback(.fixed))),
                [.preparePlayback(sessionID: session.id, mode: .fixed)]
            )

        case let (.preparing(preparation), .playbackPrepared(sessionID))
        where preparation.session.id == sessionID:
            let session = preparation.session
            switch preparation.stage {
            case .playback(.adaptive):
                let acquisitionID = 1
                return (
                    .active(
                        ActiveRun(
                            session: session,
                            activity: .playing(
                                rhythm: .acquiring(priorSPM: nil, acquisitionID: acquisitionID),
                                controls: .hidden
                            )
                        )
                    ),
                    [
                        .beginPlayback(sessionID: session.id),
                        .beginCadenceAcquisition(
                            sessionID: session.id,
                            acquisitionID: acquisitionID,
                            priorSPM: nil
                        ),
                    ]
                )
            case .playback(.fixed):
                return (
                    .active(ActiveRun(session: session, activity: .playing(rhythm: .fixed, controls: .hidden))),
                    [.beginPlayback(sessionID: session.id)]
                )
            case .authorization:
                return (state, [])
            }

        case let (.active(active), .cadenceLocked(sessionID, acquisitionID, spm)):
            // Both IDs must match because an old sensor callback can arrive after a restart.
            guard active.session.id == sessionID,
                case let .playing(.acquiring(_, currentID), controls) = active.activity,
                currentID == acquisitionID
            else { return (state, []) }
            var next = active
            next.activity = .playing(rhythm: .locked(spm: spm), controls: controls)
            return (.active(next), [.emitHaptic(.lock), .cancelTask(sessionID: sessionID, .acquisition)])

        case let (.active(active), .surfaceTapped(timeoutID)):
            guard case let .playing(rhythm, _) = active.activity else { return (state, []) }
            var next = active
            next.activity = .playing(rhythm: rhythm, controls: .timed(timeoutID: timeoutID))
            return (
                .active(next),
                [.scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID)]
            )

        case let (.active(active), .controlsTimedOut(timeoutID)):
            guard case let .playing(rhythm, .timed(currentID)) = active.activity,
                currentID == timeoutID
            else { return (state, []) }
            var next = active
            next.activity = .playing(rhythm: rhythm, controls: .hidden)
            return (.active(next), [])

        case let (.active(active), .controlsFocusEntered):
            // Visible controls stay pinned while VoiceOver owns focus.
            guard case let .playing(rhythm, controls) = active.activity, case .hidden = controls else {
                if case let .playing(rhythm, .timed) = active.activity {
                    var next = active
                    next.activity = .playing(rhythm: rhythm, controls: .voiceOverPinned)
                    return (.active(next), [.cancelTask(sessionID: active.session.id, .controlsTimeout)])
                }
                return (state, [])
            }
            var next = active
            next.activity = .playing(rhythm: rhythm, controls: .voiceOverPinned)
            return (.active(next), [])

        case let (.active(active), .controlsFocusExited(timeoutID)):
            guard case let .playing(rhythm, .voiceOverPinned) = active.activity else { return (state, []) }
            var next = active
            next.activity = .playing(rhythm: rhythm, controls: .timed(timeoutID: timeoutID))
            return (
                .active(next),
                [.scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID)]
            )

        case let (.active(active), .pauseTapped):
            guard case let .playing(rhythm, _) = active.activity else { return (state, []) }
            var next = active
            next.activity = .paused(rhythm: rhythm)
            return (
                .active(next),
                [
                    .cancelTask(sessionID: active.session.id, .acquisition),
                    .cancelTask(sessionID: active.session.id, .controlsTimeout),
                    .cancelTask(sessionID: active.session.id, .ticker),
                    .pausePlayback(sessionID: active.session.id),
                    .emitHaptic(.pause),
                ]
            )

        case let (.active(active), .resumeTapped(acquisitionID, timeoutID)):
            guard case let .paused(rhythm) = active.activity else { return (state, []) }
            let resumedRhythm: RhythmState
            let cadenceEffect: [RunEffect]
            switch rhythm {
            case .fixed:
                resumedRhythm = .fixed
                cadenceEffect = []
            case let .locked(spm):
                resumedRhythm = .acquiring(priorSPM: spm, acquisitionID: acquisitionID)
                cadenceEffect = [
                    .beginCadenceAcquisition(
                        sessionID: active.session.id,
                        acquisitionID: acquisitionID,
                        priorSPM: spm
                    )
                ]
            case let .acquiring(prior, _):
                resumedRhythm = .acquiring(priorSPM: prior, acquisitionID: acquisitionID)
                cadenceEffect = [
                    .beginCadenceAcquisition(
                        sessionID: active.session.id,
                        acquisitionID: acquisitionID,
                        priorSPM: prior
                    )
                ]
            }
            var next = active
            next.activity = .playing(rhythm: resumedRhythm, controls: .timed(timeoutID: timeoutID))
            return (
                .active(next),
                [.resumePlayback(sessionID: active.session.id), .emitHaptic(.resume)] + cadenceEffect + [
                    .scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID)
                ]
            )

        case let (.active(active), .skipTapped):
            var next = active
            next.session.trackIndex = (next.session.trackIndex + 1) % trackCount
            next.session.songCount += 1
            next.session.trackElapsedSeconds = 0
            return (.active(next), [.skipTrack(sessionID: active.session.id)])

        case let (.active(active), .previousTapped):
            var next = active
            next.session.trackIndex = (next.session.trackIndex - 1 + trackCount) % trackCount
            next.session.trackElapsedSeconds = 0
            return (.active(next), [.previousTrack(sessionID: active.session.id)])

        case let (.active(active), .finishTapped):
            switch active.activity {
            case .playing(_, .hidden):
                return (state, [])
            case .playing, .paused:
                return (
                    .confirmingFinish(
                        FinishConfirmation(session: active.session, origin: active.activity, hold: .armed)
                    ),
                    [.cancelTask(sessionID: active.session.id, .controlsTimeout)]
                )
            }

        case let (.confirmingFinish(confirmation), .finishHoldBegan(holdID)):
            guard confirmation.hold == .armed else { return (state, []) }
            var next = confirmation
            next.hold = .pressing(holdID: holdID)
            return (
                .confirmingFinish(next),
                [.scheduleFinishHold(sessionID: confirmation.session.id, holdID: holdID)]
            )

        case let (.confirmingFinish(confirmation), .finishHoldCancelled(holdID)):
            guard confirmation.hold == .pressing(holdID: holdID) else { return (state, []) }
            var next = confirmation
            next.hold = .armed
            return (
                .confirmingFinish(next),
                [.cancelTask(sessionID: confirmation.session.id, .finishHold)]
            )

        case let (.confirmingFinish(confirmation), .finishHoldCompleted(holdID)):
            guard confirmation.hold == .pressing(holdID: holdID) else { return (state, []) }
            return (
                .finishing(confirmation.session),
                [
                    .cancelAllTasks(sessionID: confirmation.session.id),
                    .fadeAndStop(sessionID: confirmation.session.id),
                    .emitHaptic(.finish),
                ]
            )

        case let (.active(active), .audioRouteLost):
            return routeRecovery(from: active.session, origin: active.activity)

        case let (.confirmingFinish(confirmation), .audioRouteLost):
            return routeRecovery(from: confirmation.session, origin: confirmation.origin)

        case let (.routeRecovery(recovery), .audioRouteRestored):
            // A restored route never restarts a running session without explicit user intent.
            var next = recovery
            next.availability = .restored
            if case .paused = recovery.origin {
                return (.active(ActiveRun(session: recovery.session, activity: recovery.origin)), [])
            }
            return (.routeRecovery(next), [])

        case let (.routeRecovery(recovery), .routeResumeTapped(acquisitionID, timeoutID)):
            guard recovery.availability == .restored,
                case let .playing(rhythm, _) = recovery.origin
            else { return (state, []) }
            let nextRhythm: RhythmState
            var effects: [RunEffect] = [.resumePlayback(sessionID: recovery.session.id)]
            switch rhythm {
            case .fixed:
                nextRhythm = .fixed
            case let .locked(spm):
                nextRhythm = .acquiring(priorSPM: spm, acquisitionID: acquisitionID)
                effects.append(
                    .beginCadenceAcquisition(
                        sessionID: recovery.session.id,
                        acquisitionID: acquisitionID,
                        priorSPM: spm
                    )
                )
            case let .acquiring(prior, _):
                nextRhythm = .acquiring(priorSPM: prior, acquisitionID: acquisitionID)
                effects.append(
                    .beginCadenceAcquisition(
                        sessionID: recovery.session.id,
                        acquisitionID: acquisitionID,
                        priorSPM: prior
                    )
                )
            }
            effects.append(
                .scheduleControlsTimeout(sessionID: recovery.session.id, timeoutID: timeoutID)
            )
            return (
                .active(
                    ActiveRun(
                        session: recovery.session,
                        activity: .playing(
                            rhythm: nextRhythm,
                            controls: .timed(timeoutID: timeoutID)
                        )
                    )
                ),
                effects
            )

        case let (.active(active), .activeSecond):
            // Only stable playback enters the summary. Paused and cadence-acquisition time is excluded.
            guard case let .playing(rhythm, _) = active.activity else { return (state, []) }
            var next = active
            switch rhythm {
            case let .locked(spm):
                next.session.recordSecond(cadence: spm, inStep: true)
            case .fixed:
                next.session.recordSecond(cadence: nil, inStep: nil)
            case .acquiring:
                return (state, [])
            }
            return (.active(next), [])

        case let (.finishing(session), .finishCompleted(sessionID)) where session.id == sessionID:
            let summary = session.summary
            return (.summary(summary), [])

        case (.summary, .summaryDismissed):
            return (.ready, [])

        default:
            return (state, [])
        }
    }

    private func routeRecovery(from session: RunSession, origin: RunActivity) -> (RunState, [RunEffect]) {
        (
            .routeRecovery(RouteRecovery(session: session, origin: origin, availability: .missing)),
            [
                .cancelAllTasks(sessionID: session.id),
                .pausePlayback(sessionID: session.id),
            ]
        )
    }
}
