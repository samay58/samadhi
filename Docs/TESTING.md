# Verification

## Full gate

~~~sh
./Scripts/bootstrap.sh
./Scripts/test.sh
~~~

Scripts/test.sh runs Swift package tests, app-model tests, and UI tests serially on iPhone 17 Pro Simulator.

The 2026-07-21 full serial gate passed 67 package tests, 9 app-model tests, and 9 UI tests.

Formatter gate:

~~~sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  xcrun swift-format lint --configuration .swift-format --recursive \
  App Packages/SamadhiKit/Sources Packages/SamadhiKit/Tests Tests
~~~

## Coverage

Domain tests cover:

- Adaptive and fixed starts
- Stale cadence and timeout tokens
- Paused-time exclusion
- Resume reacquisition with cadence prior
- Permission fallback
- Route loss and explicit resume
- Finish visibility and hold identity
- Cancellation ordering
- VoiceOver control pinning
- Mixed summary metrics
- Track progress reset and configured collection wraparound
- Half-time and double-time tempo normalization
- Safe rate bounds, initial and ongoing ramps, deadband, and target update interval
- The 149.75 BPM focused fixture ramping from 1.00 through 0.98 and 0.96 toward a safe 142 SPM target
- Target recomputation when the track changes at a steady cadence
- Confidence hold, return to normal rate, and reacquisition reset
- Incompatible tracks and applied-rate match timing
- Honest tempo measurement and fixed-rhythm Not measured summary
- Stable cadence producing bounded, identified playback-rate effects
- Applied-rate feedback requiring current session, operation, request, and track identity
- Confidence loss holding the last rate, easing to 1.00, and returning to acquisition
- Stale session feedback and cadence-provider failure
- Imported collection order, ready-track filtering, and cache-key invalidation
- Refusal to start a production collection without an adaptive-ready track
- Auto correction, Manual targeting, reset, bounds, and honest limit reporting
- Manual behavior before cadence lock, through confidence loss, pause, resume, and track change
- Prevention of a general surface tap replacing an open rhythm control
- Compatible-track ranking across half-time, full-time, and double-time pulse families
- Quality-envelope exclusion, source-order ties, and current-track retention

Motion tests cover:

- The simulation and production provider boundary
- Five-observation stable lock
- Three-observation resume lock with the prior estimate as a smoothing seed
- Walking-range rejection, isolated spike rejection, and sustained missing cadence

The Core Motion adapter compiles for a generic iPhone target. A 29-second physical walk produced changing cadence and a 142 SPM average. Full placement calibration is not covered by this observation or automated tests.

Tempo-analysis tests cover:

- Periodic onset detection at 120, 150, 168, and 190 BPM
- Half and double tempo equivalence within 2 percent
- Alternating accents
- Strong every-third-beat accents reject instead of producing a confident triple-meter error
- Silence and irregular-onset rejection
- Mono and stereo audio-file decoding through the public analysis interface

These generated fixtures validate the module seam. The opt-in `TempoCorpusValidator` adds network evidence against 12 provider-hosted Apple previews whose catalog titles declare tempos from 130 through 180 BPM. Version 2 passed 12 of 12 within 2 percent of the reference or its half or double. No preview audio is committed, and normal tests remain offline.

UI tests cover:

- Complete golden run
- Motion permission recovery
- Audio route recovery
- Missing artwork
- No selected collection
- Honest analysis progress
- Partial import with visible failures and an enabled ready-track start
- Import failure and retry
- In-run BPM-control reveal, one-BPM adjustment, Manual ownership, and return to Auto

App-model tests cover ready mapping, start transition, atomic store round trips, corrupt persistence, restored selection, cancellation of stale replacement work, latest-run diagnostic persistence with BPM-control truth, and a reducer-driven diagnostic timeline through finish.

## Visual proof

Final frames under Evidence/Simulator/ cover ready, imported empty and partial states, locked run, controls, summary, Home Screen icon, BPM Auto fine-tune, the Manual safety limit, and accessibility-size BPM controls. Evidence/Previews/ covers other accessibility and state-specific visual checks.

## Truth boundary

Simulator verifies interaction, accessibility structure, reducer behavior, resource packaging, and deterministic motion. It cannot validate physical cadence quality, real headphone route behavior, tempo adaptation, or listening artifacts.

The `Samadhi MusicKit Gate` scheme verifies that the harness and framework calls compile. Physical traces separately prove authorization, library loading, automatic token generation, strict catalog resolution, preview decoding, playback, mechanical rate writes, pause, and resume. Bluetooth listening, background, controlled interruption, and route checks remain separate physical gates.

## Current device checks

- Unsigned generic iPhone build: passed
- Signed generic and physical iPhone builds: passed
- Current BPM-control exact-profile signed build, installation, launch, and running process check: passed
- Physical iPhone installation and gate launch: passed
- Normal Simulator app: launched and visually checked
- MusicKit harness Simulator app: launched and visually checked
- Background audio entry in built Info.plist: verified as an array containing `audio`
- Physical device signing, build, installation, and launch: passed
- Import-capable normal app exact-profile build, installation, and launch: passed
- Latest-run diagnostics exact-profile build and installation: passed; existing selected playlist survived byte-for-byte
- Latest-run diagnostics foreground launch: blocked because the physical iPhone is locked
- Focused body-to-music exact-profile build, installation, and launch argument: passed
- Physical cadence seam: passed for a 29-second walk with changing cadence and a 142 SPM average
- Automatic cadence-driven rate response: passed; the corrected 59-second physical run averaged 155 SPM and measured 98 percent tempo matched from MusicKit read-back
- Focused rate diagnostics: target, pending feedback, and MusicKit read-back are shown separately; commanded values are no longer echoed as applied
- Contextual Music authorization and 40-playlist loading: passed
- Real playback plus 0.94, 1.00, and 1.06 rate writes: passed mechanically
- Pause and resume observation: passed
- Direct library preview coverage: failed at 0 of 10 in every sample
- ISRC catalog retry: blocked because all 40 sampled tracks omitted ISRC
- Exact-App-ID signing: passed with `Samadhi Development` and application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`
- Automatic developer token: passed with repeated direct catalog responses
- Strict catalog resolution: passed for 10 of 10 City Pocket tracks with 0.0-second duration deltas
- Temporary preview download and PCM decode: passed for 10 of 10 City Pocket tracks
- Built-in-speaker listening: passed provisionally; no major pitch change or unpleasant artifacts were reported at 0.94 and 1.06
- Bluetooth A2DP route: passed on Beoplay Eleven
- Bluetooth rate writes during playback: passed at 0.94, 1.00, and 1.06
- Bluetooth listening note: not recorded
- Spotify adaptive playback: rejected by documented platform capability and policy review; no code spike warranted
- Screen-lock background, next track, controlled interruption, and route-loss checks: deferred to the reliability gate
- Real playlist selection and analysis: passed at 13 ready, 8 unreadable, and 4 unavailable tracks from a 25-track physical selection
- Reinstall and relaunch restoration: passed with the selected collection checksum unchanged and the physical ready screen showing 13 of 25 ready
- Production-player progress: passed from a pulled schema-version-2 trace advancing from 0 through 6 seconds on one stable catalog identity
- Imported natural track transition: not yet physically run
- BPM control: deterministic policy, UI interaction, and Simulator design pass; physical MusicKit response and listening proof not yet run
- Blinded perceptibility harness: 0.92 versus 1.08 sequence, direction answer, MusicKit read-back trace, and optional 0.90 and 1.10 controls compile in the debug gate scheme
- Paired iPhone state on 2026-07-21: unavailable to Xcode; exact `Samadhi Development` profile was previously verified through 2026-07-23 UTC

## Felt-synchronization gate

Use five analyzed songs with prominent, stable beats. Compare 0.92, 1.00, and 1.08 on the supported Bluetooth route, then test 0.90 and 1.10 only if the first endpoints remain clean. Log requested rate, MusicKit read-back, route, audible artifacts, and blinded faster-or-slower recognition. Pass only if Samay identifies direction in at least four of five comparisons and calls the largest clean pair obvious rather than subtle.

After that gate, connect `TrackMatchPlanner` to production selection and prove one compatible-track transition. Pull `latest-run-diagnostics.json` and confirm requested BPM, selected pulse, required rate, MusicKit read-back, progress, and summary agree. Renew the exact profile first if testing occurs after 2026-07-23 UTC. Before Milestone 2 completion, record one concise Bluetooth listening note and prove five screen-locked minutes, controlled interruption, and route loss.

## Known environment behavior

iOS 27 beta Simulator can terminate concurrent UI test runners. Test script disables parallel execution. Serial suite is required gate.
