import Foundation
import SamadhiDomain

struct RunDiagnosticSnapshot: Codable, Equatable, Sendable {
    struct Summary: Codable, Equatable, Sendable {
        let durationSeconds: Int
        let averageCadence: Int?
        let tempoMatchedPercent: Int?
        let songCount: Int
    }

    struct Entry: Codable, Equatable, Sendable {
        enum Kind: String, Codable, Sendable {
            case started
            case cadenceUpdated
            case cadenceLost
            case rateApplied
            case playerProgress
            case trackChanged
            case paused
            case resumeRequested
            case routeLost
            case routeRestored
            case interruptionBegan
            case interruptionEnded
            case playbackFailed
            case activeSecond
            case rhythmAdjusted
            case rhythmModeChanged
            case finishRequested
            case finished
        }

        let offsetSeconds: Double
        let kind: Kind
        let activeSeconds: Int
        let cadenceSPM: Double?
        let targetRate: Double?
        let controlMode: String?
        let automaticCorrectionBPM: Int?
        let manualTargetBPM: Int?
        let requestedBPM: Double?
        let derivedTargetRate: Double?
        let atLimit: Bool?
        let appliedRate: Double
        let awaitingRateFeedback: Bool
        let trackID: String?
        let trackTitle: String?
        let trackIndex: Int
        let trackElapsedSeconds: Int
        let trackDurationSeconds: Int?
        let tempoMatched: Bool?

        init(
            offsetSeconds: Double,
            kind: Kind,
            activeSeconds: Int,
            cadenceSPM: Double?,
            targetRate: Double?,
            controlMode: String? = nil,
            automaticCorrectionBPM: Int? = nil,
            manualTargetBPM: Int? = nil,
            requestedBPM: Double? = nil,
            derivedTargetRate: Double? = nil,
            atLimit: Bool = false,
            appliedRate: Double,
            awaitingRateFeedback: Bool,
            trackID: String?,
            trackTitle: String?,
            trackIndex: Int,
            trackElapsedSeconds: Int,
            trackDurationSeconds: Int?,
            tempoMatched: Bool?
        ) {
            self.offsetSeconds = offsetSeconds
            self.kind = kind
            self.activeSeconds = activeSeconds
            self.cadenceSPM = cadenceSPM
            self.targetRate = targetRate
            self.controlMode = controlMode
            self.automaticCorrectionBPM = automaticCorrectionBPM
            self.manualTargetBPM = manualTargetBPM
            self.requestedBPM = requestedBPM
            self.derivedTargetRate = derivedTargetRate
            self.atLimit = atLimit
            self.appliedRate = appliedRate
            self.awaitingRateFeedback = awaitingRateFeedback
            self.trackID = trackID
            self.trackTitle = trackTitle
            self.trackIndex = trackIndex
            self.trackElapsedSeconds = trackElapsedSeconds
            self.trackDurationSeconds = trackDurationSeconds
            self.tempoMatched = tempoMatched
        }
    }

    let schemaVersion: Int
    let capturedAt: Date
    let collectionID: String
    let collectionName: String
    let readyTrackCount: Int
    let summary: Summary
    let timeline: [Entry]
}

actor RunDiagnosticsStore {
    private let directoryURL: URL
    private let fileURL: URL

    init(directoryURL: URL? = nil) {
        let directory: URL
        if let directoryURL {
            directory = directoryURL
        } else if let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first {
            directory = applicationSupport.appending(
                path: "Samadhi",
                directoryHint: .isDirectory
            )
        } else {
            directory = FileManager.default.temporaryDirectory.appending(
                path: "Samadhi",
                directoryHint: .isDirectory
            )
        }
        self.directoryURL = directory
        fileURL = directory.appending(path: "latest-run-diagnostics.json")
    }

    func save(_ snapshot: RunDiagnosticSnapshot) throws {
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(snapshot).write(to: fileURL, options: .atomic)
    }

    func latest() throws -> RunDiagnosticSnapshot? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RunDiagnosticSnapshot.self, from: Data(contentsOf: fileURL))
    }
}

struct RunDiagnosticsRecorder {
    private let now: () -> Date
    private var startedAt: Date?
    private var timeline: [RunDiagnosticSnapshot.Entry] = []

    init(now: @escaping () -> Date = Date.init) {
        self.now = now
    }

    mutating func record(
        event: RunEvent,
        oldState: RunState,
        newState: RunState,
        collection: MusicCollection
    ) -> RunDiagnosticSnapshot? {
        if case .startTapped = event, newState != oldState {
            startedAt = now()
            timeline.removeAll(keepingCapacity: true)
        }

        guard let startedAt, newState != oldState, let kind = kind(for: event) else { return nil }
        let stateForEntry = newState.session == nil ? oldState : newState
        let session = stateForEntry.session
        let track = session.flatMap { session in
            collection.tracks.indices.contains(session.trackIndex)
                ? collection.tracks[session.trackIndex]
                : nil
        }
        let tempoMatched: Bool?
        if case let .activeSecond(value) = event {
            tempoMatched = value
        } else {
            tempoMatched = nil
        }

        timeline.append(
            RunDiagnosticSnapshot.Entry(
                offsetSeconds: max(now().timeIntervalSince(startedAt), 0),
                kind: kind,
                activeSeconds: session?.elapsedActiveSeconds ?? 0,
                cadenceSPM: cadence(in: stateForEntry),
                targetRate: session?.adaptationState.targetRate,
                controlMode: session?.rhythmControl.mode.rawValue,
                automaticCorrectionBPM: session?.rhythmControl.automaticCorrectionBPM,
                manualTargetBPM: session?.rhythmControl.manualTargetBPM,
                requestedBPM: session?.adaptationState.requestedBPM,
                derivedTargetRate: session?.adaptationState.derivedTargetRate,
                atLimit: session?.adaptationState.isAtLimit ?? false,
                appliedRate: session?.appliedPlaybackRate ?? 1,
                awaitingRateFeedback: session?.pendingRateRequestID != nil,
                trackID: session?.currentTrackID?.rawValue,
                trackTitle: track?.title,
                trackIndex: session?.trackIndex ?? 0,
                trackElapsedSeconds: session?.trackElapsedSeconds ?? 0,
                trackDurationSeconds: session?.trackDurationSeconds,
                tempoMatched: tempoMatched
            )
        )

        guard case let .summary(summary) = newState else { return nil }
        let snapshot = RunDiagnosticSnapshot(
            schemaVersion: 2,
            capturedAt: now(),
            collectionID: collection.id.rawValue,
            collectionName: collection.name,
            readyTrackCount: collection.tracks.count,
            summary: RunDiagnosticSnapshot.Summary(
                durationSeconds: summary.durationSeconds,
                averageCadence: summary.averageCadence,
                tempoMatchedPercent: summary.tempoMatchedPercent,
                songCount: summary.songCount
            ),
            timeline: timeline
        )
        self.startedAt = nil
        timeline.removeAll(keepingCapacity: true)
        return snapshot
    }

    private func kind(for event: RunEvent) -> RunDiagnosticSnapshot.Entry.Kind? {
        switch event {
        case .startTapped:
            .started
        case .cadenceUpdated:
            .cadenceUpdated
        case .cadenceConfidenceLost, .cadenceAcquisitionFailed:
            .cadenceLost
        case .playbackRateApplied:
            .rateApplied
        case .playbackProgress:
            .playerProgress
        case .playbackTrackChanged:
            .trackChanged
        case .pauseTapped:
            .paused
        case .resumeTapped, .routeResumeTapped:
            .resumeRequested
        case .audioRouteLost, .playbackRouteLost:
            .routeLost
        case .audioRouteRestored, .playbackRouteRestored:
            .routeRestored
        case .playbackInterrupted:
            .interruptionBegan
        case .playbackInterruptionEnded:
            .interruptionEnded
        case .playbackFailed:
            .playbackFailed
        case .activeSecond:
            .activeSecond
        case .rhythmControlAdjusted:
            .rhythmAdjusted
        case .rhythmControlSetManual, .rhythmControlReset:
            .rhythmModeChanged
        case .finishHoldCompleted:
            .finishRequested
        case .finishCompleted:
            .finished
        default:
            nil
        }
    }

    private func cadence(in state: RunState) -> Double? {
        switch state {
        case let .active(active):
            if case let .locked(spm) = active.activity.rhythm { return Double(spm) }
        case let .confirmingFinish(confirmation):
            if case let .locked(spm) = confirmation.origin.rhythm { return Double(spm) }
        case let .routeRecovery(recovery):
            if case let .locked(spm) = recovery.origin.rhythm { return Double(spm) }
        default:
            break
        }
        return state.session?.adaptationState.lastReliableCadenceSPM
    }
}
