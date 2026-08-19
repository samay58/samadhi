import CoreHaptics
import Foundation
import SamadhiDomain
import Testing

@testable import Samadhi

@Test @MainActor func everyPackagedAutoFeedbackPatternParses() throws {
    let catalog = AutoFeedbackAssetCatalog()
    let directory = try #require(catalog.packagedDirectoryURL)
    let enumerator = try #require(
        FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil)
    )

    var patternURLs: [URL] = []
    for case let url as URL in enumerator where url.pathExtension == AutoFeedbackAssetCatalog.patternExtension {
        patternURLs.append(url)
    }

    #expect(patternURLs.count == AutoFeedbackAssetCatalog.everyPatternRelativePath.count)
    for url in patternURLs {
        let pattern = try CHHapticPattern(contentsOf: url)
        let exported = try pattern.exportDictionary()
        let events = exported[CHHapticPattern.Key.pattern] as? [Any]
        #expect(events?.isEmpty == false, "\(url.lastPathComponent) has no events")
    }
}

@Test @MainActor func autoFeedbackCatalogResolvesEveryPrototypeAsset() {
    let catalog = AutoFeedbackAssetCatalog()
    let directions: [AutoFeedbackDirection] = [.faster, .slower]
    let sizes: [AutoFeedbackSize] = [.small, .medium, .large]

    #expect(AutoFeedbackAssetCatalog.everyPatternRelativePath.count == 24)
    #expect(AutoFeedbackAssetCatalog.everySoundRelativePath.count == 6)

    for family in AutoFeedbackFamily.allCases {
        for direction in directions {
            for size in sizes {
                let url = catalog.startPatternURL(family: family, direction: direction, size: size)
                #expect(url != nil, "missing \(family.rawValue) \(direction.rawValue) \(size.rawValue) pattern")
            }
            #expect(catalog.arrivalPatternURL(family: family, direction: direction) != nil)
            #expect(catalog.arrivalSoundURL(family: family, direction: direction) != nil)
            let span = AutoFeedbackAssetCatalog.startPatternSeconds(family: family, direction: direction)
            #expect(span >= 0.12 && span <= 0.26)
        }
    }
    #expect(catalog.everyArrivalSoundURL.count == 6)
}

@Test @MainActor func packagedArrivalSoundsAreShortMonoFortyEightKilohertzFiles() throws {
    let catalog = AutoFeedbackAssetCatalog()
    for url in catalog.everyArrivalSoundURL {
        let format = try #require(WaveHeader(contentsOf: url), "unreadable header in \(url.lastPathComponent)")
        #expect(format.sampleRate == 48000)
        #expect(format.channels == 1)
        #expect(format.bitsPerSample == 16)
        #expect(format.durationSeconds >= 0.18 && format.durationSeconds <= 0.45)
    }
}

@Test @MainActor func autoFeedbackServicePlaysEachMomentOfATransactionOnce() {
    let factory = RecordingCuePlayerFactory()
    var clock: TimeInterval = 100
    let service = AutoFeedbackService(playerFactory: factory, now: { clock })

    service.play(cue(transactionID: 4, moment: .began))
    service.play(cue(transactionID: 4, moment: .began))
    clock += 1
    service.play(cue(transactionID: 4, moment: .arrived))
    service.play(cue(transactionID: 4, moment: .arrived))

    #expect(factory.requests.count == 2)
    #expect(factory.requests.map(\.moment) == [.began, .arrived])
    #expect(factory.requests[0].patternURL != nil)
    #expect(factory.requests[0].soundURL == nil)
    #expect(factory.requests[1].soundURL != nil)
    #expect(service.pendingArrivalCount == 0)
}

@Test @MainActor func autoFeedbackServiceHoldsAnArrivalThatLandsOnItsOwnStart() {
    let factory = RecordingCuePlayerFactory()
    let clock: TimeInterval = 50
    let service = AutoFeedbackService(playerFactory: factory, now: { clock })

    service.play(cue(transactionID: 7, moment: .began))
    service.play(cue(transactionID: 7, moment: .arrived))

    #expect(factory.requests.count == 1)
    #expect(service.pendingArrivalCount == 1)

    service.cancelAll()

    #expect(service.pendingArrivalCount == 0)
    #expect(factory.requests.count == 1)
    #expect(factory.players.allSatisfy { $0.stopCount == 1 })
}

@Test @MainActor func autoFeedbackServiceCancelStopsOnlyTheNamedTransaction() {
    let factory = RecordingCuePlayerFactory()
    var clock: TimeInterval = 10
    let service = AutoFeedbackService(playerFactory: factory, now: { clock })

    service.play(cue(transactionID: 1, moment: .began))
    clock += 1
    service.play(cue(transactionID: 2, moment: .began))

    service.cancel(transactionID: 1)

    #expect(factory.players.count == 2)
    #expect(factory.players[0].stopCount == 1)
    #expect(factory.players[1].stopCount == 0)
}

private func cue(
    transactionID: Int,
    moment: AutoFeedbackMoment,
    direction: AutoFeedbackDirection = .faster,
    size: AutoFeedbackSize = .medium
) -> AutoFeedbackCue {
    AutoFeedbackCue(
        transactionID: transactionID,
        moment: moment,
        direction: direction,
        size: size,
        isLimited: false
    )
}

@Test @MainActor func autoFeedbackServiceRecordsWhatBecameOfEveryCue() {
    let factory = RecordingCuePlayerFactory()
    var clock: TimeInterval = 10
    let service = AutoFeedbackService(playerFactory: factory, now: { clock })
    var deliveries: [AutoFeedbackDeliveryRecord] = []
    service.onDelivery = { deliveries.append($0) }

    // Played through the engine.
    service.play(cue(transactionID: 1, moment: .began))
    clock += 1
    // The engine is gone; the sound still plays locally.
    factory.nextBuild = .localSoundOnly(detail: "engine not running")
    service.play(cue(transactionID: 1, moment: .arrived))
    // Nothing can carry the cue.
    factory.nextBuild = .failure(.engineUnavailable, detail: "no haptic hardware")
    service.play(cue(transactionID: 2, moment: .began))
    factory.nextBuild = .failure(.patternMissing, detail: "faster-medium.ahap: unreadable")
    service.play(cue(transactionID: 3, moment: .began))
    // The engine accepted the build but refused to start it.
    factory.nextBuild = .engine(detail: nil, failsToPlay: true)
    service.play(cue(transactionID: 4, moment: .began))
    // An arrival held behind its own start, then cancelled before it played.
    factory.nextBuild = .engine(detail: nil, failsToPlay: false)
    service.play(cue(transactionID: 5, moment: .began))
    service.play(cue(transactionID: 5, moment: .arrived))
    service.cancel(transactionID: 5)

    #expect(
        deliveries.map(\.outcome) == [
            .playedThroughEngine,
            .playedLocalSoundOnly,
            .engineUnavailable,
            .patternMissing,
            .engineUnavailable,
            .playedThroughEngine,
            .cancelledBeforePlay,
        ]
    )
    #expect(deliveries.map(\.transactionID) == [1, 1, 2, 3, 4, 5, 5])
    #expect(deliveries.map(\.moment) == [.began, .arrived, .began, .began, .began, .began, .arrived])
    #expect(deliveries[1].detail == "engine not running")
    #expect(deliveries[2].detail == "no haptic hardware")
    #expect(deliveries[4].detail?.hasPrefix("start failed") == true)
    #expect(deliveries.allSatisfy { $0.family == .pulse && $0.soundPath == .coreHaptics })
}

@Test @MainActor func autoFeedbackServiceForwardsEngineEvents() {
    let factory = RecordingCuePlayerFactory()
    let service = AutoFeedbackService(playerFactory: factory, now: { 0 })
    var events: [AutoFeedbackEngineEvent] = []
    service.onEngineEvent = { events.append($0) }

    factory.onEngineEvent?(.created)
    factory.onEngineEvent?(.started)
    factory.onEngineEvent?(.stopped(reason: "application suspended"))
    factory.onEngineEvent?(.reset)

    #expect(events == [.created, .started, .stopped(reason: "application suspended"), .reset])
    #expect(events[2].detail == "application suspended")
    #expect(events.map(\.name) == ["created", "started", "stopped", "reset"])
}

private struct TestPlayFailure: Error {}

private enum ScriptedBuild {
    case engine(detail: String?, failsToPlay: Bool)
    case localSoundOnly(detail: String?)
    case failure(AutoFeedbackDeliveryOutcome, detail: String?)
}

@MainActor
private final class RecordingCuePlayerFactory: AutoFeedbackCuePlayerMaking {
    private(set) var requests: [AutoFeedbackPlaybackRequest] = []
    private(set) var players: [RecordingCuePlayer] = []
    var nextBuild: ScriptedBuild = .engine(detail: nil, failsToPlay: false)
    var onEngineEvent: ((AutoFeedbackEngineEvent) -> Void)?

    func makePlayer(for request: AutoFeedbackPlaybackRequest) -> AutoFeedbackCueBuild {
        requests.append(request)
        switch nextBuild {
        case let .engine(detail, failsToPlay):
            let player = RecordingCuePlayer(failsToPlay: failsToPlay)
            players.append(player)
            return AutoFeedbackCueBuild(player: player, outcome: .playedThroughEngine, detail: detail)
        case let .localSoundOnly(detail):
            let player = RecordingCuePlayer(failsToPlay: false)
            players.append(player)
            return AutoFeedbackCueBuild(player: player, outcome: .playedLocalSoundOnly, detail: detail)
        case let .failure(outcome, detail):
            return AutoFeedbackCueBuild(player: nil, outcome: outcome, detail: detail)
        }
    }
}

@MainActor
private final class RecordingCuePlayer: AutoFeedbackCuePlaying {
    private(set) var playCount = 0
    private(set) var stopCount = 0
    private let failsToPlay: Bool

    init(failsToPlay: Bool = false) {
        self.failsToPlay = failsToPlay
    }

    func play() throws {
        playCount += 1
        if failsToPlay { throw TestPlayFailure() }
    }

    func stop() { stopCount += 1 }
}

private struct WaveHeader {
    let sampleRate: Int
    let channels: Int
    let bitsPerSample: Int
    let durationSeconds: Double

    init?(contentsOf url: URL) {
        guard let data = try? Data(contentsOf: url), data.count > 12 else { return nil }
        guard Self.tag(data, at: 0) == "RIFF", Self.tag(data, at: 8) == "WAVE" else { return nil }

        var offset = 12
        var format: (channels: Int, sampleRate: Int, bits: Int)?
        var dataBytes: Int?
        while offset + 8 <= data.count {
            let identifier = Self.tag(data, at: offset)
            let size = Int(Self.integer(data, at: offset + 4, bytes: 4))
            let body = offset + 8
            if identifier == "fmt ", body + 16 <= data.count {
                format = (
                    channels: Int(Self.integer(data, at: body + 2, bytes: 2)),
                    sampleRate: Int(Self.integer(data, at: body + 4, bytes: 4)),
                    bits: Int(Self.integer(data, at: body + 14, bytes: 2))
                )
            } else if identifier == "data" {
                dataBytes = size
            }
            offset = body + size + (size % 2)
        }

        guard let format, let dataBytes, format.sampleRate > 0, format.channels > 0, format.bits > 0
        else { return nil }
        sampleRate = format.sampleRate
        channels = format.channels
        bitsPerSample = format.bits
        let frameBytes = format.channels * format.bits / 8
        durationSeconds = Double(dataBytes / frameBytes) / Double(format.sampleRate)
    }

    private static func tag(_ data: Data, at offset: Int) -> String {
        guard offset + 4 <= data.count else { return "" }
        return String(decoding: data[data.startIndex + offset..<data.startIndex + offset + 4], as: UTF8.self)
    }

    private static func integer(_ data: Data, at offset: Int, bytes: Int) -> UInt32 {
        var value: UInt32 = 0
        for index in 0..<bytes where offset + index < data.count {
            value |= UInt32(data[data.startIndex + offset + index]) << (8 * index)
        }
        return value
    }
}
