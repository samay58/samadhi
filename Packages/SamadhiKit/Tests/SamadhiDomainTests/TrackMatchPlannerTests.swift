import Testing

@testable import SamadhiDomain

@Test func closestCompatiblePulseWinsAcrossTracks() throws {
    let match = try #require(
        TrackMatchPlanner().select(
            requestedBPM: 170,
            from: [track("first", tempo: 160), track("second", tempo: 168), track("third", tempo: 180)]
        )
    )

    #expect(match.trackID == MusicTrackID("second"))
    #expect(match.pulseBPM == 168)
    #expect(match.requiredRate == 170.0 / 168.0)
}

@Test func halfAndDoubleTempoFamiliesCanSupplyTheSamePulse() throws {
    let half = try #require(
        TrackMatchPlanner().select(requestedBPM: 170, from: [track("half", tempo: 85)])
    )
    let double = try #require(
        TrackMatchPlanner().select(requestedBPM: 170, from: [track("double", tempo: 340)])
    )

    #expect(half.pulseBPM == 170)
    #expect(double.pulseBPM == 170)
    #expect(half.requiredRate == 1)
    #expect(double.requiredRate == 1)
}

@Test func unavailableAndIncompatibleTracksAreExcluded() throws {
    let pending = MusicTrack(
        id: MusicTrackID("pending"),
        title: "Pending",
        durationSeconds: 180
    )
    let match = try #require(
        TrackMatchPlanner().select(
            requestedBPM: 180,
            from: [pending, track("too-slow", tempo: 150), track("ready", tempo: 176)]
        )
    )

    #expect(match.trackID == MusicTrackID("ready"))
}

@Test func sourceOrderBreaksAnExactTie() throws {
    let match = try #require(
        TrackMatchPlanner().select(
            requestedBPM: 168,
            from: [track("first", tempo: 168), track("second", tempo: 168)]
        )
    )

    #expect(match.trackID == MusicTrackID("first"))
    #expect(match.collectionIndex == 0)
}

@Test func currentTrackStaysWhenTheAlternativeIsOnlyMarginallyCloser() throws {
    let match = try #require(
        TrackMatchPlanner(currentTrackRetention: 0.01).select(
            requestedBPM: 170,
            from: [track("current", tempo: 168), track("closer", tempo: 169)],
            currentTrackID: MusicTrackID("current")
        )
    )

    #expect(match.trackID == MusicTrackID("current"))
}

@Test func materiallyBetterTrackReplacesTheCurrentTrack() throws {
    let match = try #require(
        TrackMatchPlanner(currentTrackRetention: 0.01).select(
            requestedBPM: 170,
            from: [track("current", tempo: 160), track("better", tempo: 170)],
            currentTrackID: MusicTrackID("current")
        )
    )

    #expect(match.trackID == MusicTrackID("better"))
}

@Test func plannerUsesItsConfiguredQualityEnvelope() {
    let conservative = TrackMatchPlanner().select(
        requestedBPM: 180,
        from: [track("candidate", tempo: 168)]
    )
    let provenWiderRange = TrackMatchPlanner(minimumRate: 0.92, maximumRate: 1.08).select(
        requestedBPM: 180,
        from: [track("candidate", tempo: 168)]
    )

    #expect(conservative == nil)
    #expect(provenWiderRange?.trackID == MusicTrackID("candidate"))
}

private func track(_ id: String, tempo: Double) -> MusicTrack {
    MusicTrack(
        id: MusicTrackID(id),
        title: id,
        durationSeconds: 180,
        tempo: TempoAnalysis(
            baseBPM: tempo,
            confidence: 0.9,
            analyzedDurationSeconds: 30,
            version: 2
        )
    )
}
