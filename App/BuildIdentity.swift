import Darwin
import Foundation
import SamadhiAudio

struct BuildIdentity: Codable, Equatable, Sendable {
    let gitCommit: String
    let gitBranch: String
    let trackedFilesDirty: Bool
    let buildDate: String
    let sourceFingerprint: String
    let appVersion: String
    let buildNumber: String
    let tempoAnalyzerVersion: Int
    let diagnosticFileVersion: Int

    static var current: BuildIdentity {
        from(bundle: .main)
    }

    static func from(bundle: Bundle) -> BuildIdentity {
        let info = bundle.infoDictionary ?? [:]
        return BuildIdentity(
            gitCommit: info["SamadhiGitCommit"] as? String ?? "unknown",
            gitBranch: info["SamadhiGitBranch"] as? String ?? "unknown",
            trackedFilesDirty: info["SamadhiTrackedFilesDirty"] as? Bool ?? false,
            buildDate: info["SamadhiBuildDate"] as? String ?? "unknown",
            sourceFingerprint: info["SamadhiSourceFingerprint"] as? String ?? "unknown",
            appVersion: info["CFBundleShortVersionString"] as? String ?? "unknown",
            buildNumber: info["CFBundleVersion"] as? String ?? "unknown",
            tempoAnalyzerVersion: LocalTempoAnalyzer.analysisVersion,
            diagnosticFileVersion: RunDiagnosticSnapshot.currentSchemaVersion
        )
    }
}

struct DiagnosticEnvironment: Codable, Equatable, Sendable {
    let deviceModel: String
    let operatingSystem: String
    let musicService: String
    let motionService: String
    let launchArguments: [String]

    static var current: DiagnosticEnvironment {
        let arguments = sanitizedLaunchArguments(
            Array(ProcessInfo.processInfo.arguments.dropFirst())
        )
        #if targetEnvironment(simulator)
            let usesRealMusic =
                arguments.contains("--real-apple-music")
                || arguments.contains("--apple-music-core-loop")
            let deviceModel =
                ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]
                ?? "iOS Simulator"
            let musicService = usesRealMusic ? "real Apple Music" : "simulated music"
            let motionService = "simulated motion"
        #else
            let deviceModel = Self.hardwareModel()
            let musicService = "real Apple Music"
            let motionService = "real phone motion"
        #endif

        return DiagnosticEnvironment(
            deviceModel: deviceModel,
            operatingSystem: ProcessInfo.processInfo.operatingSystemVersionString,
            musicService: musicService,
            motionService: motionService,
            launchArguments: arguments
        )
    }

    static func sanitizedLaunchArguments(_ arguments: [String]) -> [String] {
        let privateWords = ["token", "secret", "password", "credential", "api-key", "apikey"]
        var hidesNextValue = false
        return arguments.map { argument in
            if hidesNextValue {
                hidesNextValue = false
                return "<redacted>"
            }
            let lowercased = argument.lowercased()
            guard privateWords.contains(where: lowercased.contains) else { return argument }
            if let equalsIndex = argument.firstIndex(of: "=") {
                return String(argument[...equalsIndex]) + "<redacted>"
            }
            hidesNextValue = true
            return argument
        }
    }

    private static func hardwareModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }
}
