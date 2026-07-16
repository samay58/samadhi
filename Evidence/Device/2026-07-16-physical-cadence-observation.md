# Physical cadence observation

Date: 2026-07-16

Device: Samay's iPhone 17 Pro

OS: iOS 27.0

Source: Apple Music through `Samadhi Apple Music Core Loop`

Track: `1066177773`, “Shake It Off (Workout Remix 170 Bpm)” by Hanna

Track tempo: 170.25 BPM, analyzer version 2, confidence 1

Placement: right-front pocket

Duration: 29 seconds

Route: not reported

Screenshot: `2026-07-16-physical-cadence-summary.png`

SHA-256: `50a8ba09715b3a30c5f88a9cdd4e7fcaca46d9e7b1c391df8ee12141e1b5e50c`

## Observation

Samay observed the displayed cadence changing during movement, though less frequently than expected. The run summary recorded a 142 SPM average and 0 percent tempo matched.

The update cadence is consistent with the five-observation acquisition filter, smoothing, deadband, and minimum update interval. Those rules intentionally prevent raw pedometer changes from driving nervous UI or audio.

The original track could not match 142 SPM inside the 0.94 through 1.06 safety range. The required rate was about 0.83, so the honest result was to leave the track unmatched. This observation proves live Core Motion cadence reached the production loop. It does not prove automatic rate response or listening quality.

## Follow-up

The focused fixture changes to catalog track `1434921088`, “Can't Stop the Feeling! (Workout Remix 140 BPM)” by Power Music Workout. Its validated estimate is 139.5 BPM with confidence 1. At the observed walking cadence, the target rate is about 1.02 and remains inside the safe range.

One final brief walk or jog is enough to observe automatic rate response before playlist import begins.
