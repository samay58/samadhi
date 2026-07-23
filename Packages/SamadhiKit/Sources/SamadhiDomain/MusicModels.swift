public struct MusicTrackID: Sendable, Hashable, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct MusicCollectionID: Sendable, Hashable, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct TempoAnalysis: Sendable, Equatable, Codable {
    public static let readyConfidence = 0.72

    public let baseBPM: Double
    public let alternatePulseBPM: Double?
    public let confidence: Double
    public let analyzedDurationSeconds: Double
    public let version: Int

    public init(
        baseBPM: Double,
        alternatePulseBPM: Double? = nil,
        confidence: Double,
        analyzedDurationSeconds: Double,
        version: Int
    ) {
        self.baseBPM = baseBPM
        self.alternatePulseBPM = alternatePulseBPM
        self.confidence = min(max(confidence, 0), 1)
        self.analyzedDurationSeconds = max(analyzedDurationSeconds, 0)
        self.version = version
    }

    public var isAdaptiveReady: Bool {
        confidence >= Self.readyConfidence && (120...210).contains(runningPulseBPM)
    }

    public var runningPulseBPM: Double {
        if (120...210).contains(baseBPM) { return baseBPM }
        if let alternatePulseBPM, (120...210).contains(alternatePulseBPM) {
            return alternatePulseBPM
        }
        return baseBPM
    }
}

public enum TrackAnalysisFailure: String, Sendable, Equatable, Codable {
    case rhythmUnclear
    case previewUnavailable
    case catalogMatchUnavailable
    case temporaryCatalogFailure
    case temporaryDownloadFailure
    case decodeFailure
    case couldNotReadTempo
    case unavailable
}

public enum MusicTrackAnalysisState: Sendable, Equatable, Codable {
    case pending
    case ready(TempoAnalysis)
    case failed(TrackAnalysisFailure)
}

public struct TempoAnalysisCacheKey: Sendable, Hashable, Codable {
    public let trackID: MusicTrackID
    public let sourceFingerprint: String
    public let analyzerVersion: Int

    public init(
        trackID: MusicTrackID,
        sourceFingerprint: String,
        analyzerVersion: Int
    ) {
        self.trackID = trackID
        self.sourceFingerprint = sourceFingerprint
        self.analyzerVersion = analyzerVersion
    }
}

public struct MusicTrack: Sendable, Equatable, Codable {
    public let id: MusicTrackID
    public let title: String
    public let artist: String?
    public let durationSeconds: Double
    public let sourceFingerprint: String
    public let analysisState: MusicTrackAnalysisState

    public init(
        id: MusicTrackID,
        title: String,
        artist: String? = nil,
        durationSeconds: Double,
        tempo: TempoAnalysis? = nil,
        sourceFingerprint: String = ""
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.durationSeconds = max(durationSeconds, 0)
        self.sourceFingerprint = sourceFingerprint
        analysisState = tempo.map(MusicTrackAnalysisState.ready) ?? .pending
    }

    public init(
        id: MusicTrackID,
        title: String,
        artist: String? = nil,
        durationSeconds: Double,
        sourceFingerprint: String,
        analysisState: MusicTrackAnalysisState
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.durationSeconds = max(durationSeconds, 0)
        self.sourceFingerprint = sourceFingerprint
        self.analysisState = analysisState
    }

    public var tempo: TempoAnalysis? {
        guard case let .ready(analysis) = analysisState else { return nil }
        return analysis
    }

    public var isAdaptiveReady: Bool {
        tempo?.isAdaptiveReady == true
    }
}

public struct MusicCollection: Sendable, Equatable, Codable {
    public let id: MusicCollectionID
    public let name: String
    public let tracks: [MusicTrack]

    public init(id: MusicCollectionID, name: String, tracks: [MusicTrack]) {
        self.id = id
        self.name = name
        self.tracks = tracks
    }

    public var readyTrackCount: Int {
        tracks.count { $0.isAdaptiveReady }
    }

    public var adaptiveReadyCollection: MusicCollection {
        MusicCollection(
            id: id,
            name: name,
            tracks: tracks.filter(\.isAdaptiveReady)
        )
    }
}

public struct PlaybackProgress: Sendable, Equatable {
    public let trackID: MusicTrackID
    public let elapsedSeconds: Double
    public let durationSeconds: Double

    public init(trackID: MusicTrackID, elapsedSeconds: Double, durationSeconds: Double) {
        self.trackID = trackID
        self.elapsedSeconds = max(elapsedSeconds, 0)
        self.durationSeconds = max(durationSeconds, 0)
    }

    public var fraction: Double {
        guard durationSeconds > 0 else { return 0 }
        return min(elapsedSeconds / durationSeconds, 1)
    }
}

public struct CadenceObservation: Sendable, Equatable {
    public let stepsPerMinute: Double?
    public let elapsedSeconds: Double
    public let sampleAgeSeconds: Double

    public init(
        stepsPerMinute: Double?,
        elapsedSeconds: Double,
        sampleAgeSeconds: Double = 0
    ) {
        self.stepsPerMinute = stepsPerMinute
        self.elapsedSeconds = max(elapsedSeconds, 0)
        self.sampleAgeSeconds = max(sampleAgeSeconds, 0)
    }
}
