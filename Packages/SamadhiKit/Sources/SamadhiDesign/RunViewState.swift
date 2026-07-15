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

public struct RunViewState: Sendable, Equatable {
    public var phase: RunVisualPhase
    public var controlsVisible: Bool
    public var cadenceSPM: Int?
    public var elapsedSeconds: Int
    public var trackElapsedSeconds: Int
    public var trackProgress: Double
    public var track: TrackMetadata
    public var hasArtwork: Bool
    public var showLockBrief: Bool
    public var fixedRhythm: Bool
    public var forceReduceMotion: Bool
    public var forceIncreasedContrast: Bool

    public init(
        phase: RunVisualPhase,
        controlsVisible: Bool = false,
        cadenceSPM: Int? = nil,
        elapsedSeconds: Int = 0,
        trackElapsedSeconds: Int = 0,
        trackProgress: Double = 0,
        track: TrackMetadata = .demoTracks[0],
        hasArtwork: Bool = true,
        showLockBrief: Bool = false,
        fixedRhythm: Bool = false,
        forceReduceMotion: Bool = false,
        forceIncreasedContrast: Bool = false
    ) {
        self.phase = phase
        self.controlsVisible = controlsVisible
        self.cadenceSPM = cadenceSPM
        self.elapsedSeconds = elapsedSeconds
        self.trackElapsedSeconds = trackElapsedSeconds
        self.trackProgress = min(max(trackProgress, 0), 1)
        self.track = track
        self.hasArtwork = hasArtwork
        self.showLockBrief = showLockBrief
        self.fixedRhythm = fixedRhythm
        self.forceReduceMotion = forceReduceMotion
        self.forceIncreasedContrast = forceIncreasedContrast
    }
}

public enum RunAction: Sendable, Equatable {
    case start
    case revealControls
    case controlsFocusChanged(Bool)
    case previous
    case pause
    case resume
    case skip
    case finishTapped
    case finishHoldBegan
    case finishHoldCancelled
    case finishHoldCompleted
    case cancelFinish
    case useFixedRhythm
    case openSettings
    case routeResume
    case done
}
