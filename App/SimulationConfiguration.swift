import Foundation

enum MusicSelectionFixture {
    case standard
    case none
    case loading
    case analyzing
    case partial
    case authorizationFailure
    case importFailure
}

struct SimulationConfiguration {
    // Launch flags make previews and UI tests deterministic. They are not product settings.
    let fastMode: Bool
    let permissionDenied: Bool
    let simulateRouteLoss: Bool
    let missingArtwork: Bool
    let extendedAcquisitionWindow: Bool
    let useAppleMusicCoreLoop: Bool
    let useSimulatorDemoMusic: Bool
    let musicSelectionFixture: MusicSelectionFixture

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
            simulateRouteLoss: arguments.contains("-SAMADHI_ROUTE_LOST"),
            missingArtwork: arguments.contains("-SAMADHI_MISSING_ARTWORK"),
            extendedAcquisitionWindow: arguments.contains("-SAMADHI_TEST_ACQUISITION_WINDOW"),
            useAppleMusicCoreLoop: arguments.contains("--apple-music-core-loop"),
            useSimulatorDemoMusic: useSimulatorDemoMusic,
            musicSelectionFixture: {
                if arguments.contains("-SAMADHI_MUSIC_NONE") { return .none }
                if arguments.contains("-SAMADHI_MUSIC_LOADING") { return .loading }
                if arguments.contains("-SAMADHI_MUSIC_ANALYZING") { return .analyzing }
                if arguments.contains("-SAMADHI_MUSIC_PARTIAL") { return .partial }
                if arguments.contains("-SAMADHI_MUSIC_AUTHORIZATION_FAILURE") {
                    return .authorizationFailure
                }
                if arguments.contains("-SAMADHI_MUSIC_IMPORT_FAILURE") {
                    return .importFailure
                }
                return .standard
            }()
        )
    }
}
