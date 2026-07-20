// Product behavior lives here as value-state transitions. The reducer returns outside work but never performs it.
public struct RunReducer: Sendable {
    private let trackCount: Int
    private let requiresAdaptiveReadyTrack: Bool
    let tracks: [MusicTrack]
    let adaptationPolicy: AdaptationPolicy

    public init(trackCount: Int = 3) {
        self.trackCount = max(trackCount, 1)
        requiresAdaptiveReadyTrack = false
        tracks = []
        adaptationPolicy = AdaptationPolicy()
    }

    public init(tracks: [MusicTrack]) {
        self.tracks = tracks
        trackCount = max(tracks.count, 1)
        requiresAdaptiveReadyTrack = true
        adaptationPolicy = AdaptationPolicy()
    }

    public func reduce(state: RunState, event: RunEvent) -> (RunState, [RunEffect]) {
        switch (state, event) {
        case let (.ready, .startTapped(sessionID)):
            guard !requiresAdaptiveReadyTrack || tracks.contains(where: \.isAdaptiveReady) else {
                return (state, [])
            }
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

        case let (.preparing(preparation), .playbackPrepared(sessionID, trackID))
        where preparation.session.id == sessionID:
            guard tracks.isEmpty || tracks.contains(where: { $0.id == trackID }) else {
                return (state, [])
            }
            var session = preparation.session
            session.currentTrackID = trackID
            switch preparation.stage {
            case .playback(.adaptive):
                let acquisitionID = 1
                session.cadenceAcquisitionID = acquisitionID
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

        case let (
            .preparing(preparation),
            .playbackFailed(sessionID, operationID)
        )
        where preparation.session.id == sessionID
            && preparation.session.playbackOperationID == operationID:
            return (.ready, [.cancelAllTasks(sessionID: sessionID)])

        case let (
            .active(active),
            .cadenceUpdated(
                sessionID,
                acquisitionID,
                stepsPerMinute,
                deltaSeconds,
                rateRequestID
            )
        ):
            return reduceCadenceUpdate(
                active: active,
                sessionID: sessionID,
                acquisitionID: acquisitionID,
                stepsPerMinute: stepsPerMinute,
                deltaSeconds: deltaSeconds,
                rateRequestID: rateRequestID
            )

        case let (
            .active(active),
            .cadenceConfidenceLost(
                sessionID,
                acquisitionID,
                deltaSeconds,
                rateRequestID
            )
        ):
            return reduceCadenceConfidenceLoss(
                active: active,
                sessionID: sessionID,
                acquisitionID: acquisitionID,
                deltaSeconds: deltaSeconds,
                rateRequestID: rateRequestID
            )

        case let (.active(active), .cadenceAcquisitionFailed(sessionID, acquisitionID)):
            return reduceCadenceFailure(
                active: active,
                sessionID: sessionID,
                acquisitionID: acquisitionID
            )

        case let (.active(active), .surfaceTapped(timeoutID)):
            guard case let .playing(rhythm, controls) = active.activity,
                controls.surface != .rhythm
            else { return (state, []) }
            var next = active
            next.activity = .playing(
                rhythm: rhythm,
                controls: .timed(surface: .transport, timeoutID: timeoutID)
            )
            return (
                .active(next),
                [.scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID)]
            )

        case let (.active(active), .rhythmControlRevealed(timeoutID)):
            guard active.session.mode == .adaptive,
                case let .playing(rhythm, _) = active.activity
            else { return (state, []) }
            var next = active
            next.activity = .playing(
                rhythm: rhythm,
                controls: .timed(surface: .rhythm, timeoutID: timeoutID)
            )
            return (
                .active(next),
                [.scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID)]
            )

        case let (.active(active), .rhythmControlAdjusted(steps, rateRequestID, timeoutID)):
            return reduceRhythmControlChange(
                active: active,
                change: .adjust(steps),
                rateRequestID: rateRequestID,
                timeoutID: timeoutID
            )

        case let (.active(active), .rhythmControlSetManual(rateRequestID, timeoutID)):
            return reduceRhythmControlChange(
                active: active,
                change: .manual,
                rateRequestID: rateRequestID,
                timeoutID: timeoutID
            )

        case let (.active(active), .rhythmControlReset(rateRequestID, timeoutID)):
            return reduceRhythmControlChange(
                active: active,
                change: .automatic,
                rateRequestID: rateRequestID,
                timeoutID: timeoutID
            )

        case let (.active(active), .controlsTimedOut(timeoutID)):
            guard case let .playing(rhythm, .timed(_, currentID)) = active.activity,
                currentID == timeoutID
            else { return (state, []) }
            var next = active
            next.activity = .playing(rhythm: rhythm, controls: .hidden)
            return (.active(next), [])

        case let (.active(active), .controlsFocusEntered):
            // Visible controls stay pinned while VoiceOver owns focus.
            guard case let .playing(rhythm, controls) = active.activity, case .hidden = controls else {
                if case let .playing(rhythm, .timed(surface, _)) = active.activity {
                    var next = active
                    next.activity = .playing(
                        rhythm: rhythm,
                        controls: .voiceOverPinned(surface: surface)
                    )
                    return (.active(next), [.cancelTask(sessionID: active.session.id, .controlsTimeout)])
                }
                return (state, [])
            }
            var next = active
            next.activity = .playing(
                rhythm: rhythm,
                controls: .voiceOverPinned(surface: .transport)
            )
            return (.active(next), [])

        case let (.active(active), .controlsFocusExited(timeoutID)):
            guard case let .playing(rhythm, .voiceOverPinned(surface)) = active.activity else {
                return (state, [])
            }
            var next = active
            next.activity = .playing(
                rhythm: rhythm,
                controls: .timed(surface: surface, timeoutID: timeoutID)
            )
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
            next.session.cadenceAcquisitionID = resumedRhythm == .fixed ? nil : acquisitionID
            next.activity = .playing(
                rhythm: resumedRhythm,
                controls: .timed(surface: .transport, timeoutID: timeoutID)
            )
            return (
                .active(next),
                [.resumePlayback(sessionID: active.session.id), .emitHaptic(.resume)] + cadenceEffect + [
                    .scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID)
                ]
            )

        case let (.active(active), .skipTapped):
            var next = active
            next.session.trackIndex = (next.session.trackIndex + 1) % trackCount
            if tracks.indices.contains(next.session.trackIndex) {
                next.session.currentTrackID = tracks[next.session.trackIndex].id
            }
            next.session.pendingRateRequestID = nil
            next.session.songCount += 1
            next.session.trackElapsedSeconds = 0
            next.session.trackDurationSeconds = nil
            return (.active(next), [.skipTrack(sessionID: active.session.id)])

        case let (.active(active), .previousTapped):
            var next = active
            next.session.trackIndex = (next.session.trackIndex - 1 + trackCount) % trackCount
            if tracks.indices.contains(next.session.trackIndex) {
                next.session.currentTrackID = tracks[next.session.trackIndex].id
            }
            next.session.pendingRateRequestID = nil
            next.session.trackElapsedSeconds = 0
            next.session.trackDurationSeconds = nil
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
            var resumedSession = recovery.session
            resumedSession.cadenceAcquisitionID = nextRhythm == .fixed ? nil : acquisitionID
            return (
                .active(
                    ActiveRun(
                        session: resumedSession,
                        activity: .playing(
                            rhythm: nextRhythm,
                            controls: .timed(surface: .transport, timeoutID: timeoutID)
                        )
                    )
                ),
                effects
            )

        case let (
            .active(active),
            .playbackProgress(
                sessionID,
                operationID,
                trackIndex,
                elapsedSeconds,
                durationSeconds
            )
        ):
            guard active.session.id == sessionID,
                active.session.playbackOperationID == operationID,
                (0..<trackCount).contains(trackIndex)
            else { return (state, []) }
            var next = active
            if next.session.trackIndex != trackIndex {
                next.session.trackIndex = trackIndex
                next.session.songCount += 1
            }
            next.session.trackElapsedSeconds = max(elapsedSeconds, 0)
            next.session.trackDurationSeconds = max(durationSeconds, 0)
            return (.active(next), [])

        case let (
            .active(active),
            .playbackRateApplied(
                sessionID,
                operationID,
                requestID,
                trackID,
                rate
            )
        ):
            guard active.session.id == sessionID,
                active.session.playbackOperationID == operationID,
                active.session.pendingRateRequestID == requestID,
                active.session.currentTrackID == trackID
            else { return (state, []) }
            var next = active
            next.session.appliedPlaybackRate = min(max(rate, 0.94), 1.06)
            next.session.pendingRateRequestID = nil
            return (.active(next), [])

        case let (
            .active(active),
            .playbackTrackChanged(
                sessionID,
                operationID,
                trackID,
                trackIndex,
                rateRequestID
            )
        ):
            guard active.session.id == sessionID,
                active.session.playbackOperationID == operationID,
                (0..<trackCount).contains(trackIndex),
                tracks.isEmpty || tracks[trackIndex].id == trackID
            else { return (state, []) }
            var next = active
            if next.session.trackIndex != trackIndex {
                next.session.songCount += 1
            }
            next.session.trackIndex = trackIndex
            next.session.currentTrackID = trackID
            next.session.trackElapsedSeconds = 0
            next.session.trackDurationSeconds = nil
            next.session.pendingRateRequestID = nil
            return adaptManualControlAfterTrackChange(
                active: next,
                rateRequestID: rateRequestID
            )

        case let (
            .active(active),
            .playbackRouteLost(sessionID, operationID)
        ),
            let (
                .active(active),
                .playbackInterrupted(sessionID, operationID)
            ),
            let (
                .active(active),
                .playbackFailed(sessionID, operationID)
            ):
            guard active.session.id == sessionID,
                active.session.playbackOperationID == operationID
            else { return (state, []) }
            return routeRecovery(from: active.session, origin: active.activity)

        case let (
            .routeRecovery(recovery),
            .playbackRouteRestored(sessionID, operationID)
        ),
            let (
                .routeRecovery(recovery),
                .playbackInterruptionEnded(sessionID, operationID)
            ):
            guard recovery.session.id == sessionID,
                recovery.session.playbackOperationID == operationID
            else { return (state, []) }
            var next = recovery
            next.availability = .restored
            if case .paused = recovery.origin {
                return (.active(ActiveRun(session: recovery.session, activity: recovery.origin)), [])
            }
            return (.routeRecovery(next), [])

        case let (.active(active), .activeSecond(tempoMatched)):
            // Only stable playback enters the summary. Paused and cadence-acquisition time is excluded.
            guard case let .playing(rhythm, _) = active.activity else { return (state, []) }
            var next = active
            switch rhythm {
            case let .locked(spm):
                next.session.recordSecond(cadence: spm, tempoMatched: tempoMatched)
            case .fixed:
                next.session.recordSecond(cadence: nil, tempoMatched: nil)
            case .acquiring:
                guard next.session.rhythmControl.mode == .manual else { return (state, []) }
                next.session.recordSecond(cadence: nil, tempoMatched: nil)
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
