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

@Test func pulsesWithNoTruthfulCadenceProjectionAreRejected() {
    #expect(TrackMatchPlanner().select(requestedBPM: 170, from: [track("double", tempo: 340)]) == nil)
}

@Test func aSlowBeatCanSupportTwoStepsWithoutBecomingFalseMusicalTempo() throws {
    let music = track("slow-beat", tempo: 90)
    let match = try #require(
        TrackMatchPlanner().select(
            requestedBPM: 180,
            from: [music]
        ))

    #expect(music.tempo?.baseBPM == 90)
    #expect(music.tempo?.runningPulseBPM == 90)
    #expect(match.relationship == .twoStepsPerBeat)
    #expect(match.pulseBPM == 180)
}

@Test func anExplicitAlternatePulseCanRelateSlowMusicToRunningCadence() throws {
    let slowMusic = MusicTrack(
        id: MusicTrackID("slow-with-stride"),
        title: "Slow with stride",
        durationSeconds: 180,
        tempo: TempoAnalysis(
            baseBPM: 90,
            alternatePulseBPM: 180,
            confidence: 0.9,
            analyzedDurationSeconds: 30,
            version: 4
        )
    )

    let match = try #require(
        TrackMatchPlanner().select(requestedBPM: 180, from: [slowMusic])
    )

    #expect(slowMusic.tempo?.baseBPM == 90)
    #expect(match.pulseBPM == 180)
    #expect(match.relationship == .twoStepsPerBeat)
    #expect(match.requiredRate == 1)
}

@Test func detectedStepBeatRelationshipsStayExplicit() throws {
    let analysis = TempoAnalysis(
        baseBPM: 60.5,
        alternatePulseBPM: 121.25,
        confidence: 0.9,
        analyzedDurationSeconds: 30,
        version: 4
    )

    let projection = try #require(analysis.cadenceProjections.first)

    #expect(analysis.baseBPM == 60.5)
    #expect(projection.relationship == .twoStepsPerBeat)
    #expect(projection.musicalPulseBPM == 60.5)
    #expect(projection.cadencePulseBPM == 121.25)
}

@Test func anUnprovenFractionalRelationshipDoesNotCreateAFalseMatch() {
    let music = MusicTrack(
        id: MusicTrackID("fractional"),
        title: "Fractional",
        durationSeconds: 180,
        tempo: TempoAnalysis(
            baseBPM: 102.5,
            alternatePulseBPM: 204,
            confidence: 0.9,
            analyzedDurationSeconds: 30,
            version: 4
        )
    )

    let match = TrackMatchPlanner().select(requestedBPM: 160, from: [music])

    #expect(match == nil)
    #expect(music.tempo?.baseBPM == 102.5)
}

@Test func liteSpotsPulseStaysTruthfulWhenTheRequestedCadenceIsOutOfRange() {
    let music = MusicTrack(
        id: MusicTrackID("user-example"),
        title: "User example",
        durationSeconds: 180,
        tempo: TempoAnalysis(
            baseBPM: 60.5,
            alternatePulseBPM: 121.25,
            confidence: 0.892,
            analyzedDurationSeconds: 30,
            version: 4
        )
    )

    let match = TrackMatchPlanner().select(requestedBPM: 175, from: [music])

    #expect(match == nil)
    #expect(music.tempo?.baseBPM == 60.5)
}

@Test func aTruthfulBoundaryWithinMatchToleranceClosesSmallPlaylistGaps() throws {
    let match = try #require(
        TrackMatchPlanner().select(
            requestedBPM: 160,
            from: [track("upper-boundary", tempo: 145)]
        )
    )

    #expect(match.requiredRate == 1.1)
    #expect(abs(match.achievableCadenceBPM - 159.5) < 0.000_1)
    #expect(abs(match.cadenceErrorBPM - 0.5) < 0.000_1)
}

@Test func aBoundaryOutsideTempoMatchToleranceStillFailsClosed() {
    let match = TrackMatchPlanner().select(
        requestedBPM: 210,
        from: [track("far-away", tempo: 120)]
    )

    #expect(match == nil)
}

@Test func defaultEnvelopeIncludesThePhysicallyProvenTenPercentEndpoints() throws {
    let slower = try #require(
        TrackMatchPlanner().select(requestedBPM: 153, from: [track("slower", tempo: 170)])
    )
    let faster = try #require(
        TrackMatchPlanner().select(requestedBPM: 187, from: [track("faster", tempo: 170)])
    )

    #expect(abs(slower.requiredRate - 0.9) < 0.000_1)
    #expect(abs(faster.requiredRate - 1.1) < 0.000_1)
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

@Test func plannerUsesItsConfiguredRateEnvelope() {
    let standard = TrackMatchPlanner().select(
        requestedBPM: 189,
        from: [track("candidate", tempo: 168)]
    )
    let wider = TrackMatchPlanner(minimumRate: 0.88, maximumRate: 1.12).select(
        requestedBPM: 189,
        from: [track("candidate", tempo: 168)]
    )

    #expect(standard == nil)
    #expect(wider?.trackID == MusicTrackID("candidate"))
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
