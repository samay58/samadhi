# First normal field-run failure analysis

Date: 2026-07-22

Device: Samay's iPhone 17 Pro

OS: iOS 27.0 (`24A5390f`)

## User result

The normal app imported and ran, but the user could not feel the requested BPM changes. Playlist analysis felt slow, the result showed only the first few songs, and the click-wheel haptics felt weak with no distinct clockwise or counterclockwise indication. The user correctly treated this as a failed product mechanic.

## Pulled evidence

The app container was copied directly from the paired phone after the run.

- Active duration: 240 seconds
- Songs observed: 4
- Average cadence: 126 SPM
- Summary shown: 99 percent tempo matched
- Timeline entries: 1,129
- Rhythm adjustments: 497
- Requested BPM span: 120 through 179
- Derived target-rate span: 0.669 through 1.479
- MusicKit applied-rate events: 17
- MusicKit applied-rate span: 0.956 through 1.012
- Final requested BPM: 120
- Final applied rate: 1.00
- Eligible automatic summary samples: 141, of which 140 were matched
- Manual active seconds excluded from tempo-match measurement: 99

The selected collection contained 18 tracks: 11 ready, 5 failed because no trusted tempo was produced, and 2 were unavailable. The raw run and collection records contain personal library metadata and were not committed.

- Raw run trace SHA-256: `c1fdd812209423a4ea702a626132187ad3e13eddf3bb86682abb8f240bc323ff`
- Raw collection record SHA-256: `f1726fd763bf47265ea125bd3d333ae57b1c039ba7438ef0ab71d628f982ba8c`

## Reproduction signal

The direct trace check is red when more than 100 wheel adjustments and at least 40 requested BPM produce less than 0.08 of applied-rate movement. This trace produced 497 adjustments, 59 requested BPM, and 0.056 applied-rate movement.

## Diagnosed causes

1. `ReadyScreen` intentionally renders `collection.tracks.prefix(5)`, so every later result is hidden.
2. Import processes each song sequentially through catalog resolution, preview download, local decode, and tempo estimation.
3. Five songs collapsed to `couldNotReadTempo`, which currently combines low confidence, ambiguous pulse, download failure, and decode failure. Two `unavailable` results combine catalog-resolution and preview-availability failure.
4. Manual targets can range from 120 through 210 BPM, but the production player clamps rate to 0.94 through 1.06. `AdaptationPolicy` marks an incompatible target at the limit, clears its target rate, and commands a return toward 1.00. The interface continues displaying the unachievable request.
5. A better-fitting track is only prepared after sustained mismatch and does not replace the current song until a later transition. The wheel therefore has no prompt audible response for incompatible targets.
6. Player read-back is sampled once per second. Rapid wheel changes overwrite the single pending request, which weakens causality between a detent and verified playback.
7. `HapticEvent.rhythmStep` retains only the five-BPM landmark flag. Clockwise versus counterclockwise direction is discarded. Minor intensity is 0.28 and major intensity is 0.52, matching the user's report that the wheel feels weak.
8. The 99 percent summary was mathematically consistent with its eligible automatic samples, but it did not reveal that manual control time was unmeasured or that large requested changes were rejected.

## Decision

Command truth and felt response are the highest priority. No visual polish, reliability work, or additional feature should proceed until the app either produces a prompt, verified, audible change or explicitly explains that the current track cannot reach the request. If public MusicKit cannot pass that gate, use the existing source pivot instead of preserving a false control.

## Remediation status

The captured behavior now has a privacy-safe replay test. The repair separates requested BPM, achievable BPM, commanded rate, MusicKit read-back, latency, and command status. An unreachable detent returns to the last truthful target. A compatible alternate track is prepared and committed immediately for direct wheel input, then the current target is reapplied after the player confirms the change. Rapid detents coalesce toward the latest requested target while the interface continues to wait for real read-back before calling it applied.

Tempo matched now requires verified player feedback and at least 80 percent measurement coverage. Automatic and Manual seconds remain explicit in schema-version-3 diagnostics. The recorded 141 eligible seconds across a 240-second field run therefore produce 58 percent coverage and Not measured instead of a misleading 99 percent.

The import path now preserves every source track, records distinct rhythm, preview, catalog, download, and decode outcomes, runs three ordered tracks at a time, supports retry after relaunch, and saves private stage timings. The primary ready composition shows three rows and opens every result through `All tracks`. Clockwise and counterclockwise wheel direction now reach stronger, distinct haptic patterns.

Verification on 2026-07-22 passed formatter lint, 92 package tests, 14 app-model tests, 10 UI tests, the exact-profile physical build, embedded application identifier verification, and installation on Samay's connected iPhone. These checks prove command logic, import disclosure, accessibility structure, signing, and installation. They do not prove audible response, haptic comfort, or real import duration. One short physical check remains required before this failure can be closed.
