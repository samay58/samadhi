// Read this file before RunReducer: states describe what can be true, events enter, and effects leave.
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
        case let .playing(rhythm, _), let .paused(rhythm):
            rhythm
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
    // Effects name outside work without performing it. IDs make late callbacks safe to ignore.
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
    case audioRouteLost
    case audioRouteRestored
    case routeResumeTapped(acquisitionID: Int, timeoutID: Int)
    case activeSecond
    case finishCompleted(sessionID: Int)
    case summaryDismissed
}

public extension RunState {
    var session: RunSession? {
        switch self {
        case .ready, .summary:
            nil
        case let .preparing(value):
            value.session
        case let .permissionRecovery(value), let .finishing(value):
            value
        case let .active(value):
            value.session
        case let .confirmingFinish(value):
            value.session
        case let .routeRecovery(value):
            value.session
        }
    }
}
