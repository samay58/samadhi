import Testing
@testable import SamadhiAudio

@Test func beatPhaseRepeatsDeterministically() {
    let clock = BeatClockSnapshot(bpm: 120, anchorUptime: 10)
    #expect(clock.phase(atUptime: 10.25) == 0.5)
    #expect(clock.phase(atUptime: 10.75) == 0.5)
}

@Test func pausedBeatClockFreezesAtCapturedPhase() {
    let clock = BeatClockSnapshot(bpm: 168, anchorUptime: 10, pausedPhase: 0.18)
    #expect(clock.phase(atUptime: 10) == 0.18)
    #expect(clock.phase(atUptime: 300) == 0.18)
}
