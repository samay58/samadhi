import Foundation

enum MusicSelectionFixture: Equatable {
    case standard
    case none
    case loading
    case loadingSelected
    case analyzing
    case partial
    case authorizationFailure
    case importFailure
    case emptyLibrary
    case twoPlaylistLibrary
    case largeLibrary
    case longPlaylistName
    case readingLibrary
}

// A scripted Auto adjustment for Simulator proof. The simulated cadence settles, then moves by the
// named band and direction so the reducer opens exactly one feedback transaction.
enum AutoFeedbackScenario: String, Equatable {
    case fasterSmall = "faster-small"
    case fasterMedium = "faster-medium"
    case fasterLarge = "faster-large"
    case slowerSmall = "slower-small"
    case slowerMedium = "slower-medium"
    case slowerLarge = "slower-large"

    // The simulated demo songs are analyzed at 168 BPM, so a 168 SPM base starts the run at normal
    // speed and every band below stays inside the proven 0.85 through 1.15 envelope.
    static let baseCadenceSPM = 168

    // Raw cadence offsets, not the resulting band. The shell's cadence filter stops inside its two
    // SPM deadband, so these raw moves settle at about 7, 13, and 19 SPM of reachable change.
    var cadenceOffsetSPM: Int {
        switch self {
        case .fasterSmall: 8
        case .fasterMedium: 14
        case .fasterLarge: 20
        case .slowerSmall: -8
        case .slowerMedium: -14
        case .slowerLarge: -20
        }
    }
}

// A scripted walk whose cadence most of the Simulator collection cannot reach, so the reach
// notice can be seen. Faster means the songs are faster than the body; slower the reverse.
enum OutOfReachScenario: String, Equatable {
    case faster
    case slower

    // Against the out-of-reach demo set (126, 132, and 138 BPM), 100 steps per minute sits below
    // every song's floor and 172 above every song's ceiling inside the rate window.
    var cadenceSPM: Int {
        switch self {
        case .faster: 100
        case .slower: 172
        }
    }

    // Walking acquisition, the filter, the twenty held seconds, and a margin.
    static let heldSamples = 60
}

// One scripted playback event per launch, so a UI test can prove one cause at a time.
enum ScriptedPlaybackScenario: String, CaseIterable {
    case routeLoss = "-SAMADHI_ROUTE_LOST"
    case interruption = "-SAMADHI_INTERRUPTION"
    case naturalBoundary = "-SAMADHI_NATURAL_BOUNDARY"
    case externalBoundary = "-SAMADHI_EXTERNAL_BOUNDARY"
    case sameSongCallback = "-SAMADHI_SAME_SONG_CALLBACK"
}

struct SimulationConfiguration {
    // Launch flags make previews and UI tests deterministic. They are not product settings.
    let fastMode: Bool
    let permissionDenied: Bool
    let scriptedPlayback: ScriptedPlaybackScenario?
    let autoFeedbackScenario: AutoFeedbackScenario?
    let outOfReachScenario: OutOfReachScenario?
    let feedbackAudition: Bool
    let missingArtwork: Bool
    let extendedAcquisitionWindow: Bool
    let useAppleMusicCoreLoop: Bool
    let useSimulatorDemoMusic: Bool
    let setupReviewMode: Bool
    let musicSelectionFixture: MusicSelectionFixture

    init(
        fastMode: Bool,
        permissionDenied: Bool,
        scriptedPlayback: ScriptedPlaybackScenario? = nil,
        autoFeedbackScenario: AutoFeedbackScenario? = nil,
        outOfReachScenario: OutOfReachScenario? = nil,
        feedbackAudition: Bool = false,
        missingArtwork: Bool,
        extendedAcquisitionWindow: Bool,
        useAppleMusicCoreLoop: Bool,
        useSimulatorDemoMusic: Bool,
        setupReviewMode: Bool,
        musicSelectionFixture: MusicSelectionFixture
    ) {
        self.fastMode = fastMode
        self.permissionDenied = permissionDenied
        self.scriptedPlayback = scriptedPlayback
        self.autoFeedbackScenario = autoFeedbackScenario
        self.outOfReachScenario = outOfReachScenario
        self.feedbackAudition = feedbackAudition
        self.missingArtwork = missingArtwork
        self.extendedAcquisitionWindow = extendedAcquisitionWindow
        self.useAppleMusicCoreLoop = useAppleMusicCoreLoop
        self.useSimulatorDemoMusic = useSimulatorDemoMusic
        self.setupReviewMode = setupReviewMode
        self.musicSelectionFixture = musicSelectionFixture
    }

    static var current: SimulationConfiguration {
        let arguments = ProcessInfo.processInfo.arguments
        #if DEBUG && targetEnvironment(simulator)
            let useSimulatorDemoMusic =
                !arguments.contains("--real-apple-music")
                && !arguments.contains("--music-feasibility")
                && !arguments.contains("--apple-music-core-loop")
        #else
            let useSimulatorDemoMusic = false
        #endif

        return SimulationConfiguration(
            fastMode: arguments.contains("-SAMADHI_FAST_MODE"),
            permissionDenied: arguments.contains("-SAMADHI_PERMISSION_DENIED"),
            scriptedPlayback: ScriptedPlaybackScenario.allCases.first {
                arguments.contains($0.rawValue)
            },
            autoFeedbackScenario: {
                let prefix = "-SAMADHI_AUTO_FEEDBACK="
                guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else {
                    return nil
                }
                return AutoFeedbackScenario(rawValue: String(argument.dropFirst(prefix.count)))
            }(),
            outOfReachScenario: {
                let prefix = "-SAMADHI_OUT_OF_REACH="
                guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else {
                    return nil
                }
                return OutOfReachScenario(rawValue: String(argument.dropFirst(prefix.count)))
            }(),
            feedbackAudition: {
                #if DEBUG
                    arguments.contains("--feedback-audition")
                #else
                    false
                #endif
            }(),
            missingArtwork: arguments.contains("-SAMADHI_MISSING_ARTWORK"),
            extendedAcquisitionWindow: arguments.contains("-SAMADHI_TEST_ACQUISITION_WINDOW"),
            useAppleMusicCoreLoop: arguments.contains("--apple-music-core-loop"),
            useSimulatorDemoMusic: useSimulatorDemoMusic,
            setupReviewMode: {
                #if DEBUG && targetEnvironment(simulator)
                    arguments.contains("-SAMADHI_SETUP_REVIEW_MODE")
                #else
                    false
                #endif
            }(),
            musicSelectionFixture: {
                if arguments.contains("-SAMADHI_MUSIC_NONE") { return .none }
                if arguments.contains("-SAMADHI_MUSIC_LOADING") { return .loading }
                if arguments.contains("-SAMADHI_MUSIC_LOADING_SELECTED") {
                    return .loadingSelected
                }
                if arguments.contains("-SAMADHI_MUSIC_ANALYZING") { return .analyzing }
                if arguments.contains("-SAMADHI_MUSIC_PARTIAL") { return .partial }
                if arguments.contains("-SAMADHI_MUSIC_AUTHORIZATION_FAILURE") {
                    return .authorizationFailure
                }
                if arguments.contains("-SAMADHI_MUSIC_IMPORT_FAILURE") {
                    return .importFailure
                }
                if arguments.contains("-SAMADHI_MUSIC_LIBRARY_EMPTY") {
                    return .emptyLibrary
                }
                if arguments.contains("-SAMADHI_MUSIC_LIBRARY_TWO") {
                    return .twoPlaylistLibrary
                }
                if arguments.contains("-SAMADHI_MUSIC_LIBRARY_LARGE") {
                    return .largeLibrary
                }
                if arguments.contains("-SAMADHI_MUSIC_LONG_NAME") {
                    return .longPlaylistName
                }
                if arguments.contains("-SAMADHI_MUSIC_LIBRARY_READING") {
                    return .readingLibrary
                }
                return .standard
            }()
        )
    }
}
