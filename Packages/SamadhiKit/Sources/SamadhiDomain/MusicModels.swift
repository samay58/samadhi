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
    public let confidence: Double
    public let analyzedDurationSeconds: Double
    public let version: Int

    public init(baseBPM: Double, confidence: Double, analyzedDurationSeconds: Double, version: Int) {
        self.baseBPM = baseBPM
        self.confidence = min(max(confidence, 0), 1)
        self.analyzedDurationSeconds = max(analyzedDurationSeconds, 0)
        self.version = version
    }

    public var isAdaptiveReady: Bool {
        confidence >= Self.readyConfidence
    }
}

public struct MusicTrack: Sendable, Equatable, Codable {
    public let id: MusicTrackID
    public let title: String
    public let artist: String?
    public let durationSeconds: Double
    public let tempo: TempoAnalysis?

    public init(
        id: MusicTrackID,
        title: String,
        artist: String? = nil,
        durationSeconds: Double,
        tempo: TempoAnalysis? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.durationSeconds = max(durationSeconds, 0)
        self.tempo = tempo
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

    public init(stepsPerMinute: Double?, elapsedSeconds: Double) {
        self.stepsPerMinute = stepsPerMinute
        self.elapsedSeconds = max(elapsedSeconds, 0)
    }
}
