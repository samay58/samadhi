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
    public let tempoMatchedPercent: Int?
    public let tempoMatchedCoveragePercent: Int
    public let automaticSeconds: Int
    public let manualSeconds: Int
    public let songCount: Int

    public init(
        durationSeconds: Int,
        averageCadence: Int?,
        tempoMatchedPercent: Int?,
        tempoMatchedCoveragePercent: Int = 0,
        automaticSeconds: Int = 0,
        manualSeconds: Int = 0,
        songCount: Int
    ) {
        self.durationSeconds = durationSeconds
        self.averageCadence = averageCadence
        self.tempoMatchedPercent = tempoMatchedPercent
        self.tempoMatchedCoveragePercent = tempoMatchedCoveragePercent
        self.automaticSeconds = automaticSeconds
        self.manualSeconds = manualSeconds
        self.songCount = songCount
    }
}

public struct RunSession: Sendable, Equatable {
    public let id: Int
    public var mode: RunMode
    public var elapsedActiveSeconds: Int
    public var cadenceTotal: Int
    public var cadenceSamples: Int
    public var tempoMatchedSamples: Int
    public var eligibleTempoMatchSamples: Int
    public var automaticActiveSeconds: Int
    public var manualActiveSeconds: Int
    public var songCount: Int
    public var trackIndex: Int
    public var trackElapsedSeconds: Int
    public var trackDurationSeconds: Int?
    public var playbackOperationID: Int
    public var currentTrackID: MusicTrackID?
    public var cadenceAcquisitionID: Int?
    public var adaptationState: AdaptationState
    public var rhythmControl: RhythmControlState
    public var appliedPlaybackRate: Double
    public var pendingRateRequestID: Int?
    public var pendingCommandedRate: Double?
    public var incompatibleTrackSeconds: Double
    public var pendingTrackSelectionID: Int?
    public var pendingNextTrackID: MusicTrackID?
    public var preparedNextTrackID: MusicTrackID?
    public var immediateTrackSelectionID: Int?

    public init(id: Int, mode: RunMode = .adaptive, playbackOperationID: Int? = nil) {
        self.id = id
        self.mode = mode
        elapsedActiveSeconds = 0
        cadenceTotal = 0
        cadenceSamples = 0
        tempoMatchedSamples = 0
        eligibleTempoMatchSamples = 0
        automaticActiveSeconds = 0
        manualActiveSeconds = 0
        songCount = 1
        trackIndex = 0
        trackElapsedSeconds = 0
        trackDurationSeconds = nil
        self.playbackOperationID = playbackOperationID ?? id
        currentTrackID = nil
        cadenceAcquisitionID = nil
        adaptationState = .initial
        rhythmControl = .initial
        appliedPlaybackRate = 1
        pendingRateRequestID = nil
        pendingCommandedRate = nil
        incompatibleTrackSeconds = 0
        pendingTrackSelectionID = nil
        pendingNextTrackID = nil
        preparedNextTrackID = nil
        immediateTrackSelectionID = nil
    }

    public mutating func recordSecond(cadence: Int?, tempoMatched: Bool?) {
        elapsedActiveSeconds += 1
        trackElapsedSeconds += 1
        switch rhythmControl.mode {
        case .automatic:
            automaticActiveSeconds += 1
        case .manual:
            manualActiveSeconds += 1
        }
        if let cadence {
            cadenceTotal += cadence
            cadenceSamples += 1
        }
        if let tempoMatched {
            eligibleTempoMatchSamples += 1
            if tempoMatched { tempoMatchedSamples += 1 }
        }
    }

    public var summary: RunSummary {
        let coveragePercent =
            elapsedActiveSeconds == 0
            ? 0
            : (eligibleTempoMatchSamples * 100) / elapsedActiveSeconds
        return RunSummary(
            durationSeconds: elapsedActiveSeconds,
            averageCadence: cadenceSamples == 0 ? nil : cadenceTotal / cadenceSamples,
            tempoMatchedPercent: mode == .fixed || coveragePercent < 80
                ? nil
                : (tempoMatchedSamples * 100) / eligibleTempoMatchSamples,
            tempoMatchedCoveragePercent: coveragePercent,
            automaticSeconds: automaticActiveSeconds,
            manualSeconds: manualActiveSeconds,
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

public enum RunControlSurface: Sendable, Equatable {
    case transport
    case rhythm
}

public enum ControlsState: Sendable, Equatable {
    case hidden
    case timed(surface: RunControlSurface, timeoutID: Int)
    case voiceOverPinned(surface: RunControlSurface)

    public var surface: RunControlSurface? {
        switch self {
        case .hidden:
            nil
        case let .timed(surface, _), let .voiceOverPinned(surface):
            surface
        }
    }
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
    case rhythmStep(direction: RhythmAdjustmentDirection, isMajor: Bool)
    case rhythmAuto
    case rhythmLimit
}

public enum RunTaskKind: Sendable, Equatable, Hashable {
    case authorization
    case preparation
    case playbackCommand
    case trackSelection
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
    case preparePlayback(
        sessionID: Int,
        mode: RunMode,
        startingTrackID: MusicTrackID
    )
    case beginPlayback(sessionID: Int)
    case beginCadenceAcquisition(sessionID: Int, acquisitionID: Int, priorSPM: Int?)
    case pausePlayback(sessionID: Int)
    case resumePlayback(sessionID: Int)
    case previousTrack(sessionID: Int)
    case skipTrack(sessionID: Int)
    case prepareNextTrack(
        sessionID: Int,
        operationID: Int,
        selectionID: Int,
        trackID: MusicTrackID
    )
    case clearPreparedNextTrack(
        sessionID: Int,
        operationID: Int,
        selectionID: Int
    )
    case setPlaybackRate(
        sessionID: Int,
        operationID: Int,
        requestID: Int,
        trackID: MusicTrackID,
        rate: Double
    )
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
    case playbackPrepared(sessionID: Int, trackID: MusicTrackID)
    case nextTrackPrepared(
        sessionID: Int,
        operationID: Int,
        selectionID: Int,
        trackID: MusicTrackID
    )
    case nextTrackPreparationFailed(
        sessionID: Int,
        operationID: Int,
        selectionID: Int,
        trackID: MusicTrackID
    )
    case cadenceUpdated(
        sessionID: Int,
        acquisitionID: Int,
        stepsPerMinute: Double,
        deltaSeconds: Double,
        rateRequestID: Int
    )
    case cadenceConfidenceLost(
        sessionID: Int,
        acquisitionID: Int,
        deltaSeconds: Double,
        rateRequestID: Int
    )
    case cadenceAcquisitionFailed(sessionID: Int, acquisitionID: Int)
    case surfaceTapped(timeoutID: Int)
    case rhythmControlRevealed(timeoutID: Int)
    case rhythmControlAdjusted(steps: Int, rateRequestID: Int, timeoutID: Int)
    case rhythmControlSetManual(rateRequestID: Int, timeoutID: Int)
    case rhythmControlReset(rateRequestID: Int, timeoutID: Int)
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
    case playbackProgress(
        sessionID: Int,
        operationID: Int,
        trackIndex: Int,
        elapsedSeconds: Int,
        durationSeconds: Int
    )
    case playbackRouteLost(sessionID: Int, operationID: Int)
    case playbackRouteRestored(sessionID: Int, operationID: Int)
    case playbackInterrupted(sessionID: Int, operationID: Int)
    case playbackInterruptionEnded(sessionID: Int, operationID: Int)
    case playbackRateApplied(
        sessionID: Int,
        operationID: Int,
        requestID: Int,
        trackID: MusicTrackID,
        rate: Double,
        latencySeconds: Double
    )
    case playbackTrackChanged(
        sessionID: Int,
        operationID: Int,
        trackID: MusicTrackID,
        trackIndex: Int,
        rateRequestID: Int
    )
    case playbackFailed(sessionID: Int, operationID: Int)
    case activeSecond(tempoMatched: Bool?)
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
