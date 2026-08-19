import AVFoundation
import CoreHaptics
import Foundation
import SamadhiDomain

// Working labels for the three prototype cue families. None of them is approved product material.
enum AutoFeedbackFamily: String, CaseIterable, Sendable {
    case pulse
    case swell
    case step

    var displayName: String {
        switch self {
        case .pulse: "Pulse"
        case .swell: "Swell"
        case .step: "Step"
        }
    }
}

// Two ways to carry the arrival sound. The physical comparison picks one.
enum AutoFeedbackSoundPath: String, CaseIterable, Sendable {
    case coreHaptics
    case avAudioPlayer

    var displayName: String {
        switch self {
        case .coreHaptics: "Core Haptics audio"
        case .avAudioPlayer: "Local audio player"
        }
    }
}

// Pure name and URL resolution so a test can enumerate the packaged prototype set without a device.
struct AutoFeedbackAssetCatalog: Sendable {
    static let directoryName = "AutoFeedback"
    static let patternExtension = "ahap"
    static let soundExtension = "wav"

    let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    static func startPatternName(direction: AutoFeedbackDirection, size: AutoFeedbackSize) -> String {
        "\(direction.rawValue)-\(size.rawValue)"
    }

    static func arrivalName(direction: AutoFeedbackDirection) -> String {
        "arrival-\(direction.rawValue)"
    }

    // The span each start pattern occupies. The service uses it to keep an arrival off the start.
    static func startPatternSeconds(
        family: AutoFeedbackFamily,
        direction: AutoFeedbackDirection
    ) -> TimeInterval {
        switch (family, direction) {
        case (.pulse, .faster): 0.16
        case (.pulse, .slower): 0.21
        case (.swell, .faster): 0.2
        case (.swell, .slower): 0.24
        case (.step, .faster): 0.175
        case (.step, .slower): 0.225
        }
    }

    static var everyPatternRelativePath: [String] {
        var paths: [String] = []
        for family in AutoFeedbackFamily.allCases {
            for direction in [AutoFeedbackDirection.faster, .slower] {
                for size in [AutoFeedbackSize.small, .medium, .large] {
                    paths.append(
                        "\(family.rawValue)/\(startPatternName(direction: direction, size: size)).\(patternExtension)"
                    )
                }
                paths.append("\(family.rawValue)/\(arrivalName(direction: direction)).\(patternExtension)")
            }
        }
        return paths
    }

    static var everySoundRelativePath: [String] {
        AutoFeedbackFamily.allCases.flatMap { family in
            [AutoFeedbackDirection.faster, .slower].map { direction in
                "\(family.rawValue)/\(arrivalName(direction: direction)).\(soundExtension)"
            }
        }
    }

    func startPatternURL(
        family: AutoFeedbackFamily,
        direction: AutoFeedbackDirection,
        size: AutoFeedbackSize
    ) -> URL? {
        url(
            family: family,
            name: Self.startPatternName(direction: direction, size: size),
            extension: Self.patternExtension
        )
    }

    func arrivalPatternURL(family: AutoFeedbackFamily, direction: AutoFeedbackDirection) -> URL? {
        url(family: family, name: Self.arrivalName(direction: direction), extension: Self.patternExtension)
    }

    func arrivalSoundURL(family: AutoFeedbackFamily, direction: AutoFeedbackDirection) -> URL? {
        url(family: family, name: Self.arrivalName(direction: direction), extension: Self.soundExtension)
    }

    var everyArrivalSoundURL: [URL] {
        AutoFeedbackFamily.allCases.flatMap { family in
            [AutoFeedbackDirection.faster, .slower].compactMap { direction in
                arrivalSoundURL(family: family, direction: direction)
            }
        }
    }

    var packagedDirectoryURL: URL? {
        bundle.resourceURL?.appendingPathComponent(Self.directoryName, isDirectory: true)
    }

    private func url(family: AutoFeedbackFamily, name: String, extension fileExtension: String) -> URL? {
        bundle.url(
            forResource: name,
            withExtension: fileExtension,
            subdirectory: "\(Self.directoryName)/\(family.rawValue)"
        )
    }
}

struct AutoFeedbackPlaybackRequest: Equatable, Sendable {
    let transactionID: Int
    let moment: AutoFeedbackMoment
    let family: AutoFeedbackFamily
    let direction: AutoFeedbackDirection
    let size: AutoFeedbackSize
    let soundPath: AutoFeedbackSoundPath
    let patternURL: URL?
    let soundURL: URL?
}

@MainActor
protocol AutoFeedbackCuePlaying: AnyObject {
    // Throws when the engine refuses to start the pattern, so the delivery record can say so.
    func play() throws
    func stop()
}

// A built cue and how it was built. No player means nothing could carry the cue; the outcome and
// detail say why.
struct AutoFeedbackCueBuild {
    let player: (any AutoFeedbackCuePlaying)?
    let outcome: AutoFeedbackDeliveryOutcome
    let detail: String?
}

// The seam that lets tests drive the service without haptic hardware or an audio route.
@MainActor
protocol AutoFeedbackCuePlayerMaking: AnyObject {
    func makePlayer(for request: AutoFeedbackPlaybackRequest) -> AutoFeedbackCueBuild
    var onEngineEvent: ((AutoFeedbackEngineEvent) -> Void)? { get set }
}

@MainActor
final class AutoFeedbackService: AutoFeedbackPlaying {
    // An arrival that lands inside this window of its own start is held until the start pattern ends.
    static let arrivalHoldWindowSeconds: TimeInterval = 0.35
    static let arrivalGapSeconds: TimeInterval = 0.06

    var family: AutoFeedbackFamily = .pulse
    var soundPath: AutoFeedbackSoundPath = .coreHaptics
    var soundEnabled = true
    var hapticsEnabled = true

    let catalog: AutoFeedbackAssetCatalog

    var onDelivery: ((AutoFeedbackDeliveryRecord) -> Void)?
    var onEngineEvent: ((AutoFeedbackEngineEvent) -> Void)? {
        didSet { playerFactory.onEngineEvent = onEngineEvent }
    }

    private let playerFactory: any AutoFeedbackCuePlayerMaking
    private let now: () -> TimeInterval
    private var playedMoments: Set<PlayedMoment> = []
    private var beganTimes: [Int: TimeInterval] = [:]
    private var activePlayers: [Int: [any AutoFeedbackCuePlaying]] = [:]
    private var pendingArrivals: [Int: PendingArrival] = [:]

    init(
        catalog: AutoFeedbackAssetCatalog = AutoFeedbackAssetCatalog(),
        playerFactory: (any AutoFeedbackCuePlayerMaking)? = nil,
        now: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }
    ) {
        self.catalog = catalog
        self.playerFactory = playerFactory ?? CoreHapticsAutoFeedbackPlayerFactory(catalog: catalog)
        self.now = now
    }

    var pendingArrivalCount: Int { pendingArrivals.count }

    func play(_ cue: AutoFeedbackCue) {
        let played = PlayedMoment(transactionID: cue.transactionID, moment: cue.moment)
        guard !playedMoments.contains(played) else { return }
        playedMoments.insert(played)

        switch cue.moment {
        case .began:
            beganTimes[cue.transactionID] = now()
            perform(cue)
        case .arrived:
            let delay = arrivalDelay(for: cue)
            guard delay > 0 else {
                perform(cue)
                return
            }
            pendingArrivals[cue.transactionID]?.task.cancel()
            let task = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled, let self else { return }
                self.pendingArrivals[cue.transactionID] = nil
                self.perform(cue)
            }
            pendingArrivals[cue.transactionID] = PendingArrival(cue: cue, task: task)
        }
    }

    func cancel(transactionID: Int) {
        if let pending = pendingArrivals.removeValue(forKey: transactionID) {
            pending.task.cancel()
            report(pending.cue, outcome: .cancelledBeforePlay, detail: "arrival was still held")
        }
        activePlayers.removeValue(forKey: transactionID)?.forEach { $0.stop() }
        beganTimes.removeValue(forKey: transactionID)
        // The played record stays so a late duplicate cannot revive a cancelled transaction.
    }

    func cancelAll() {
        for pending in pendingArrivals.values {
            pending.task.cancel()
            report(pending.cue, outcome: .cancelledBeforePlay, detail: "run ended or recovered")
        }
        pendingArrivals.removeAll()
        for players in activePlayers.values {
            for player in players { player.stop() }
        }
        activePlayers.removeAll()
        beganTimes.removeAll()
        // A later run numbers its transactions from one again, so the played record must not survive.
        playedMoments.removeAll()
    }

    func playbackRequest(for cue: AutoFeedbackCue) -> AutoFeedbackPlaybackRequest {
        let patternURL: URL? =
            hapticsEnabled
            ? (cue.moment == .began
                ? catalog.startPatternURL(family: family, direction: cue.direction, size: cue.size)
                : catalog.arrivalPatternURL(family: family, direction: cue.direction))
            : nil
        let soundURL: URL? =
            soundEnabled && cue.moment == .arrived
            ? catalog.arrivalSoundURL(family: family, direction: cue.direction)
            : nil
        return AutoFeedbackPlaybackRequest(
            transactionID: cue.transactionID,
            moment: cue.moment,
            family: family,
            direction: cue.direction,
            size: cue.size,
            soundPath: soundPath,
            patternURL: patternURL,
            soundURL: soundURL
        )
    }

    private func arrivalDelay(for cue: AutoFeedbackCue) -> TimeInterval {
        guard let began = beganTimes[cue.transactionID] else { return 0 }
        let elapsed = now() - began
        guard elapsed < Self.arrivalHoldWindowSeconds else { return 0 }
        let span = AutoFeedbackAssetCatalog.startPatternSeconds(family: family, direction: cue.direction)
        return max(0, span + Self.arrivalGapSeconds - elapsed)
    }

    private func perform(_ cue: AutoFeedbackCue) {
        let request = playbackRequest(for: cue)
        guard request.patternURL != nil || request.soundURL != nil else {
            report(cue, outcome: .patternMissing, detail: "sound and haptics both disabled")
            return
        }
        let build = playerFactory.makePlayer(for: request)
        guard let player = build.player else {
            report(cue, outcome: build.outcome, detail: build.detail)
            return
        }
        activePlayers[cue.transactionID, default: []].append(player)
        do {
            try player.play()
            report(cue, outcome: build.outcome, detail: build.detail)
        } catch {
            report(cue, outcome: .engineUnavailable, detail: "start failed: \(error.localizedDescription)")
        }
    }

    private func report(_ cue: AutoFeedbackCue, outcome: AutoFeedbackDeliveryOutcome, detail: String?) {
        onDelivery?(
            AutoFeedbackDeliveryRecord(
                transactionID: cue.transactionID,
                moment: cue.moment,
                family: family,
                soundPath: soundPath,
                outcome: outcome,
                detail: detail
            )
        )
    }

    private struct PlayedMoment: Hashable {
        let transactionID: Int
        let moment: AutoFeedbackMoment
    }

    private struct PendingArrival {
        let cue: AutoFeedbackCue
        let task: Task<Void, Never>
    }
}

// Owns the one engine, its registered audio resources, and the preloaded local players.
// Samadhi never configures AVAudioSession, so no ducking or category option is set anywhere here.
@MainActor
final class CoreHapticsAutoFeedbackPlayerFactory: AutoFeedbackCuePlayerMaking {
    private let catalog: AutoFeedbackAssetCatalog
    private var engine: CHHapticEngine?
    private var engineIsRunning = false
    private var lastEngineFailure: String?
    private var audioResourceIDs: [URL: CHHapticAudioResourceID] = [:]
    private var filePlayers: [URL: AVAudioPlayer] = [:]

    var onEngineEvent: ((AutoFeedbackEngineEvent) -> Void)?

    init(catalog: AutoFeedbackAssetCatalog) {
        self.catalog = catalog
    }

    func makePlayer(for request: AutoFeedbackPlaybackRequest) -> AutoFeedbackCueBuild {
        let engine = preparedEngine()
        var enginePlayers: [any CHHapticPatternPlayer] = []
        var filePlayer: AVAudioPlayer?
        var patternProblem: String?

        if let patternURL = request.patternURL, let engine {
            do {
                let pattern = try CHHapticPattern(contentsOf: patternURL)
                enginePlayers.append(try engine.makePlayer(with: pattern))
            } catch {
                patternProblem = "\(patternURL.lastPathComponent): \(error.localizedDescription)"
            }
        }

        if let soundURL = request.soundURL {
            // Without haptic hardware the engine is absent, so the sound falls back to the local player.
            if request.soundPath == .coreHaptics, let engine,
                let player = audioEventPlayer(for: soundURL, engine: engine)
            {
                enginePlayers.append(player)
            } else {
                filePlayer = preparedFilePlayer(for: soundURL)
            }
        }

        if !enginePlayers.isEmpty {
            return AutoFeedbackCueBuild(
                player: CoreHapticsCuePlayer(enginePlayers: enginePlayers, filePlayer: filePlayer),
                outcome: .playedThroughEngine,
                detail: filePlayer == nil ? patternProblem : "sound through the local player"
            )
        }
        if let filePlayer {
            return AutoFeedbackCueBuild(
                player: CoreHapticsCuePlayer(enginePlayers: [], filePlayer: filePlayer),
                outcome: .playedLocalSoundOnly,
                detail: engine == nil ? engineAbsenceDetail : patternProblem
            )
        }
        if let patternProblem {
            return AutoFeedbackCueBuild(player: nil, outcome: .patternMissing, detail: patternProblem)
        }
        return AutoFeedbackCueBuild(
            player: nil,
            outcome: engine == nil ? .engineUnavailable : .patternMissing,
            detail: engine == nil ? engineAbsenceDetail : "no pattern or sound resolved"
        )
    }

    private var engineAbsenceDetail: String {
        if !CHHapticEngine.capabilitiesForHardware().supportsHaptics { return "no haptic hardware" }
        return lastEngineFailure ?? "engine not running"
    }

    private func preparedEngine() -> CHHapticEngine? {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            if lastEngineFailure == nil {
                lastEngineFailure = "no haptic hardware"
                onEngineEvent?(.unsupported)
            }
            return nil
        }
        if let engine {
            if !engineIsRunning {
                do {
                    try engine.start()
                    engineIsRunning = true
                    lastEngineFailure = nil
                    onEngineEvent?(.started)
                } catch {
                    lastEngineFailure = "start failed: \(error.localizedDescription)"
                    onEngineEvent?(.startFailed(error.localizedDescription))
                }
            }
            return engineIsRunning ? engine : nil
        }
        do {
            let created = try CHHapticEngine()
            created.playsHapticsOnly = false
            created.isAutoShutdownEnabled = false
            onEngineEvent?(.created)
            created.stoppedHandler = { [weak self] reason in
                Task { @MainActor in
                    self?.engineIsRunning = false
                    let name = Self.stopReasonName(reason)
                    self?.lastEngineFailure = "stopped: \(name)"
                    self?.onEngineEvent?(.stopped(reason: name))
                }
            }
            created.resetHandler = { [weak self] in
                Task { @MainActor in self?.recoverFromReset() }
            }
            try created.start()
            engine = created
            engineIsRunning = true
            lastEngineFailure = nil
            onEngineEvent?(.started)
            return created
        } catch {
            engine = nil
            engineIsRunning = false
            lastEngineFailure = "start failed: \(error.localizedDescription)"
            onEngineEvent?(.startFailed(error.localizedDescription))
            return nil
        }
    }

    // A reset invalidates registered audio resources and every cached player, so both are rebuilt.
    private func recoverFromReset() {
        audioResourceIDs.removeAll()
        filePlayers.removeAll()
        engineIsRunning = false
        onEngineEvent?(.reset)
        guard let engine else { return }
        do {
            try engine.start()
            engineIsRunning = true
            lastEngineFailure = nil
            onEngineEvent?(.started)
        } catch {
            lastEngineFailure = "start failed after reset: \(error.localizedDescription)"
            onEngineEvent?(.startFailed(error.localizedDescription))
            return
        }
        for url in catalog.everyArrivalSoundURL {
            _ = audioResourceID(for: url, engine: engine)
        }
    }

    private static func stopReasonName(_ reason: CHHapticEngine.StoppedReason) -> String {
        switch reason {
        case .audioSessionInterrupt: "audio session interrupt"
        case .applicationSuspended: "application suspended"
        case .idleTimeout: "idle timeout"
        case .notifyWhenFinished: "finished"
        case .engineDestroyed: "engine destroyed"
        case .gameControllerDisconnect: "game controller disconnected"
        case .systemError: "system error"
        @unknown default: "unknown (\(reason.rawValue))"
        }
    }

    private func audioResourceID(for url: URL, engine: CHHapticEngine) -> CHHapticAudioResourceID? {
        if let existing = audioResourceIDs[url] { return existing }
        guard let identifier = try? engine.registerAudioResource(url, options: [:]) else { return nil }
        audioResourceIDs[url] = identifier
        return identifier
    }

    private func audioEventPlayer(for url: URL, engine: CHHapticEngine) -> (any CHHapticPatternPlayer)? {
        guard let resourceID = audioResourceID(for: url, engine: engine) else { return nil }
        let event = CHHapticEvent(
            audioResourceID: resourceID,
            parameters: [CHHapticEventParameter(parameterID: .audioVolume, value: 1)],
            relativeTime: 0
        )
        guard let pattern = try? CHHapticPattern(events: [event], parameters: []),
            let player = try? engine.makePlayer(with: pattern)
        else { return nil }
        return player
    }

    private func preparedFilePlayer(for url: URL) -> AVAudioPlayer? {
        if let existing = filePlayers[url] { return existing }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.prepareToPlay()
        filePlayers[url] = player
        return player
    }
}

@MainActor
private final class CoreHapticsCuePlayer: AutoFeedbackCuePlaying {
    private let enginePlayers: [any CHHapticPatternPlayer]
    private let filePlayer: AVAudioPlayer?

    init(enginePlayers: [any CHHapticPatternPlayer], filePlayer: AVAudioPlayer?) {
        self.enginePlayers = enginePlayers
        self.filePlayer = filePlayer
    }

    func play() throws {
        for player in enginePlayers {
            try player.start(atTime: CHHapticTimeImmediate)
        }
        filePlayer?.currentTime = 0
        filePlayer?.play()
    }

    func stop() {
        for player in enginePlayers {
            try? player.stop(atTime: CHHapticTimeImmediate)
        }
        filePlayer?.stop()
    }
}
