import Foundation

public struct TrackTempoMatch: Sendable, Equatable {
    public let trackID: MusicTrackID
    public let collectionIndex: Int
    public let pulseBPM: Double
    public let sourcePulseBPM: Double
    public let relationship: StepBeatRelationship
    public let requiredRate: Double
    public let achievableCadenceBPM: Double
    public let cadenceErrorBPM: Double

    public init(
        trackID: MusicTrackID,
        collectionIndex: Int,
        pulseBPM: Double,
        sourcePulseBPM: Double,
        relationship: StepBeatRelationship,
        requiredRate: Double,
        achievableCadenceBPM: Double,
        cadenceErrorBPM: Double
    ) {
        self.trackID = trackID
        self.collectionIndex = collectionIndex
        self.pulseBPM = pulseBPM
        self.sourcePulseBPM = sourcePulseBPM
        self.relationship = relationship
        self.requiredRate = requiredRate
        self.achievableCadenceBPM = achievableCadenceBPM
        self.cadenceErrorBPM = cadenceErrorBPM
    }

    public var stretchDistance: Double {
        abs(log(requiredRate))
    }
}

public struct TrackMatchPlanner: Sendable {
    public let minimumRate: Double
    public let maximumRate: Double
    public let currentTrackRetention: Double
    public let cadenceToleranceBPM: Double

    public init(
        minimumRate: Double = TempoEnvelope.rateRange.lowerBound,
        maximumRate: Double = TempoEnvelope.rateRange.upperBound,
        currentTrackRetention: Double = 0.01,
        cadenceToleranceBPM: Double = TempoEnvelope.approximateMatchToleranceSPM
    ) {
        self.minimumRate = minimumRate
        self.maximumRate = maximumRate
        self.currentTrackRetention = max(currentTrackRetention, 0)
        self.cadenceToleranceBPM = max(cadenceToleranceBPM, 0)
    }

    public func select(
        requestedBPM: Double,
        from tracks: [MusicTrack],
        currentTrackID: MusicTrackID? = nil
    ) -> TrackTempoMatch? {
        guard TempoEnvelope.locomotionCadenceSPM.contains(requestedBPM),
            minimumRate > 0,
            minimumRate <= maximumRate
        else { return nil }

        let candidates = tracks.enumerated().compactMap { index, track in
            match(for: track, at: index, requestedBPM: requestedBPM)
        }
        guard let best = candidates.min(by: isBetter) else { return nil }

        guard let currentTrackID,
            let current = candidates.first(where: { $0.trackID == currentTrackID })
        else { return best }

        // A small advantage is not worth interrupting the song that is already playing.
        return cost(current) <= cost(best) + currentTrackRetention ? current : best
    }

    // Whether one song can carry this cadence inside the rate window. Nil means the song cannot.
    public func fit(of track: MusicTrack, requestedBPM: Double) -> TrackTempoMatch? {
        guard TempoEnvelope.locomotionCadenceSPM.contains(requestedBPM),
            minimumRate > 0,
            minimumRate <= maximumRate
        else { return nil }
        return match(for: track, at: 0, requestedBPM: requestedBPM)
    }

    // The closest step rhythm this song can reach for the request, even when that is not close
    // enough to count as a fit. Reach reporting uses its sign to say which way the song misses.
    public func nearestAchievableCadenceBPM(for track: MusicTrack, requestedBPM: Double) -> Double? {
        guard let tempo = track.tempo, minimumRate > 0, minimumRate <= maximumRate else { return nil }
        return tempo.cadenceProjections
            .map { projection in
                let rate = min(max(requestedBPM / projection.cadencePulseBPM, minimumRate), maximumRate)
                return projection.cadencePulseBPM * rate
            }
            .min { abs($0 - requestedBPM) < abs($1 - requestedBPM) }
    }

    // Cadence error is scored against the tolerance that admitted the match, so widening the
    // tolerance cannot leave the ranking normalized against a stale constant.
    private func cost(_ match: TrackTempoMatch) -> Double {
        let cadencePenalty =
            cadenceToleranceBPM > 0 ? match.cadenceErrorBPM / cadenceToleranceBPM : 0
        return cadencePenalty + match.stretchDistance + match.relationship.selectionCost
    }

    private func match(
        for track: MusicTrack,
        at index: Int,
        requestedBPM: Double
    ) -> TrackTempoMatch? {
        // An empty projection set is exactly what makes a track not adaptive-ready, so the
        // compactMap below is the readiness test. Asking twice would recompute the projections.
        guard let tempo = track.tempo else { return nil }

        return tempo.cadenceProjections.compactMap { projection in
            let derivedRate = requestedBPM / projection.cadencePulseBPM
            let rate = min(max(derivedRate, minimumRate), maximumRate)
            let achievableCadenceBPM = projection.cadencePulseBPM * rate
            let cadenceErrorBPM = abs(achievableCadenceBPM - requestedBPM)
            guard cadenceErrorBPM <= cadenceToleranceBPM else { return nil }
            return TrackTempoMatch(
                trackID: track.id,
                collectionIndex: index,
                pulseBPM: projection.cadencePulseBPM,
                sourcePulseBPM: projection.sourcePulseBPM,
                relationship: projection.relationship,
                requiredRate: rate,
                achievableCadenceBPM: achievableCadenceBPM,
                cadenceErrorBPM: cadenceErrorBPM
            )
        }.min(by: isBetter)
    }

    private func isBetter(_ lhs: TrackTempoMatch, than rhs: TrackTempoMatch) -> Bool {
        let difference = cost(lhs) - cost(rhs)
        if abs(difference) > 0.000_001 {
            return difference < 0
        }
        return lhs.collectionIndex < rhs.collectionIndex
    }
}
