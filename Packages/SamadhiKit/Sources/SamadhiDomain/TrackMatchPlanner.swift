import Foundation

public struct TrackTempoMatch: Sendable, Equatable {
    public let trackID: MusicTrackID
    public let collectionIndex: Int
    public let pulseBPM: Double
    public let requiredRate: Double

    public init(
        trackID: MusicTrackID,
        collectionIndex: Int,
        pulseBPM: Double,
        requiredRate: Double
    ) {
        self.trackID = trackID
        self.collectionIndex = collectionIndex
        self.pulseBPM = pulseBPM
        self.requiredRate = requiredRate
    }

    public var stretchDistance: Double {
        abs(log(requiredRate))
    }
}

public struct TrackMatchPlanner: Sendable {
    public let minimumRate: Double
    public let maximumRate: Double
    public let currentTrackRetention: Double

    public init(
        minimumRate: Double = 0.94,
        maximumRate: Double = 1.06,
        currentTrackRetention: Double = 0.01
    ) {
        self.minimumRate = minimumRate
        self.maximumRate = maximumRate
        self.currentTrackRetention = max(currentTrackRetention, 0)
    }

    public func select(
        requestedBPM: Double,
        from tracks: [MusicTrack],
        currentTrackID: MusicTrackID? = nil
    ) -> TrackTempoMatch? {
        guard requestedBPM > 0, minimumRate > 0, minimumRate <= maximumRate else { return nil }

        let candidates = tracks.enumerated().compactMap { index, track in
            match(for: track, at: index, requestedBPM: requestedBPM)
        }
        guard let best = candidates.min(by: isBetter) else { return nil }

        guard let currentTrackID,
            let current = candidates.first(where: { $0.trackID == currentTrackID })
        else { return best }

        // A small advantage is not worth interrupting the song that is already playing.
        return current.stretchDistance <= best.stretchDistance + currentTrackRetention ? current : best
    }

    private func match(
        for track: MusicTrack,
        at index: Int,
        requestedBPM: Double
    ) -> TrackTempoMatch? {
        guard let tempo = track.tempo, tempo.isAdaptiveReady, tempo.baseBPM > 0 else { return nil }

        return [tempo.baseBPM / 2, tempo.baseBPM, tempo.baseBPM * 2]
            .filter { (120...210).contains($0) }
            .compactMap { pulse -> TrackTempoMatch? in
                let rate = requestedBPM / pulse
                guard (minimumRate...maximumRate).contains(rate) else { return nil }
                return TrackTempoMatch(
                    trackID: track.id,
                    collectionIndex: index,
                    pulseBPM: pulse,
                    requiredRate: rate
                )
            }
            .min(by: isBetter)
    }

    private func isBetter(_ lhs: TrackTempoMatch, than rhs: TrackTempoMatch) -> Bool {
        let difference = lhs.stretchDistance - rhs.stretchDistance
        if abs(difference) > 0.000_001 {
            return difference < 0
        }
        return lhs.collectionIndex < rhs.collectionIndex
    }
}
