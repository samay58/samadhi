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

Result: automatic rate response remains unproven.

## Diagnostic correction

The adapter now reports a rate only after reading `ApplicationMusicPlayer.state.playbackRate`. The focused build displays cadence, target rate, MusicKit read-back, and whether feedback remains pending.

The next check uses catalog track `1558215042`, estimated at 149.75 BPM. At 142 SPM, the deterministic policy ramps from 1.00 through 0.98 and 0.96 toward about 0.948. This remains inside the accepted 0.94 through 1.06 range and is large enough for an objective visual check.

The corrected build passed the full automated gate and an exact-profile iPhone build. Installation remains open because the phone became unavailable to Xcode after the observation.
