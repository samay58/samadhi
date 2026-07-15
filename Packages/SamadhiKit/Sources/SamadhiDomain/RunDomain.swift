import Foundation

public enum MotionAuthorization: Sendable, Equatable {
    case authorized
    case denied
    case unavailable
}

public enum RunMode: Sendable, Equatable {
    case adaptive
    case fixed
}

public struct RunSummary: Sendable, Equatable {
    public let durationSeconds: Int
    public let averageCadence: Int?
    public let timeInStepPercent: Int
    public let songCount: Int

    public init(durationSeconds: Int, averageCadence: Int?, timeInStepPercent: Int, songCount: Int) {
        self.durationSeconds = durationSeconds
        self.averageCadence = averageCadence
        self.timeInStepPercent = timeInStepPercent
        self.songCount = songCount
    }
}

public struct RunSession: Sendable, Equatable {
    public let id: Int
    public var mode: RunMode
    public var elapsedActiveSeconds: Int
    public var cadenceTotal: Int
    public var cadenceSamples: Int
    public var inStepSamples: Int
    public var eligibleInStepSamples: Int
    public var songCount: Int
    public var trackIndex: Int
    public var trackElapsedSeconds: Int

    public init(id: Int, mode: RunMode = .adaptive) {
        self.id = id
        self.mode = mode
        elapsedActiveSeconds = 0
        cadenceTotal = 0
        cadenceSamples = 0
        inStepSamples = 0
        eligibleInStepSamples = 0
        songCount = 1
        trackIndex = 0
        trackElapsedSeconds = 0
    }

    public mutating func recordSecond(cadence: Int?, inStep: Bool?) {
        elapsedActiveSeconds += 1
        trackElapsedSeconds += 1
        if let cadence {
            cadenceTotal += cadence
            cadenceSamples += 1
        }
        if let inStep {
            eligibleInStepSamples += 1
            if inStep { inStepSamples += 1 }
        }
    }

    public var summary: RunSummary {
        RunSummary(
            durationSeconds: elapsedActiveSeconds,
            averageCadence: cadenceSamples == 0 ? nil : cadenceTotal / cadenceSamples,
            timeInStepPercent: eligibleInStepSamples == 0 ? 0 : (inStepSamples * 100) / eligibleInStepSamples,
            songCount: songCount
        )
    }
}

public enum PreparationStage: Sendable, Equatable {
    case authorization
    case playback(RunMode)
}

public struct Preparation: Sendable, Equatable {
    public var session: RunSession
    public var stage: PreparationStage
}

public enum RhythmState: Sendable, Equatable {
    case acquiring(priorSPM: Int?, acquisitionID: Int)
    case locked(spm: Int)
    case fixed
}

public enum ControlsState: Sendable, Equatable {
    case hidden
    case timed(timeoutID: Int)
    case voiceOverPinned
}

public enum RunActivity: Sendable, Equatable {
    case playing(rhythm: RhythmState, controls: ControlsState)
    case paused(rhythm: RhythmState)

    public var rhythm: RhythmState {
        switch self {
        case let .playing(rhythm, _), let .paused(rhythm): rhythm
        }
    }
}

public enum FinishHold: Sendable, Equatable {
    case armed
    case pressing(holdID: Int)
}

public struct ActiveRun: Sendable, Equatable {
    public var session: RunSession
    public var activity: RunActivity
}

public struct FinishConfirmation: Sendable, Equatable {
    public var session: RunSession
    public var origin: RunActivity
    public var hold: FinishHold
}

public enum RouteAvailability: Sendable, Equatable {
    case missing
    case restored
}

public struct RouteRecovery: Sendable, Equatable {
    public var session: RunSession
    public var origin: RunActivity
    public var availability: RouteAvailability
}

public enum RunState: Sendable, Equatable {
    case ready
    case preparing(Preparation)
    case permissionRecovery(RunSession)
    case active(ActiveRun)
    case confirmingFinish(FinishConfirmation)
    case routeRecovery(RouteRecovery)
    case finishing(RunSession)
    case summary(RunSummary)
}

public enum HapticEvent: Sendable, Equatable {
    case start
    case lock
    case pause
    case resume
    case finish
}

public enum RunTaskKind: Sendable, Equatable, Hashable {
    case authorization
    case preparation
    case acquisition
    case controlsTimeout
    case finishHold
    case ticker
    case finishing
    case lockBrief
    case simulatedRoute
}

public enum RunEffect: Sendable, Equatable {
    case requestMotionAuthorization(sessionID: Int)
    case preparePlayback(sessionID: Int, mode: RunMode)
    case beginPlayback(sessionID: Int)
    case beginCadenceAcquisition(sessionID: Int, acquisitionID: Int, priorSPM: Int?)
    case pausePlayback(sessionID: Int)
    case resumePlayback(sessionID: Int)
    case previousTrack(sessionID: Int)
    case skipTrack(sessionID: Int)
    case scheduleControlsTimeout(sessionID: Int, timeoutID: Int)
    case scheduleFinishHold(sessionID: Int, holdID: Int)
    case fadeAndStop(sessionID: Int)
    case persistSummary(RunSummary)
    case emitHaptic(HapticEvent)
    case cancelTask(sessionID: Int, RunTaskKind)
    case cancelAllTasks(sessionID: Int)
}

public enum RunEvent: Sendable, Equatable {
    case startTapped(sessionID: Int)
    case authorizationResolved(sessionID: Int, MotionAuthorization)
    case useFixedRhythmTapped
    case playbackPrepared(sessionID: Int)
    case cadenceLocked(sessionID: Int, acquisitionID: Int, spm: Int)
    case surfaceTapped(timeoutID: Int)
    case controlsTimedOut(timeoutID: Int)
    case controlsFocusEntered
    case controlsFocusExited(timeoutID: Int)
    case pauseTapped
    case resumeTapped(acquisitionID: Int, timeoutID: Int)
    case previousTapped
    case skipTapped
    case finishTapped
    case finishHoldBegan(holdID: Int)
    case finishHoldCancelled(holdID: Int)
    case finishHoldCompleted(holdID: Int)
    case finishConfirmationCancelled(timeoutID: Int)
    case audioRouteLost
    case audioRouteRestored
    case routeResumeTapped(acquisitionID: Int, timeoutID: Int)
    case activeSecond
    case finishCompleted(sessionID: Int)
    case summaryDismissed
}

public struct RunReducer: Sendable {
    public init() {}

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
                    .active(ActiveRun(
                        session: session,
                        activity: .playing(rhythm: .acquiring(priorSPM: nil, acquisitionID: acquisitionID), controls: .hidden)
                    )),
                    [
                        .beginPlayback(sessionID: session.id),
                        .beginCadenceAcquisition(sessionID: session.id, acquisitionID: acquisitionID, priorSPM: nil),
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
            guard active.session.id == sessionID,
                  case let .playing(.acquiring(_, currentID), controls) = active.activity,
                  currentID == acquisitionID else { return (state, []) }
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
                  currentID == timeoutID else { return (state, []) }
            var next = active
            next.activity = .playing(rhythm: rhythm, controls: .hidden)
            return (.active(next), [])

        case let (.active(active), .controlsFocusEntered):
            guard case let .playing(rhythm, controls) = active.activity,
                  case .hidden = controls else {
                if case let .playing(rhythm, .timed(_)) = active.activity {
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
            return (.active(next), [.scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID)])

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
                cadenceEffect = [.beginCadenceAcquisition(sessionID: active.session.id, acquisitionID: acquisitionID, priorSPM: spm)]
            case let .acquiring(prior, _):
                resumedRhythm = .acquiring(priorSPM: prior, acquisitionID: acquisitionID)
                cadenceEffect = [.beginCadenceAcquisition(sessionID: active.session.id, acquisitionID: acquisitionID, priorSPM: prior)]
            }
            var next = active
            next.activity = .playing(rhythm: resumedRhythm, controls: .timed(timeoutID: timeoutID))
            return (
                .active(next),
                [.resumePlayback(sessionID: active.session.id), .emitHaptic(.resume)] + cadenceEffect + [
                    .scheduleControlsTimeout(sessionID: active.session.id, timeoutID: timeoutID),
                ]
            )

        case let (.active(active), .skipTapped):
            var next = active
            next.session.trackIndex = (next.session.trackIndex + 1) % 3
            next.session.songCount += 1
            next.session.trackElapsedSeconds = 0
            return (.active(next), [.skipTrack(sessionID: active.session.id)])

        case let (.active(active), .previousTapped):
            var next = active
            next.session.trackIndex = (next.session.trackIndex + 2) % 3
            next.session.trackElapsedSeconds = 0
            return (.active(next), [.previousTrack(sessionID: active.session.id)])

        case let (.active(active), .finishTapped):
            switch active.activity {
            case .playing(_, .hidden):
                return (state, [])
            case .playing, .paused:
                return (
                    .confirmingFinish(FinishConfirmation(session: active.session, origin: active.activity, hold: .armed)),
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

        case let (.confirmingFinish(confirmation), .finishConfirmationCancelled(timeoutID)):
            let active = ActiveRun(session: confirmation.session, activity: confirmation.origin)
            if case let .playing(rhythm, _) = confirmation.origin {
                var next = active
                next.activity = .playing(rhythm: rhythm, controls: .timed(timeoutID: timeoutID))
                return (
                    .active(next),
                    [.cancelTask(sessionID: confirmation.session.id, .finishHold), .scheduleControlsTimeout(sessionID: confirmation.session.id, timeoutID: timeoutID)]
                )
            }
            return (.active(active), [.cancelTask(sessionID: confirmation.session.id, .finishHold)])

        case let (.active(active), .audioRouteLost):
            return routeRecovery(from: active.session, origin: active.activity)

        case let (.confirmingFinish(confirmation), .audioRouteLost):
            return routeRecovery(from: confirmation.session, origin: confirmation.origin)

        case let (.routeRecovery(recovery), .audioRouteRestored):
            var next = recovery
            next.availability = .restored
            if case .paused = recovery.origin {
                return (.active(ActiveRun(session: recovery.session, activity: recovery.origin)), [])
            }
            return (.routeRecovery(next), [])

        case let (.routeRecovery(recovery), .routeResumeTapped(acquisitionID, timeoutID)):
            guard recovery.availability == .restored,
                  case let .playing(rhythm, _) = recovery.origin else { return (state, []) }
            let nextRhythm: RhythmState
            var effects: [RunEffect] = [.resumePlayback(sessionID: recovery.session.id)]
            switch rhythm {
            case .fixed:
                nextRhythm = .fixed
            case let .locked(spm):
                nextRhythm = .acquiring(priorSPM: spm, acquisitionID: acquisitionID)
                effects.append(.beginCadenceAcquisition(sessionID: recovery.session.id, acquisitionID: acquisitionID, priorSPM: spm))
            case let .acquiring(prior, _):
                nextRhythm = .acquiring(priorSPM: prior, acquisitionID: acquisitionID)
                effects.append(.beginCadenceAcquisition(sessionID: recovery.session.id, acquisitionID: acquisitionID, priorSPM: prior))
            }
            effects.append(.scheduleControlsTimeout(sessionID: recovery.session.id, timeoutID: timeoutID))
            return (
                .active(ActiveRun(session: recovery.session, activity: .playing(rhythm: nextRhythm, controls: .timed(timeoutID: timeoutID)))),
                effects
            )

        case let (.active(active), .activeSecond):
            guard case let .playing(rhythm, _) = active.activity else { return (state, []) }
            var next = active
            switch rhythm {
            case let .locked(spm): next.session.recordSecond(cadence: spm, inStep: true)
            case .fixed: next.session.recordSecond(cadence: nil, inStep: nil)
            case .acquiring: return (state, [])
            }
            return (.active(next), [])

        case let (.finishing(session), .finishCompleted(sessionID)) where session.id == sessionID:
            let summary = session.summary
            return (.summary(summary), [.persistSummary(summary)])

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

public extension RunState {
    var session: RunSession? {
        switch self {
        case .ready, .summary: nil
        case let .preparing(value): value.session
        case let .permissionRecovery(value), let .finishing(value): value
        case let .active(value): value.session
        case let .confirmingFinish(value): value.session
        case let .routeRecovery(value): value.session
        }
    }
}
