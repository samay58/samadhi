import Testing

@testable import SamadhiDesign

@Test func aSongThatCouldNotBeReadLeavesAGapInPlace() {
    let lines = PlaylistContourMap.lines(
        for: [
            song("a", bpm: 120),
            ImportedTrackPresentation(id: "b", title: "b", status: .rhythmUnclear),
            song("c", bpm: 120),
        ],
        totalCount: 3
    )

    #expect(lines.map(\.id) == ["a", "c"])
    #expect(lines.map(\.position) == [0, 1])
}

@Test func aFasterSongRipplesTighterThanASlowerOne() {
    let lines = PlaylistContourMap.lines(for: [song("slow", bpm: 90), song("fast", bpm: 180)], totalCount: 2)

    #expect(lines[0].crests == 3)
    #expect(lines[1].crests == 6)
}

@Test func linesKeepTheirPlaceWhileTheRestOfThePlaylistIsStillBeingRead() {
    let partial = PlaylistContourMap.lines(for: [song("a", bpm: 120), song("b", bpm: 130)], totalCount: 5)
    let complete = PlaylistContourMap.lines(
        for: ["a", "b", "c", "d", "e"].map { song($0, bpm: $0 == "b" ? 130 : 120) },
        totalCount: 5
    )

    #expect(Array(complete.prefix(2)) == partial)
}

@Test func aLongPlaylistThinsItsMapInsteadOfTurningSolid() {
    let tracks = (0..<300).map { song("song-\($0)", bpm: 120) }
    let lines = PlaylistContourMap.lines(for: tracks, totalCount: 300)

    #expect(lines.count == PlaylistContourMap.maximumLines)
    #expect(lines.first?.position == 0)
    #expect(lines.last?.position == 1)
}

@Test func theFieldWarmsOnlyWithSongsActuallyRead() {
    #expect(selection(completed: 0, total: 0).fieldBloom == 0.25)
    #expect(selection(completed: 0, total: 4).fieldBloom == 0.25)
    #expect(selection(completed: 2, total: 4).fieldBloom == 0.625)
    #expect(selection(completed: 4, total: 4).fieldBloom == 1)
    #expect(MusicSelectionPresentation.none.fieldBloom == 0.55)
}

@Test func thePlainRestingLinesShowOnlyWithoutAPlaylist() {
    #expect(MusicSelectionPresentation.none.contourLines == nil)
    #expect(selection(completed: 0, total: 0).contourLines == [])
}

@Test func theSongNameShownIsTheLatestOneRead() {
    let collection = ImportedCollectionPresentation(
        name: "Fixture",
        totalTrackCount: 3,
        readyTrackCount: 1,
        completedTrackCount: 2,
        tracks: [
            song("first", bpm: 120),
            ImportedTrackPresentation(id: "second", title: "second", status: .rhythmUnclear),
            ImportedTrackPresentation(id: "third", title: "third", status: .pending),
        ]
    )

    #expect(collection.latestReadTitle == "second")
    #expect(collection.latestReadBPM == nil)
}

@Test func theTempoShownIsTheLatestSongsRoundedMeasurement() {
    let collection = ImportedCollectionPresentation(
        name: "Fixture",
        totalTrackCount: 2,
        readyTrackCount: 1,
        completedTrackCount: 1,
        tracks: [song("first", bpm: 137.6)]
    )

    #expect(collection.latestReadBPM == 138)
}

private func song(_ id: String, bpm: Double) -> ImportedTrackPresentation {
    ImportedTrackPresentation(id: id, title: id, status: .ready, pulseBPM: bpm)
}

private func selection(completed: Int, total: Int) -> MusicSelectionPresentation {
    .analyzing(
        ImportedCollectionPresentation(
            name: "Fixture",
            totalTrackCount: total,
            readyTrackCount: 0,
            completedTrackCount: completed,
            tracks: []
        )
    )
}

@Test func aTempoChangeKeepsTheBeatWhereItWas() {
    var clock = BeatClock(bpm: 120)
    let before = clock.phase(at: 10.2)

    clock.retime(toBPM: 180, at: 10.2)

    #expect(abs(clock.phase(at: 10.2) - before) < 0.000_1)
    // 180 BPM is three beats a second, so a tenth of a second later is 0.3 of a beat on.
    #expect(abs(clock.phase(at: 10.3) - (before + 0.3).truncatingRemainder(dividingBy: 1)) < 0.000_1)
}

@Test func theConeIsStillForTheLastThirdOfABeat() {
    #expect(BeatClock.pump(atPhase: 0) == 1)
    #expect(BeatClock.pump(atPhase: 0.7) == 0)
    #expect(BeatClock.pump(atPhase: 0.99) == 0)
}

@Test func theFieldHoldsItsPlaceWhenItStopsAndContinuesFromThere() {
    var clock = FieldClock()
    #expect(clock.time(at: 100) == 100)

    clock.stop(at: 100)
    #expect(clock.time(at: 500) == 100)
    #expect(clock.restingTime == 100)

    clock.start(at: 500)
    #expect(clock.time(at: 500) == 100)
    #expect(clock.time(at: 503) == 103)
}

@Test func aFieldThatNeverRanRestsAtTheStart() {
    #expect(FieldClock().restingTime == 0)
}
