// Read this file before RunReducer: states describe what can be true, events enter, and effects leave.
public enum MotionAuthorization: Sendable, Equatable {
    case authorized
    case denied
    case unavailable
}

public enum CadenceTrackingState: String, Sendable, Equatable, Codable {
    case acquiring
    case tracking
    case reacquiring
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
    public var autoTargetState: AutoTargetState
    public var rhythmControl: RhythmControlState
    public var appliedPlaybackRate: Double
    public var pendingRateRequestID: Int?
    public var pendingCommandedRate: Double?
    public var incompatibleTrackSeconds: Double
    public var pendingTrackSelectionID: Int?
    public var pendingNextTrackID: MusicTrackID?
    public var preparedNextTrackID: MusicTrackID?
    public var autoFeedback: AutoFeedbackState
    // Why the current song became current. Diagnostics read it; no product rule branches on it.
    public var lastTrackChangeReason: TrackChangeReason?
    // The collection index the player's queue continues after. A prepared song is slotted in
    // after the song that was playing, so the queue resumes from that song, not from the prepared one.
    public var queueAnchorIndex: Int
    // What the reducer expects at the next natural boundary. Diagnostics and tests read it.
    public var nextSongOutlook: NextSongOutlook
    public var collectionReach: CollectionReachState

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
        autoTargetState = .initial
        rhythmControl = .initial
        appliedPlaybackRate = 1
        pendingRateRequestID = nil
        pendingCommandedRate = nil
        incompatibleTrackSeconds = 0
        pendingTrackSelectionID = nil
        pendingNextTrackID = nil
        preparedNextTrackID = nil
        autoFeedback = .initial
        lastTrackChangeReason = nil
        queueAnchorIndex = 0
        nextSongOutlook = .notYetKnown
        collectionReach = .initial
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
    case pinned(surface: RunControlSurface)

    public var surface: RunControlSurface? {
        switch self {
        case .hidden:
            nil
        case let .timed(surface, _), let .pinned(surface):
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

    // The reducer's hold window and the visible fill share this one duration.
    public static let durationSeconds = 0.9
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

// The reducer looks at the queued next song before the current one ends, so a natural boundary
// lands on a song the body can follow. Skip and Previous stay the runner's and carry no plan.
public enum NextSongOutlook: String, Sendable, Equatable, Codable {
    // Outside the look-ahead window, or no settled Auto target to judge against yet.
    case notYetKnown
    case queuedSongFits
    case betterFitPrepared
    // Nothing in the ready collection reaches the settled target, so the queue proceeds as it is.
    case nothingFits
}

// Most of the ready collection cannot reach the settled Auto target inside the rate window, and
// which way it misses. Said once per run per direction, in human words, never per second.
public enum CollectionReach: String, Sendable, Equatable, Codable {
    case mostlyFaster
    case mostlySlower
}

public struct CollectionReachState: Sendable, Equatable {
    public var condition: CollectionReach?
    public var heldSeconds: Double
    public var noticed: [CollectionReach]

    public init(condition: CollectionReach? = nil, heldSeconds: Double = 0, noticed: [CollectionReach] = []) {
        self.condition = condition
        self.heldSeconds = heldSeconds
        self.noticed = noticed
    }

    public static let initial = CollectionReachState()
}

public enum TrackChangeReason: String, Sendable, Equatable, Codable {
    case explicitPrevious
    case explicitSkip
    case naturalBoundary
    // The player moved to another entry with no Samadhi command and not near the end of the song.
    // Control Center, the Music app, or a headphone button are the usual causes.
    case externalUnknown
    case recovery
}

// One meaningful Auto adjustment is one identified transaction: committed target, verified start,
// verified arrival. The reducer owns identity and the exactly-once triggers; the app shell only plays.
public enum AutoFeedbackDirection: String, Sendable, Equatable, Codable {
    case faster
    case slower
}

public enum AutoFeedbackSize: String, Sendable, Equatable, Codable {
    case small
    case medium
    case large

    // Bands are prototype starting points in reachable step rhythm; physical testing may move them.
    public static let smallRangeSPM = 6.0...9.0
    public static let mediumRangeSPM = 10.0...15.0
    public static let largeMinimumSPM = 16.0

    public static func band(forChangeSPM change: Double) -> AutoFeedbackSize? {
        let rounded = abs(change).rounded()
        if rounded >= largeMinimumSPM { return .large }
        if rounded >= mediumRangeSPM.lowerBound { return .medium }
        if rounded >= smallRangeSPM.lowerBound { return .small }
        return nil
    }
}

public enum AutoFeedbackMoment: String, Sendable, Equatable, Codable {
    case began
    case arrived
}

public enum AutoFeedbackPhase: String, Sendable, Equatable, Codable {
    case committed
    case began
    case arrived
}

public struct AutoFeedbackCue: Sendable, Equatable {
    public let transactionID: Int
    public let moment: AutoFeedbackMoment
    public let direction: AutoFeedbackDirection
    public let size: AutoFeedbackSize
    public let isLimited: Bool

    public init(
        transactionID: Int,
        moment: AutoFeedbackMoment,
        direction: AutoFeedbackDirection,
        size: AutoFeedbackSize,
        isLimited: Bool
    ) {
        self.transactionID = transactionID
        self.moment = moment
        self.direction = direction
        self.size = size
        self.isLimited = isLimited
    }
}

public struct AutoFeedbackTransaction: Sendable, Equatable {
    public let id: Int
    public let trackID: MusicTrackID
    public let settledTargetSPM: Double
    public let direction: AutoFeedbackDirection
    public let size: AutoFeedbackSize
    public let originRate: Double
    public let targetRate: Double
    public let changeSPM: Double
    public let isLimited: Bool
    public var phase: AutoFeedbackPhase

    public init(
        id: Int,
        trackID: MusicTrackID,
        settledTargetSPM: Double,
        direction: AutoFeedbackDirection,
        size: AutoFeedbackSize,
        originRate: Double,
        targetRate: Double,
        changeSPM: Double,
        isLimited: Bool,
        phase: AutoFeedbackPhase = .committed
    ) {
        self.id = id
        self.trackID = trackID
        self.settledTargetSPM = settledTargetSPM
        self.direction = direction
        self.size = size
        self.originRate = originRate
        self.targetRate = targetRate
        self.changeSPM = changeSPM
        self.isLimited = isLimited
        self.phase = phase
    }
}

public struct AutoFeedbackState: Sendable, Equatable {
    public var transaction: AutoFeedbackTransaction?
    // The settled target that last opened a transaction. A reaffirmed target opens nothing.
    public var lastSettledTargetSPM: Double?
    public var nextTransactionID: Int

    public init(
        transaction: AutoFeedbackTransaction? = nil,
        lastSettledTargetSPM: Double? = nil,
        nextTransactionID: Int = 1
    ) {
        self.transaction = transaction
        self.lastSettledTargetSPM = lastSettledTargetSPM
        self.nextTransactionID = nextTransactionID
    }

    public static let initial = AutoFeedbackState()
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
    // Previous or Next was requested. The song change itself is confirmed later by the player.
    case transportRequest
    // Finish changed into its hold control. The run has not ended.
    case finishArmed
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
    case reachNotice
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
    case emitAutoFeedback(AutoFeedbackCue)
    case cancelAutoFeedback(transactionID: Int)
    // One quiet line on the run screen. The reducer allows it once per run per direction.
    case showReachNotice(CollectionReach)
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
    case rhythmControlDismissed(timeoutID: Int)
    case rhythmControlAdjusted(steps: Int, rateRequestID: Int, timeoutID: Int)
    case rhythmControlTargetCommitted(bpm: Int, rateRequestID: Int, timeoutID: Int)
    case rhythmControlSetManual(rateRequestID: Int, timeoutID: Int)
    case rhythmControlReset(rateRequestID: Int, timeoutID: Int)
    case controlsTimedOut(timeoutID: Int)
    case controlsInteractionBegan
    case controlsInteractionEnded(timeoutID: Int)
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
    // Progress carries a selection identifier because the boundary look-ahead may prepare a next
    // song from it; the player orders prepare and clear commands by that identifier.
    case playbackProgress(
        sessionID: Int,
        operationID: Int,
        trackIndex: Int,
        elapsedSeconds: Int,
        durationSeconds: Int,
        selectionID: Int
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
        reason: TrackChangeReason,
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
