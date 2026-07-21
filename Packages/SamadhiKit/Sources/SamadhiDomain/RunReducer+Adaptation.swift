extension RunReducer {
    enum RhythmControlChange: Sendable, Equatable {
        case adjust(Int)
        case manual
        case automatic
    }

    func reduceCadenceUpdate(
        active: ActiveRun,
        sessionID: Int,
        acquisitionID: Int,
        stepsPerMinute: Double,
        deltaSeconds: Double,
        rateRequestID: Int
    ) -> (RunState, [RunEffect]) {
        guard active.session.id == sessionID,
            active.session.cadenceAcquisitionID == acquisitionID,
            case let .playing(rhythm, controls) = active.activity
        else { return (.active(active), []) }

        let firstLock: Bool
        switch rhythm {
        case .acquiring:
            firstLock = true
        case .locked:
            firstLock = false
        case .fixed:
            return (.active(active), [])
        }

        var next = active
        next.activity = .playing(
            rhythm: .locked(spm: Int(stepsPerMinute.rounded())),
            controls: controls
        )
        let adaptation = adapt(
            session: next.session,
            cadenceSPM: stepsPerMinute,
            cadenceReliable: true,
            deltaSeconds: deltaSeconds,
            rateRequestID: rateRequestID
        )
        next.session = adaptation.session
        var effects = firstLock ? [RunEffect.emitHaptic(.lock)] : []
        effects.append(contentsOf: adaptation.effects)
        let transition = planTrackTransition(
            session: next.session,
            deltaSeconds: deltaSeconds,
            selectionID: rateRequestID
        )
        next.session = transition.session
        effects.append(contentsOf: transition.effects)
        return (.active(next), effects)
    }

    func reduceCadenceConfidenceLoss(
        active: ActiveRun,
        sessionID: Int,
        acquisitionID: Int,
        deltaSeconds: Double,
        rateRequestID: Int
    ) -> (RunState, [RunEffect]) {
        guard active.session.id == sessionID,
            active.session.cadenceAcquisitionID == acquisitionID,
            case let .playing(rhythm, controls) = active.activity,
            rhythm != .fixed
        else { return (.active(active), []) }

        var next = active
        let adaptation = adapt(
            session: next.session,
            cadenceSPM: nil,
            cadenceReliable: false,
            deltaSeconds: deltaSeconds,
            rateRequestID: rateRequestID
        )
        next.session = adaptation.session
        if (next.session.adaptationState.confidenceLostSeconds ?? 0) >= 10 {
            let priorSPM: Int?
            switch rhythm {
            case let .locked(spm):
                priorSPM = spm
            case let .acquiring(prior, _):
                priorSPM = prior
            case .fixed:
                priorSPM = nil
            }
            next.activity = .playing(
                rhythm: .acquiring(priorSPM: priorSPM, acquisitionID: acquisitionID),
                controls: controls
            )
        }
        return (.active(next), adaptation.effects)
    }

    func reduceCadenceFailure(
        active: ActiveRun,
        sessionID: Int,
        acquisitionID: Int
    ) -> (RunState, [RunEffect]) {
        guard active.session.id == sessionID,
            active.session.cadenceAcquisitionID == acquisitionID,
            active.session.mode == .adaptive
        else { return (.active(active), []) }

        return (
            .permissionRecovery(active.session),
            [
                .cancelTask(sessionID: sessionID, .acquisition),
                .cancelTask(sessionID: sessionID, .ticker),
                .pausePlayback(sessionID: sessionID),
            ]
        )
    }

    func reduceRhythmControlChange(
        active: ActiveRun,
        change: RhythmControlChange,
        rateRequestID: Int,
        timeoutID: Int
    ) -> (RunState, [RunEffect]) {
        guard active.session.mode == .adaptive,
            case let .playing(rhythm, _) = active.activity
        else { return (.active(active), []) }

        let cadenceSPM: Double?
        let cadenceReliable: Bool
        switch rhythm {
        case let .locked(spm):
            cadenceSPM = Double(spm)
            cadenceReliable = true
        case let .acquiring(priorSPM, _):
            cadenceSPM = priorSPM.map(Double.init)
            cadenceReliable = false
        case .fixed:
            cadenceSPM = nil
            cadenceReliable = false
        }

        var next = active
        let priorControl = next.session.rhythmControl
        switch change {
        case let .adjust(steps):
            _ = next.session.rhythmControl.adjust(by: steps)
        case .manual:
            let seed = next.session.adaptationState.requestedBPM ?? cadenceSPM ?? 168
            next.session.rhythmControl.useManual(seedBPM: seed)
        case .automatic:
            next.session.rhythmControl.resetToAutomatic()
        }

        next.activity = .playing(
            rhythm: rhythm,
            controls: .timed(surface: .rhythm, timeoutID: timeoutID)
        )

        guard next.session.rhythmControl != priorControl else {
            return (
                .active(next),
                [
                    .emitHaptic(.rhythmLimit),
                    .scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID),
                ]
            )
        }

        let adaptation = adapt(
            session: next.session,
            cadenceSPM: cadenceSPM,
            cadenceReliable: cadenceReliable,
            deltaSeconds: 1,
            rateRequestID: rateRequestID,
            forceTargetUpdate: true
        )
        next.session = adaptation.session
        let transition = planTrackTransition(
            session: next.session,
            deltaSeconds: 0,
            selectionID: rateRequestID
        )
        next.session = transition.session

        let haptic: HapticEvent
        if next.session.rhythmControl.mode == .automatic,
            next.session.rhythmControl.automaticCorrectionBPM == 0
        {
            haptic = .rhythmAuto
        } else {
            let detentValue =
                next.session.rhythmControl.mode == .automatic
                ? next.session.rhythmControl.automaticCorrectionBPM
                : next.session.rhythmControl.manualTargetBPM
            haptic = .rhythmStep(isMajor: detentValue.isMultiple(of: 5))
        }

        return (
            .active(next),
            [.emitHaptic(haptic)] + adaptation.effects + transition.effects + [
                .scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID)
            ]
        )
    }

    func adaptManualControlAfterTrackChange(
        active: ActiveRun,
        rateRequestID: Int
    ) -> (RunState, [RunEffect]) {
        guard active.session.rhythmControl.mode == .manual else {
            return (.active(active), [])
        }

        let cadenceSPM: Double?
        let cadenceReliable: Bool
        switch active.activity.rhythm {
        case let .locked(spm):
            cadenceSPM = Double(spm)
            cadenceReliable = true
        case let .acquiring(priorSPM, _):
            cadenceSPM = priorSPM.map(Double.init)
            cadenceReliable = false
        case .fixed:
            cadenceSPM = nil
            cadenceReliable = false
        }

        var next = active
        let adaptation = adapt(
            session: next.session,
            cadenceSPM: cadenceSPM,
            cadenceReliable: cadenceReliable,
            deltaSeconds: 1,
            rateRequestID: rateRequestID,
            forceTargetUpdate: true
        )
        next.session = adaptation.session
        return (.active(next), adaptation.effects)
    }

    private func adapt(
        session: RunSession,
        cadenceSPM: Double?,
        cadenceReliable: Bool,
        deltaSeconds: Double,
        rateRequestID: Int,
        forceTargetUpdate: Bool = false
    ) -> (session: RunSession, effects: [RunEffect]) {
        guard session.mode == .adaptive,
            let trackID = session.currentTrackID,
            let track = tracks.first(where: { $0.id == trackID }),
            let tempo = track.tempo
        else { return (session, []) }

        var next = session
        let decision = adaptationPolicy.update(
            state: session.adaptationState,
            input: AdaptationInput(
                cadenceSPM: cadenceSPM,
                cadenceReliable: cadenceReliable,
                baseTempoBPM: tempo.baseBPM,
                analysisConfidence: tempo.confidence,
                appliedRate: session.appliedPlaybackRate,
                deltaSeconds: deltaSeconds,
                rhythmControl: session.rhythmControl,
                forceTargetUpdate: forceTargetUpdate
            )
        )
        next.adaptationState = decision.nextState

        guard abs(decision.commandedRate - session.appliedPlaybackRate) > 0.000_1 else {
            return (next, [])
        }

        next.pendingRateRequestID = rateRequestID
        return (
            next,
            [
                .setPlaybackRate(
                    sessionID: session.id,
                    operationID: session.playbackOperationID,
                    requestID: rateRequestID,
                    trackID: trackID,
                    rate: decision.commandedRate
                )
            ]
        )
    }

    private func planTrackTransition(
        session: RunSession,
        deltaSeconds: Double,
        selectionID: Int
    ) -> (session: RunSession, effects: [RunEffect]) {
        var next = session
        guard session.adaptationState.isAtLimit,
            let requestedBPM = session.adaptationState.requestedBPM,
            let match = TrackMatchPlanner().select(
                requestedBPM: requestedBPM,
                from: tracks,
                currentTrackID: session.currentTrackID
            ),
            match.trackID != session.currentTrackID
        else {
            let shouldClearPlan =
                next.pendingTrackSelectionID != nil
                || next.preparedNextTrackID != nil
            next.incompatibleTrackSeconds = 0
            next.pendingTrackSelectionID = nil
            next.pendingNextTrackID = nil
            next.preparedNextTrackID = nil
            return (
                next,
                shouldClearPlan
                    ? [
                        .clearPreparedNextTrack(
                            sessionID: session.id,
                            operationID: session.playbackOperationID,
                            selectionID: selectionID
                        )
                    ]
                    : []
            )
        }

        next.incompatibleTrackSeconds += max(deltaSeconds, 0)
        guard next.incompatibleTrackSeconds >= 5 else { return (next, []) }
        guard next.pendingNextTrackID != match.trackID,
            next.preparedNextTrackID != match.trackID
        else { return (next, []) }

        next.pendingTrackSelectionID = selectionID
        next.pendingNextTrackID = match.trackID
        next.preparedNextTrackID = nil
        return (
            next,
            [
                .prepareNextTrack(
                    sessionID: session.id,
                    operationID: session.playbackOperationID,
                    selectionID: selectionID,
                    trackID: match.trackID
                )
            ]
        )
    }
}
