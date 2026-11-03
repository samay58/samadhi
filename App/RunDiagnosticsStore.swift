import Foundation
import SamadhiDomain
import SamadhiMotion

// One batch of a run's record. It holds only what is new since the last batch, because the store
// adds to the file instead of rewriting it.
struct RunDiagnosticSnapshot: Equatable, Sendable {
    // Bump when a reader of the pulled file needs to know the shape changed.
    static let currentSchemaVersion = 12

    // Every input the reducer saw, so a run can be replayed through later logic. Effects are the
    // readable names of what it asked for, to compare against a replay.
    struct LoggedEvent: Codable, Equatable, Sendable {
        let offsetSeconds: Double
        let event: RunEvent
        let effects: [String]
    }

    enum CompletionState: String, Codable, Sendable {
        case inProgress
        case completed
    }

    struct Summary: Codable, Equatable, Sendable {
        let durationSeconds: Int
        let averageCadence: Int?
        let tempoMatchedPercent: Int?
        let tempoMatchedCoveragePercent: Int
        let automaticSeconds: Int
        let manualSeconds: Int
        let songCount: Int
    }

    struct Entry: Codable, Equatable, Sendable {
        enum Kind: String, Codable, Sendable {
            case started
            case cadenceObserved
            case cadenceUpdated
            case autoFeedback
            case sameSongCallback
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
            // What physically became of a cue the service handled, and what the haptic engine did.
            case autoFeedbackDelivery
            case hapticEngine
            // The reducer planned a next song for the boundary, or said the collection is out of reach.
            case nextSongPlanned
            case reachNoticed
        }

        let offsetSeconds: Double
        let kind: Kind
        let activeSeconds: Int
        let cadenceSPM: Double?
        let rawCadenceSPM: Double?
        let sampleAgeSeconds: Double?
        let sampleEndDateSeconds: Double?
        let callbackIntervalSeconds: Double?
        let cadenceFilterState: String?
        let cadenceSampleDisposition: String?
        let filteredCadenceSPM: Double?
        let targetRate: Double?
        let controlMode: String?
        let automaticCorrectionBPM: Int?
        let manualTargetBPM: Int?
        let requestedBPM: Double?
        let musicalPulseBPM: Double?
        let alternatePulseBPM: Double?
        let analysisConfidence: Double?
        let analyzedDurationSeconds: Double?
        let analyzerVersion: Int?
        let originalStepRhythmSPM: Double?
        let stepBeatRelationship: String?
        let settledAutoTargetSPM: Double?
        let settledAutoTargetStatus: String?
        let appliedMusicalBPM: Double?
        let appliedStepRhythmSPM: Double?
        let residualTargetErrorSPM: Double?
        let derivedTargetRate: Double?
        let atLimit: Bool?
        let commandStatus: String?
        let achievableBPM: Double?
        let commandedRate: Double?
        let commandLatencySeconds: Double?
        let appliedRate: Double
        let awaitingRateFeedback: Bool
        let trackID: String?
        let trackTitle: String?
        let trackIndex: Int
        let trackElapsedSeconds: Int
        let trackDurationSeconds: Int?
        let tempoMatched: Bool?
        let trackChangeReason: String?
        let autoFeedbackTransactionID: Int?
        // The transaction's phase, or "cancelled" when a rule ended it before it arrived.
        let autoFeedbackPhase: String?
        let autoFeedbackDirection: String?
        let autoFeedbackSize: String?
        let autoFeedbackChangeSPM: Double?
        let autoFeedbackLimited: Bool?
        let autoFeedbackMoment: String?
        let autoFeedbackFamily: String?
        let autoFeedbackSoundPath: String?
        let autoFeedbackDeliveryOutcome: String?
        let autoFeedbackDeliveryDetail: String?
        let hapticEngineEvent: String?
        let nextSongOutlook: String?
        let plannedNextTrackTitle: String?
        let collectionReach: String?
        let totalSteps: Int?
        let distanceMeters: Double?
        let paceSecondsPerMeter: Double?

        init(
            offsetSeconds: Double,
            kind: Kind,
            activeSeconds: Int,
            cadenceSPM: Double?,
            rawCadenceSPM: Double? = nil,
            sampleAgeSeconds: Double? = nil,
            sampleEndDateSeconds: Double? = nil,
            callbackIntervalSeconds: Double? = nil,
            cadenceFilterState: String? = nil,
            cadenceSampleDisposition: String? = nil,
            filteredCadenceSPM: Double? = nil,
            targetRate: Double?,
            controlMode: String? = nil,
            automaticCorrectionBPM: Int? = nil,
            manualTargetBPM: Int? = nil,
            requestedBPM: Double? = nil,
            musicalPulseBPM: Double? = nil,
            alternatePulseBPM: Double? = nil,
            analysisConfidence: Double? = nil,
            analyzedDurationSeconds: Double? = nil,
            analyzerVersion: Int? = nil,
            originalStepRhythmSPM: Double? = nil,
            stepBeatRelationship: String? = nil,
            settledAutoTargetSPM: Double? = nil,
            settledAutoTargetStatus: String? = nil,
            appliedMusicalBPM: Double? = nil,
            appliedStepRhythmSPM: Double? = nil,
            residualTargetErrorSPM: Double? = nil,
            derivedTargetRate: Double? = nil,
            atLimit: Bool = false,
            commandStatus: String? = nil,
            achievableBPM: Double? = nil,
            commandedRate: Double? = nil,
            commandLatencySeconds: Double? = nil,
            appliedRate: Double,
            awaitingRateFeedback: Bool,
            trackID: String?,
            trackTitle: String?,
            trackIndex: Int,
            trackElapsedSeconds: Int,
            trackDurationSeconds: Int?,
            tempoMatched: Bool?,
            trackChangeReason: String? = nil,
            autoFeedbackTransactionID: Int? = nil,
            autoFeedbackPhase: String? = nil,
            autoFeedbackDirection: String? = nil,
            autoFeedbackSize: String? = nil,
            autoFeedbackChangeSPM: Double? = nil,
            autoFeedbackLimited: Bool? = nil,
            autoFeedbackMoment: String? = nil,
            autoFeedbackFamily: String? = nil,
            autoFeedbackSoundPath: String? = nil,
            autoFeedbackDeliveryOutcome: String? = nil,
            autoFeedbackDeliveryDetail: String? = nil,
            hapticEngineEvent: String? = nil,
            nextSongOutlook: String? = nil,
            plannedNextTrackTitle: String? = nil,
            collectionReach: String? = nil,
            totalSteps: Int? = nil,
            distanceMeters: Double? = nil,
            paceSecondsPerMeter: Double? = nil
        ) {
            self.totalSteps = totalSteps
            self.distanceMeters = distanceMeters
            self.paceSecondsPerMeter = paceSecondsPerMeter
            self.offsetSeconds = offsetSeconds
            self.kind = kind
            self.activeSeconds = activeSeconds
            self.cadenceSPM = cadenceSPM
            self.rawCadenceSPM = rawCadenceSPM
            self.sampleAgeSeconds = sampleAgeSeconds
            self.sampleEndDateSeconds = sampleEndDateSeconds
            self.callbackIntervalSeconds = callbackIntervalSeconds
            self.cadenceFilterState = cadenceFilterState
            self.cadenceSampleDisposition = cadenceSampleDisposition
            self.filteredCadenceSPM = filteredCadenceSPM
            self.targetRate = targetRate
            self.controlMode = controlMode
            self.automaticCorrectionBPM = automaticCorrectionBPM
            self.manualTargetBPM = manualTargetBPM
            self.requestedBPM = requestedBPM
            self.musicalPulseBPM = musicalPulseBPM
            self.alternatePulseBPM = alternatePulseBPM
            self.analysisConfidence = analysisConfidence
            self.analyzedDurationSeconds = analyzedDurationSeconds
            self.analyzerVersion = analyzerVersion
            self.originalStepRhythmSPM = originalStepRhythmSPM
            self.stepBeatRelationship = stepBeatRelationship
            self.settledAutoTargetSPM = settledAutoTargetSPM
            self.settledAutoTargetStatus = settledAutoTargetStatus
            self.appliedMusicalBPM = appliedMusicalBPM
            self.appliedStepRhythmSPM = appliedStepRhythmSPM
            self.residualTargetErrorSPM = residualTargetErrorSPM
            self.derivedTargetRate = derivedTargetRate
            self.atLimit = atLimit
            self.commandStatus = commandStatus
            self.achievableBPM = achievableBPM
            self.commandedRate = commandedRate
            self.commandLatencySeconds = commandLatencySeconds
            self.appliedRate = appliedRate
            self.awaitingRateFeedback = awaitingRateFeedback
            self.trackID = trackID
            self.trackTitle = trackTitle
            self.trackIndex = trackIndex
            self.trackElapsedSeconds = trackElapsedSeconds
            self.trackDurationSeconds = trackDurationSeconds
            self.tempoMatched = tempoMatched
            self.trackChangeReason = trackChangeReason
            self.autoFeedbackTransactionID = autoFeedbackTransactionID
            self.autoFeedbackPhase = autoFeedbackPhase
            self.autoFeedbackDirection = autoFeedbackDirection
            self.autoFeedbackSize = autoFeedbackSize
            self.autoFeedbackChangeSPM = autoFeedbackChangeSPM
            self.autoFeedbackLimited = autoFeedbackLimited
            self.autoFeedbackMoment = autoFeedbackMoment
            self.autoFeedbackFamily = autoFeedbackFamily
            self.autoFeedbackSoundPath = autoFeedbackSoundPath
            self.autoFeedbackDeliveryOutcome = autoFeedbackDeliveryOutcome
            self.autoFeedbackDeliveryDetail = autoFeedbackDeliveryDetail
            self.hapticEngineEvent = hapticEngineEvent
            self.nextSongOutlook = nextSongOutlook
            self.plannedNextTrackTitle = plannedNextTrackTitle
            self.collectionReach = collectionReach
        }
    }

    let schemaVersion: Int
    let capturedAt: Date
    let build: BuildIdentity
    let environment: DiagnosticEnvironment
    let completionState: CompletionState?
    let collectionID: String
    let collectionName: String
    let readyTrackCount: Int
    let summary: Summary
    let timeline: [Entry]
    let startedAt: Date
    // The first batch of a run opens its file and carries what only needs saying once.
    let startsRun: Bool
    let tracks: [MusicTrack]
    let events: [LoggedEvent]
    let device: [TimedDeviceContext]

    init(
        schemaVersion: Int,
        capturedAt: Date,
        build: BuildIdentity = .current,
        environment: DiagnosticEnvironment = .current,
        completionState: CompletionState? = .completed,
        collectionID: String,
        collectionName: String,
        readyTrackCount: Int,
        summary: Summary,
        timeline: [Entry],
        startedAt: Date? = nil,
        startsRun: Bool = false,
        tracks: [MusicTrack] = [],
        events: [LoggedEvent] = [],
        device: [TimedDeviceContext] = []
    ) {
        self.startedAt = startedAt ?? capturedAt
        self.startsRun = startsRun
        self.tracks = tracks
        self.events = events
        self.device = device
        self.schemaVersion = schemaVersion
        self.capturedAt = capturedAt
        self.build = build
        self.environment = environment
        self.completionState = completionState
        self.collectionID = collectionID
        self.collectionName = collectionName
        self.readyTrackCount = readyTrackCount
        self.summary = summary
        self.timeline = timeline
    }
}

// Each run is one file with one JSON object per line, and writing only ever adds to the end. A run of
// any length costs the same per line, and a crash loses at most the last few seconds of ticks.
actor RunDiagnosticsStore {
    private let recordsURL: URL
    private let runLimit: Int
    private let encoder: JSONEncoder
    private var handle: FileHandle?

    private struct Line<Body: Encodable>: Encodable {
        let line: String
        let body: Body
    }

    private struct Header: Encodable {
        let schemaVersion: Int
        let startedAt: Date
        let build: BuildIdentity
        let environment: DiagnosticEnvironment
        let collectionID: String
        let collectionName: String
        let readyTrackCount: Int
        let tracks: [MusicTrack]
    }

    private struct Status: Encodable {
        let capturedAt: Date
        let completionState: RunDiagnosticSnapshot.CompletionState?
        let summary: RunDiagnosticSnapshot.Summary
    }

    init(directoryURL: URL? = nil, runLimit: Int = 60) {
        let directory =
            directoryURL
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appending(path: "Samadhi", directoryHint: .isDirectory)
            ?? FileManager.default.temporaryDirectory.appending(
                path: "Samadhi",
                directoryHint: .isDirectory
            )
        recordsURL = directory.appending(path: "run-records", directoryHint: .isDirectory)
        self.runLimit = runLimit
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func append(_ batch: RunDiagnosticSnapshot) throws {
        if batch.startsRun {
            try openRecord(for: batch)
        }
        guard let handle else { return }

        var data = Data()
        if batch.startsRun {
            try add(
                "header",
                Header(
                    schemaVersion: batch.schemaVersion,
                    startedAt: batch.startedAt,
                    build: batch.build,
                    environment: batch.environment,
                    collectionID: batch.collectionID,
                    collectionName: batch.collectionName,
                    readyTrackCount: batch.readyTrackCount,
                    tracks: batch.tracks
                ),
                to: &data
            )
        }
        for event in batch.events {
            try add("event", event, to: &data)
        }
        for entry in batch.timeline {
            try add("entry", entry, to: &data)
        }
        for sample in batch.device {
            try add("device", sample, to: &data)
        }
        try add(
            "status",
            Status(
                capturedAt: batch.capturedAt,
                completionState: batch.completionState,
                summary: batch.summary
            ),
            to: &data
        )
        try handle.write(contentsOf: data)

        if batch.completionState == .completed {
            try handle.close()
            self.handle = nil
        }
    }

    func runCount() throws -> Int {
        guard FileManager.default.fileExists(atPath: recordsURL.path) else { return 0 }
        return try FileManager.default.contentsOfDirectory(atPath: recordsURL.path).count
    }

    private func add(_ line: String, _ body: some Encodable, to data: inout Data) throws {
        data.append(try encoder.encode(Line(line: line, body: body)))
        data.append(0x0A)
    }

    private func openRecord(for batch: RunDiagnosticSnapshot) throws {
        try handle?.close()
        handle = nil

        let manager = FileManager.default
        try manager.createDirectory(at: recordsURL, withIntermediateDirectories: true)
        let stamp = batch.startedAt.ISO8601Format().replacing(":", with: "-")
        var url = recordsURL.appending(path: "\(stamp).jsonl")
        var attempt = 1
        while manager.fileExists(atPath: url.path) {
            attempt += 1
            url = recordsURL.appending(path: "\(stamp)-\(attempt).jsonl")
        }
        manager.createFile(atPath: url.path, contents: nil)
        handle = try FileHandle(forWritingTo: url)

        let kept = try manager.contentsOfDirectory(atPath: recordsURL.path).sorted()
        for name in kept.dropLast(runLimit) {
            try manager.removeItem(at: recordsURL.appending(path: name))
        }
    }
}

// One raw Core Motion sample and what the filter made of it. This changes no product state, so it
// never becomes a RunEvent; the shell hands it straight to the recorder.
struct CadenceDiagnosticSample {
    var totalSteps: Int?
    var distanceMeters: Double?
    var paceSecondsPerMeter: Double?
    let rawStepsPerMinute: Double?
    let sampleAgeSeconds: Double
    let sampleEndDateSeconds: Double
    let callbackIntervalSeconds: Double
    let filterState: CadenceTrackingState
    let disposition: CadenceSampleDisposition
    let filteredStepsPerMinute: Double?
}

struct RunDiagnosticsRecorder {
    private static let checkpointInterval: TimeInterval = 5

    private let now: () -> Date
    private var startedAt: Date?
    private var lastCheckpointAt: Date?
    private var startsRun = false
    // Only what the store has not been handed yet.
    private var timeline: [RunDiagnosticSnapshot.Entry] = []
    private var events: [RunDiagnosticSnapshot.LoggedEvent] = []
    private var device: [TimedDeviceContext] = []

    init(now: @escaping () -> Date = Date.init) {
        self.now = now
    }

    mutating func record(
        event: RunEvent,
        oldState: RunState,
        newState: RunState,
        effects: [RunEffect] = [],
        collection: MusicCollection
    ) -> RunDiagnosticSnapshot? {
        if case .startTapped = event, newState != oldState {
            startedAt = now()
            startsRun = true
            lastCheckpointAt = nil
            timeline.removeAll(keepingCapacity: true)
            events.removeAll(keepingCapacity: true)
            device.removeAll(keepingCapacity: true)
        }
        guard let startedAt else { return nil }
        // Every input goes in, including one that changed nothing, because that is a fact as well.
        events.append(
            RunDiagnosticSnapshot.LoggedEvent(
                offsetSeconds: max(now().timeIntervalSince(startedAt), 0),
                event: event,
                effects: effects.map { String(describing: $0) }
            )
        )

        guard newState != oldState else { return nil }
        let tempoMatched: Bool?
        if case let .activeSecond(value) = event {
            tempoMatched = value
        } else {
            tempoMatched = nil
        }

        // A finish leaves no session on the new state, so the entry still reads the run it ended.
        let stateForEntry = newState.session == nil ? oldState : newState
        let eventKind = kind(for: event)
        if let eventKind {
            append(
                kind: eventKind,
                state: stateForEntry,
                collection: collection,
                tempoMatched: tempoMatched,
                trackChangeReason: trackChangeReason(for: event),
                cadenceSample: nil
            )
        }
        let feedback = autoFeedbackEvidence(from: oldState, to: newState)
        if let feedback {
            append(
                kind: .autoFeedback,
                state: stateForEntry,
                collection: collection,
                tempoMatched: nil,
                trackChangeReason: nil,
                cadenceSample: nil,
                autoFeedback: feedback
            )
        }
        let planned = newState.session?.pendingNextTrackID
        let plannedChanged = planned != nil && planned != oldState.session?.pendingNextTrackID
        if plannedChanged {
            append(
                kind: .nextSongPlanned,
                state: stateForEntry,
                collection: collection,
                tempoMatched: nil,
                trackChangeReason: nil,
                cadenceSample: nil
            )
        }
        let noticed = newState.session?.collectionReach.noticed ?? []
        let reachNoticed = noticed.count > (oldState.session?.collectionReach.noticed.count ?? 0)
        if reachNoticed {
            append(
                kind: .reachNoticed,
                state: stateForEntry,
                collection: collection,
                tempoMatched: nil,
                trackChangeReason: nil,
                cadenceSample: nil
            )
        }
        guard eventKind != nil || feedback != nil || plannedChanged || reachNoticed else { return nil }
        return checkpoint(
            completingWith: newState,
            session: stateForEntry.session,
            collection: collection,
            isImmediate: feedback != nil || plannedChanged || reachNoticed
                || eventKind.map(isImmediateCheckpoint) == true
        )
    }

    // The feedback service reports what became of a cue. This is shell evidence, not product
    // state, so it arrives here directly and is written at once.
    mutating func record(
        autoFeedbackDelivery delivery: AutoFeedbackDeliveryRecord,
        state: RunState,
        collection: MusicCollection
    ) -> RunDiagnosticSnapshot? {
        guard startedAt != nil else { return nil }
        append(
            kind: .autoFeedbackDelivery,
            state: state,
            collection: collection,
            tempoMatched: nil,
            trackChangeReason: nil,
            cadenceSample: nil,
            delivery: delivery
        )
        return checkpoint(
            completingWith: state,
            session: state.session,
            collection: collection,
            isImmediate: true
        )
    }

    mutating func record(
        hapticEngine event: AutoFeedbackEngineEvent,
        state: RunState,
        collection: MusicCollection
    ) -> RunDiagnosticSnapshot? {
        guard startedAt != nil else { return nil }
        append(
            kind: .hapticEngine,
            state: state,
            collection: collection,
            tempoMatched: nil,
            trackChangeReason: nil,
            cadenceSample: nil,
            engineEvent: event
        )
        return checkpoint(
            completingWith: state,
            session: state.session,
            collection: collection,
            isImmediate: true
        )
    }

    // The player named the song it is already on. Product state does not move, so this is recorded
    // straight from the shell as evidence.
    mutating func record(
        sameSongCallbackIn state: RunState,
        collection: MusicCollection
    ) -> RunDiagnosticSnapshot? {
        guard startedAt != nil else { return nil }
        append(
            kind: .sameSongCallback,
            state: state,
            collection: collection,
            tempoMatched: nil,
            trackChangeReason: nil,
            cadenceSample: nil
        )
        return checkpoint(
            completingWith: state,
            session: state.session,
            collection: collection,
            isImmediate: true
        )
    }

    mutating func record(
        cadenceSample: CadenceDiagnosticSample,
        state: RunState,
        collection: MusicCollection
    ) -> RunDiagnosticSnapshot? {
        guard startedAt != nil else { return nil }
        append(
            kind: .cadenceObserved,
            state: state,
            collection: collection,
            tempoMatched: nil,
            trackChangeReason: nil,
            cadenceSample: cadenceSample
        )
        return checkpoint(
            completingWith: state,
            session: state.session,
            collection: collection,
            isImmediate: false
        )
    }

    mutating func record(
        device sample: DeviceContext,
        state: RunState,
        collection: MusicCollection
    ) -> RunDiagnosticSnapshot? {
        guard let startedAt else { return nil }
        device.append(
            TimedDeviceContext(offsetSeconds: max(now().timeIntervalSince(startedAt), 0), context: sample)
        )
        return checkpoint(
            completingWith: state,
            session: state.session,
            collection: collection,
            isImmediate: false
        )
    }

    private mutating func append(
        kind: RunDiagnosticSnapshot.Entry.Kind,
        state stateForEntry: RunState,
        collection: MusicCollection,
        tempoMatched: Bool?,
        trackChangeReason: TrackChangeReason?,
        cadenceSample cadenceObservation: CadenceDiagnosticSample?,
        autoFeedback: AutoFeedbackEvidence? = nil,
        delivery: AutoFeedbackDeliveryRecord? = nil,
        engineEvent: AutoFeedbackEngineEvent? = nil
    ) {
        guard let startedAt else { return }
        let session = stateForEntry.session
        let track = session.flatMap { session in
            collection.tracks.indices.contains(session.trackIndex)
                ? collection.tracks[session.trackIndex]
                : nil
        }
        let plannedTrackID = session?.preparedNextTrackID ?? session?.pendingNextTrackID
        let plannedTrack = plannedTrackID.flatMap { id in collection.tracks.first { $0.id == id } }
        let appliedStepRhythmSPM = track?.tempo.map {
            (session?.adaptationState.baseTempoBPM ?? $0.stepPulseSPM)
                * (session?.adaptationState.appliedRateReadback ?? session?.appliedPlaybackRate ?? 1)
        }
        let residualTargetErrorSPM = session?.adaptationState.requestedBPM.flatMap { target in
            appliedStepRhythmSPM.map { $0 - target }
        }

        timeline.append(
            RunDiagnosticSnapshot.Entry(
                offsetSeconds: max(now().timeIntervalSince(startedAt), 0),
                kind: kind,
                activeSeconds: session?.elapsedActiveSeconds ?? 0,
                cadenceSPM: cadence(in: stateForEntry),
                rawCadenceSPM: cadenceObservation?.rawStepsPerMinute,
                sampleAgeSeconds: cadenceObservation?.sampleAgeSeconds,
                sampleEndDateSeconds: cadenceObservation?.sampleEndDateSeconds,
                callbackIntervalSeconds: cadenceObservation?.callbackIntervalSeconds,
                cadenceFilterState: cadenceObservation?.filterState.rawValue,
                cadenceSampleDisposition: cadenceObservation?.disposition.rawValue,
                filteredCadenceSPM: cadenceObservation?.filteredStepsPerMinute,
                targetRate: session?.adaptationState.targetRate,
                controlMode: session?.rhythmControl.mode.rawValue,
                automaticCorrectionBPM: session?.rhythmControl.automaticCorrectionBPM,
                manualTargetBPM: session?.rhythmControl.manualTargetBPM,
                requestedBPM: session?.adaptationState.requestedBPM,
                musicalPulseBPM: session?.adaptationState.musicalTempoBPM
                    ?? track?.tempo?.baseBPM,
                alternatePulseBPM: track?.tempo?.alternatePulseBPM,
                analysisConfidence: track?.tempo?.confidence,
                analyzedDurationSeconds: track?.tempo?.analyzedDurationSeconds,
                analyzerVersion: track?.tempo?.version,
                originalStepRhythmSPM: session?.adaptationState.baseTempoBPM
                    ?? track?.tempo?.stepPulseSPM,
                stepBeatRelationship: session?.adaptationState.stepBeatRelationship?.rawValue,
                settledAutoTargetSPM: session?.autoTargetState.settledTargetSPM,
                settledAutoTargetStatus: session?.autoTargetState.status.rawValue,
                appliedMusicalBPM: track?.tempo.map {
                    $0.baseBPM
                        * (session?.adaptationState.appliedRateReadback
                            ?? session?.appliedPlaybackRate ?? 1)
                },
                appliedStepRhythmSPM: appliedStepRhythmSPM,
                residualTargetErrorSPM: residualTargetErrorSPM,
                derivedTargetRate: session?.adaptationState.derivedTargetRate,
                atLimit: session?.adaptationState.isAtLimit ?? false,
                commandStatus: session?.adaptationState.commandStatus.rawValue,
                achievableBPM: session?.adaptationState.achievableBPM,
                commandedRate: session?.adaptationState.commandedRate,
                commandLatencySeconds: session?.adaptationState.commandLatencySeconds,
                appliedRate: session?.appliedPlaybackRate ?? 1,
                awaitingRateFeedback: session?.pendingRateRequestID != nil,
                trackID: session?.currentTrackID?.rawValue,
                trackTitle: track?.title,
                trackIndex: session?.trackIndex ?? 0,
                trackElapsedSeconds: session?.trackElapsedSeconds ?? 0,
                trackDurationSeconds: session?.trackDurationSeconds,
                tempoMatched: tempoMatched,
                trackChangeReason: trackChangeReason?.rawValue,
                autoFeedbackTransactionID: autoFeedback?.transactionID ?? delivery?.transactionID,
                autoFeedbackPhase: autoFeedback?.phase,
                autoFeedbackDirection: autoFeedback?.direction,
                autoFeedbackSize: autoFeedback?.size,
                autoFeedbackChangeSPM: autoFeedback?.changeSPM,
                autoFeedbackLimited: autoFeedback?.isLimited,
                autoFeedbackMoment: delivery?.moment.rawValue,
                autoFeedbackFamily: delivery?.family.rawValue,
                autoFeedbackSoundPath: delivery?.soundPath.rawValue,
                autoFeedbackDeliveryOutcome: delivery?.outcome.rawValue,
                autoFeedbackDeliveryDetail: delivery?.detail ?? engineEvent?.detail,
                hapticEngineEvent: engineEvent?.name,
                nextSongOutlook: session?.nextSongOutlook.rawValue,
                plannedNextTrackTitle: plannedTrack?.title,
                collectionReach: session?.collectionReach.condition?.rawValue,
                totalSteps: cadenceObservation?.totalSteps,
                distanceMeters: cadenceObservation?.distanceMeters,
                paceSecondsPerMeter: cadenceObservation?.paceSecondsPerMeter
            )
        )
    }

    // An unfinished run still writes evidence so an abandoned field check is not lost. Frequent
    // entries are throttled; anything that changes the run writes immediately.
    private mutating func checkpoint(
        completingWith state: RunState,
        session: RunSession?,
        collection: MusicCollection,
        isImmediate: Bool
    ) -> RunDiagnosticSnapshot? {
        let completedSummary: RunSummary?
        if case let .summary(summary) = state {
            completedSummary = summary
        } else {
            completedSummary = nil
        }
        let throttleElapsed =
            lastCheckpointAt.map { now().timeIntervalSince($0) >= Self.checkpointInterval } ?? true
        guard completedSummary != nil || isImmediate || throttleElapsed else { return nil }
        // Never fabricate a summary. Without a run there is nothing honest to write.
        guard let summary = completedSummary ?? session?.summary, let startedAt else { return nil }
        lastCheckpointAt = now()
        let snapshot = RunDiagnosticSnapshot(
            schemaVersion: RunDiagnosticSnapshot.currentSchemaVersion,
            capturedAt: now(),
            completionState: completedSummary == nil ? .inProgress : .completed,
            collectionID: collection.id.rawValue,
            collectionName: collection.name,
            readyTrackCount: collection.tracks.count,
            summary: RunDiagnosticSnapshot.Summary(
                durationSeconds: summary.durationSeconds,
                averageCadence: summary.averageCadence,
                tempoMatchedPercent: summary.tempoMatchedPercent,
                tempoMatchedCoveragePercent: summary.tempoMatchedCoveragePercent,
                automaticSeconds: summary.automaticSeconds,
                manualSeconds: summary.manualSeconds,
                songCount: summary.songCount
            ),
            timeline: timeline,
            startedAt: startedAt,
            startsRun: startsRun,
            tracks: startsRun ? collection.tracks : [],
            events: events,
            device: device
        )
        startsRun = false
        timeline.removeAll(keepingCapacity: true)
        events.removeAll(keepingCapacity: true)
        device.removeAll(keepingCapacity: true)
        if completedSummary != nil {
            self.startedAt = nil
            lastCheckpointAt = nil
        }
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
        case .rhythmControlAdjusted, .rhythmControlTargetCommitted:
            .rhythmAdjusted
        case .rhythmControlSetManual, .rhythmControlReset:
            .rhythmModeChanged
        case .finishHoldCompleted, .recoveryEndRunTapped:
            .finishRequested
        case .finishCompleted:
            .finished
        default:
            nil
        }
    }

    private func isImmediateCheckpoint(_ kind: RunDiagnosticSnapshot.Entry.Kind) -> Bool {
        switch kind {
        case .started, .cadenceUpdated, .cadenceLost, .rateApplied, .trackChanged,
            .paused, .resumeRequested, .routeLost, .routeRestored, .interruptionBegan,
            .interruptionEnded, .playbackFailed, .rhythmAdjusted, .rhythmModeChanged,
            .finishRequested, .finished, .autoFeedback, .sameSongCallback,
            .autoFeedbackDelivery, .hapticEngine, .nextSongPlanned, .reachNoticed:
            true
        case .cadenceObserved, .playerProgress, .activeSecond:
            false
        }
    }

    struct AutoFeedbackEvidence: Equatable {
        let transactionID: Int
        let phase: String
        let direction: String
        let size: String
        let changeSPM: Double
        let isLimited: Bool
    }

    // One entry every time the transaction identity or its phase moves, including the moment a rule
    // ends it, so a Debug trace shows that nothing replayed.
    private func autoFeedbackEvidence(
        from oldState: RunState,
        to newState: RunState
    ) -> AutoFeedbackEvidence? {
        let previous = oldState.session?.autoFeedback.transaction
        let current = newState.session?.autoFeedback.transaction
        if let current {
            guard previous?.id != current.id || previous?.phase != current.phase else { return nil }
            return AutoFeedbackEvidence(
                transactionID: current.id,
                phase: current.phase.rawValue,
                direction: current.direction.rawValue,
                size: current.size.rawValue,
                changeSPM: current.changeSPM,
                isLimited: current.isLimited
            )
        }
        guard let previous else { return nil }
        return AutoFeedbackEvidence(
            transactionID: previous.id,
            phase: "cancelled",
            direction: previous.direction.rawValue,
            size: previous.size.rawValue,
            changeSPM: previous.changeSPM,
            isLimited: previous.isLimited
        )
    }

    private func trackChangeReason(for event: RunEvent) -> TrackChangeReason? {
        guard case let .playbackTrackChanged(_, _, _, _, reason, _) = event else { return nil }
        return reason
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
