import Foundation

struct SimulationConfiguration {
    let fastMode: Bool
    let permissionDenied: Bool
    let simulateRouteLoss: Bool
    let missingArtwork: Bool
    let extendedAcquisitionWindow: Bool

    static var current: SimulationConfiguration {
        let arguments = ProcessInfo.processInfo.arguments
        return SimulationConfiguration(
            fastMode: arguments.contains("-SAMADHI_FAST_MODE"),
            permissionDenied: arguments.contains("-SAMADHI_PERMISSION_DENIED"),
            simulateRouteLoss: arguments.contains("-SAMADHI_ROUTE_LOST"),
            missingArtwork: arguments.contains("-SAMADHI_MISSING_ARTWORK"),
            extendedAcquisitionWindow: arguments.contains("-SAMADHI_TEST_ACQUISITION_WINDOW")
        )
    }
}
