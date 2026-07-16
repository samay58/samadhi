# Rate-response observation

Date: 2026-07-16

Device: Samay's iPhone 17 Pro

OS: iOS 27.0

Source: Apple Music through `Samadhi Apple Music Core Loop`

Track: `1434921088`, “Can't Stop the Feeling! (Workout Remix 140 BPM)” by Power Music Workout

Track tempo: 139.5 BPM, analyzer version 2, confidence 1

Route: not reported

## Observation

Samay reported no perceptible music-speed change during the brief walk.

At the previously observed 142 SPM cadence, the expected target was about 1.02. That change may be too subtle to distinguish by listening alone. The build also immediately echoed the commanded rate into run state, so its existing “applied” value could not objectively prove MusicKit read-back.

Result at this point: automatic rate response remained unproven.

## Diagnostic correction

The adapter now reports a rate only after reading `ApplicationMusicPlayer.state.playbackRate`. The focused build displays cadence, target rate, MusicKit read-back, and whether feedback remains pending.

The next check uses catalog track `1558215042`, estimated at 149.75 BPM. At 142 SPM, the deterministic policy ramps from 1.00 through 0.98 and 0.96 toward about 0.948. This remains inside the accepted 0.94 through 1.06 range and is large enough for an objective visual check.

The corrected build passed the full automated gate and an exact-profile iPhone build. Installation remains open because the phone became unavailable to Xcode after the observation.

## Objective follow-up

The corrected build was installed after the phone reconnected. Samay completed a 59-second run with the 149.75 BPM fixture.

- Average cadence: 155 SPM
- Tempo matched: 98 percent
- Songs: 1

At a fixed 1.00 playback rate, the fixture's effective tempo would remain 149.75 BPM. That is 5.25 SPM from the observed average and outside the three-SPM match tolerance. A 155 SPM target instead calls for a rate near 1.035. The 98 percent measured result therefore proves that MusicKit read-back moved into the compatible range for nearly every measured second. The summary only records stable playback and uses the player-reported applied rate.

Result: automatic cadence-driven rate response passes on the physical iPhone.

The live target and applied values were released when the session moved to the summary, so the completed-run panel shows placeholders. Its post-run `feedback settled` label is also a default with no active request and is not used as evidence. Future focused observations should be captured programmatically during the run or written to a focused trace file.

User-supplied iPhone frame: [objective rate-response summary](2026-07-16-objective-rate-response-summary.png)

SHA-256: `2c89e833e1accdf795515403d6b735a42a8a808597790d1a55dc67b4ea69aca7`
