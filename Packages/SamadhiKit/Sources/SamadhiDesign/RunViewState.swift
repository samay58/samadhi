import SamadhiDomain

public struct TrackMetadata: Sendable, Equatable {
    public let title: String
    public let artist: String
    public let collection: String
    public let durationSeconds: Int

    public init(title: String, artist: String, collection: String = "Night Motion", durationSeconds: Int = 214) {
        self.title = title
        self.artist = artist
        self.collection = collection
        self.durationSeconds = durationSeconds
    }

    public static let demoTracks = [
        TrackMetadata(title: "Dawn on Valencia", artist: "Saffron District", durationSeconds: 214),
        TrackMetadata(title: "Afterimage", artist: "Static Gardens", durationSeconds: 187),
        TrackMetadata(title: "Soft Current", artist: "North Window", durationSeconds: 231),
    ]
}

public enum RunVisualPhase: Sendable, Equatable {
    case ready
    case preparing
    case acquiring
    case running
    case paused
    case confirmingFinish
    case finishing
    case permissionRecovery
    case routeRecovery(restored: Bool)
    case summary(RunSummary)
}

public enum MusicTrackImportPresentation: Sendable, Equatable {
    case pending
    case ready
    case rhythmUnclear
    case previewUnavailable
    case catalogMatchUnavailable
    case temporaryFailure
}

public struct ImportedTrackPresentation: Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let status: MusicTrackImportPresentation

    public init(id: String, title: String, status: MusicTrackImportPresentation) {
        self.id = id
        self.title = title
        self.status = status
    }
}

public struct ImportedCollectionPresentation: Sendable, Equatable {
    public let name: String
    public let totalTrackCount: Int
    public let readyTrackCount: Int
    public let completedTrackCount: Int
    public let tracks: [ImportedTrackPresentation]

    public var hasTemporaryFailures: Bool {
        tracks.contains { $0.status == .temporaryFailure }
    }

    public init(
        name: String,
        totalTrackCount: Int,
        readyTrackCount: Int,
        completedTrackCount: Int,
        tracks: [ImportedTrackPresentation]
    ) {
        self.name = name
        self.totalTrackCount = totalTrackCount
        self.readyTrackCount = readyTrackCount
        self.completedTrackCount = completedTrackCount
        self.tracks = tracks
    }
}

public enum MusicSelectionPresentation: Sendable, Equatable {
    case none
    case loadingPlaylists
    case analyzing(ImportedCollectionPresentation)
    case ready(ImportedCollectionPresentation)
    case failed(String)
}

public struct RhythmControlPresentation: Sendable, Equatable {
    public var mode: RhythmControlMode
    public var automaticCorrectionBPM: Int
    public var manualTargetBPM: Int
    public var requestedBPM: Int?
    public var appliedBPM: Int?
    public var commandStatus: TempoCommandStatus
    public var achievableBPM: Int?
    public var commandedRate: Double?
    public var appliedRate: Double?
    public var commandLatencySeconds: Double?
    public var isAtLimit: Bool
    public var isFindingBetterFit: Bool
    public var isVisible: Bool
    public var isAvailable: Bool

    public init(
        mode: RhythmControlMode = .automatic,
        automaticCorrectionBPM: Int = 0,
        manualTargetBPM: Int = 168,
        requestedBPM: Int? = nil,
        appliedBPM: Int? = nil,
        commandStatus: TempoCommandStatus = .idle,
        achievableBPM: Int? = nil,
        commandedRate: Double? = nil,
        appliedRate: Double? = nil,
        commandLatencySeconds: Double? = nil,
        isAtLimit: Bool = false,
        isFindingBetterFit: Bool = false,
        isVisible: Bool = false,
        isAvailable: Bool = true
    ) {
        self.mode = mode
        self.automaticCorrectionBPM = automaticCorrectionBPM
        self.manualTargetBPM = manualTargetBPM
        self.requestedBPM = requestedBPM
        self.appliedBPM = appliedBPM
        self.commandStatus = commandStatus
        self.achievableBPM = achievableBPM
        self.commandedRate = commandedRate
        self.appliedRate = appliedRate
        self.commandLatencySeconds = commandLatencySeconds
        self.isAtLimit = isAtLimit
        self.isFindingBetterFit = isFindingBetterFit
        self.isVisible = isVisible
        self.isAvailable = isAvailable
    }
}

public struct RunViewState: Sendable, Equatable {
    public var phase: RunVisualPhase
    public var controlsVisible: Bool
    public var cadenceSPM: Int?
    public var trackElapsedSeconds: Int
    public var trackProgress: Double
    public var track: TrackMetadata
    public var hasArtwork: Bool
    public var showLockBrief: Bool
    public var forceReduceMotion: Bool
    public var forceIncreasedContrast: Bool
    public var musicSelection: MusicSelectionPresentation
    public var rhythmControl: RhythmControlPresentation

    public init(
        phase: RunVisualPhase,
        controlsVisible: Bool = false,
        cadenceSPM: Int? = nil,
        trackElapsedSeconds: Int = 0,
        trackProgress: Double = 0,
        track: TrackMetadata = .demoTracks[0],
        hasArtwork: Bool = true,
        showLockBrief: Bool = false,
        forceReduceMotion: Bool = false,
        forceIncreasedContrast: Bool = false,
        rhythmControl: RhythmControlPresentation = RhythmControlPresentation(),
        musicSelection: MusicSelectionPresentation = .ready(
            ImportedCollectionPresentation(
                name: "Night Motion",
                totalTrackCount: 3,
                readyTrackCount: 3,
                completedTrackCount: 3,
                tracks: []
            )
        )
    ) {
        self.phase = phase
        self.controlsVisible = controlsVisible
        self.cadenceSPM = cadenceSPM
        self.trackElapsedSeconds = trackElapsedSeconds
        self.trackProgress = min(max(trackProgress, 0), 1)
        self.track = track
        self.hasArtwork = hasArtwork
        self.showLockBrief = showLockBrief
        self.forceReduceMotion = forceReduceMotion
        self.forceIncreasedContrast = forceIncreasedContrast
        self.rhythmControl = rhythmControl
        self.musicSelection = musicSelection
    }
}

public enum RunAction: Sendable, Equatable {
    case start
    case revealControls
    case revealRhythmControl
    case adjustRhythmControl(Int)
    case previewRhythmStep(direction: RhythmAdjustmentDirection, isMajor: Bool)
    case commitRhythmTarget(Int)
    case useManualRhythm
    case resetRhythmControl
    case controlsInteractionChanged(Bool)
    case previous
    case pause
    case resume
    case skip
    case finishTapped
    case finishHoldBegan
    case finishHoldCancelled
    case finishHoldCompleted
    case useFixedRhythm
    case openSettings
    case routeResume
    case done
    case chooseMusic
    case changeMusic
    case retryMusicImport
}
