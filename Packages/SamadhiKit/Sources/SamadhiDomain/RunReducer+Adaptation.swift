extension RunReducer {
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

    private func adapt(
        session: RunSession,
        cadenceSPM: Double?,
        cadenceReliable: Bool,
        deltaSeconds: Double,
        rateRequestID: Int
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
                deltaSeconds: deltaSeconds
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
}
