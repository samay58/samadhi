# Field repair analysis

Date: 2026-07-23

Device evidence came from the current Samadhi container on Samay's iPhone 17 Pro running iOS 27.0. Personal playlist metadata stays outside git. The two song names below are included because Samay named them in the field report.

## Recovered state

- Selected collection: 18 tracks
- Ready under tempo estimator version 4: 14
- Rhythm unclear: 2
- Catalog match unavailable: 2
- Import wall time: 9.37 seconds with concurrency 3
- Selected collection checksum: `b7feb07e586c1e55d61666725d7649357f14971b1e61f32b214f88c200e72d35`
- Import diagnostic checksum: `ece923232a54d26959f5f594084c64d5dbd278b8433fbff7c2c2c5a0d00981e5`
- Prior run diagnostic checksum: `c1fdd812209423a4ea702a626132187ad3e13eddf3bb86682abb8f240bc323ff`

The prior run diagnostic was captured on 2026-07-22 with schema version 2. It is historical evidence only. It does not contain the latest field run or command latency.

## Why LITE SPOTS appeared to skip

LITE SPOTS was not rejected by analysis. It was the first ready track with a measured musical pulse of 60.5 BPM, an explicit two-steps-per-beat projection of 121.25 SPM, and confidence 0.892.

The old startup policy ignored source order and selected the closest track to a hardcoded 168 SPM prior before current cadence existed. Gorilla's 179.5 BPM pulse fits 168 SPM at about 0.936x. LITE SPOTS would require about 1.386x against its 121.25 SPM projection. The reducer therefore began with Gorilla. This was deterministic initial selection, not an analyzer rejection or an unexplained MusicKit track change.

The repair starts with the first adaptive-ready track in playlist order. Wheel and Auto targets may prepare one latest next candidate, but only explicit Skip or a player-confirmed natural boundary may change the playing track. Every observed transition now records a reason.

## Cadence compatibility

The current 14 ready tracks were evaluated without recording identities. The production playback envelope remains 0.90 through 1.10.

| Requested cadence | Prior exact fit | Explicit relationship plus 3 SPM boundary |
| --- | ---: | ---: |
| 145 SPM | 6 of 14 | 7 of 14 |
| 160 SPM | 0 of 14 | 2 of 14 |
| 175 SPM | 2 of 14 | 2 of 14 |
| 190 SPM | 5 of 14 | 5 of 14 |
| Total matrix cells | 13 of 56 | 16 of 56 |

The explicit relationship model keeps measured musical BPM separate from cadence projection and closes small honest gaps at a rate boundary. It does not materially solve the requested broad cadence range. Public MusicKit exposes a writable playback-rate multiplier but documents neither a quality range nor beat-grid or phase controls. A wider rate needs a separate physical listening gate. If this coverage remains inadequate in the outdoor run, the audio-source and mechanics decision must reopen rather than hiding the limit behind a clamp.

## Auto response

The former filter used a six-sample median and moved the published cadence by no more than 2 SPM per callback. A 25 SPM change could therefore take many callbacks to become visible.

The repair separates acquisition, tracking, and reacquisition:

- Three fresh stable observations acquire or reacquire cadence.
- A stale prior cannot override three agreeing current observations.
- A change larger than 12 SPM requires one corroborating observation, which rejects an isolated spike.
- After corroboration, response is based on actual sample interval with a 1.1-second time constant and a 14 SPM-per-second movement bound.
- In the deterministic 150 to 175 SPM trace, the first changed sample is held, the second moves the estimate to at least 162 SPM, and the third reaches at least 169 SPM.
- Three stale, missing, or invalid samples return the filter to reacquisition.

Physical Core Motion callback intervals and MusicKit write-to-read-back latency are not yet measured for this repair. Rolling schema-version-5 diagnostics now persist raw cadence, `CMPedometerData.endDate`, sample age, callback interval, filter state, filtered cadence, request, rate command, MusicKit read-back, track identity, and transition reason during an unfinished run. The next device check can therefore be short and diagnostic rather than another blind field run.

## Wheel choice

The candidate changes one full revolution from 40 to 30 one-BPM detents. That is 25 percent less sensitive, enough to make small adjustments more deliberate without forcing excessive travel. Half-detent reverse hysteresis prevents tremor from chattering across a boundary. Direction, angle wraparound, center protection, multiple revolutions, local preview haptics, and one absolute commit at finger-up remain intact.

Thirty BPM per revolution is deterministically covered but not yet physically accepted. Warmth, grip, and directional recognition require one short iPhone check.

## Verification completed in this environment

- Swift formatter lint
- 116 Swift package tests
- iPhone package compilation
- Simulator package compilation
- iPhone app and app-model test typechecking
- Simulator app and app-model test typechecking
- Resource-inclusive Simulator build
- 16 app-model tests
- 10 serial UI tests
- Focused wheel proof that discovers the current song's upper boundary, blocks further outward travel, reverses immediately, retains the current track, and never presents `Changing song`

Exact-profile physical build and installation passed on 2026-07-25 for commit `42f4dd5`. Boundary feel, audible response, and the physical latency trace remain open. No product-behavior claim should be made until those checks run.

The installed `Samadhi Development` profile still verifies with UUID `982e709d-7aa8-4d79-aca3-7759c8f70fc5`, application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`, and expiration on 2026-07-30. The current shell reports no valid code-signing identity, so profile presence alone is not a physical-build pass.
