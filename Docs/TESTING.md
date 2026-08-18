# Verification

## Full gate

~~~sh
./Scripts/bootstrap.sh
./Scripts/test.sh
~~~

Scripts/test.sh runs Swift package tests, app-model tests, and UI tests serially on iPhone 17 Pro Simulator.

The 2026-07-27 setup-craft gate passed 118 package tests, 25 app-model tests, and 21 UI tests serially.

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
- Active wheel and VoiceOver control pinning
- Mixed summary metrics
- Track progress reset and configured collection wraparound
- Rejection of half-time and double-time aliases outside the analyzed running-pulse range
- The 0.85 through 1.15 candidate bounds, one-second Auto retarget, eight-second response from normal speed to either endpoint, deadband, and target update interval
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
- Compatible-track ranking across the supported 90 through 210 SPM movement range
- A five-SPM approximate match passing while six SPM still fails
- Raw cadence staying unable to command playback before the separate Auto target settles
- Quality-envelope exclusion, source-order ties, and current-track retention
- Compatible adaptive starting-song selection from the initial cadence prior
- Five-second mismatch hold, prepared-next identity, recovery clearing, and stale preparation rejection
- Player-confirmed Previous and Skip truth instead of predicted song state
- One haptic for each accepted detent, a fuller event every five BPM, and one distinct warning at a requested limit
- Privacy-safe replay of the first field failure across broad Manual wheel input
- Applied, boundary-limited, and rejected command outcomes
- Manual and Auto candidate preparation without an implicit track change
- Rapid target coalescing, stale candidate rejection, explicit Skip authority, and player-confirmed natural-boundary authority
- Target reapplication after a player-confirmed track change
- Rapid detents coalescing toward the latest requested target before read-back
- Mismatched read-back rejecting the command and preserving latency evidence
- Tempo-matched coverage preventing unmeasured Manual time from producing a misleading percentage
- Clockwise and counterclockwise haptic direction through the reducer event

Design tests cover clockwise and counterclockwise one-BPM detents, partial-turn accumulation, reverse hysteresis, direction reversal, angle wraparound, multiple revolutions, reset between gestures, exactly 30 BPM per revolution, and readiness feedback only for a genuine transition to a newly runnable import.

Motion tests cover:

- The simulation and production provider boundary
- Five-observation stable lock
- Three-observation resume lock with the prior estimate as a smoothing seed
- Purposeful walking acquisition, below-range rejection, broken rep-like movement, isolated spikes, and sustained missing cadence

The Core Motion adapter compiles for a generic iPhone target. A 29-second physical walk produced changing cadence and a 142 SPM average. A privacy-safe replay now covers the exact 2026-08-15 delivery shape: callbacks advance about every 2.56 seconds while most samples are about 2.57 seconds old. Advancing timestamps allow those delayed new samples. Old first samples, repeats, backward timestamps, out-of-order callbacks, unexplained gaps, missing cadence, and values outside the supported range still fail. A second replay covers steady delayed walking samples near 100 SPM. Full placement calibration is not covered by automated tests.

The saved replay was run before the timing change and failed because it never locked. The same replay passed after the new advancing-timestamp rule.

Tempo-analysis tests cover:

- Periodic onset detection at 120, 150, 168, and 190 BPM
- Exact running-pulse agreement within 2 percent
- Alternating accents
- Strong every-third-beat accents reject instead of producing a confident triple-meter error
- Silence and irregular-onset rejection
- Mono and stereo audio-file decoding through the public analysis interface

These generated fixtures validate the module seam. The opt-in `TempoCorpusValidator` adds network evidence against 12 provider-hosted Apple previews whose catalog titles declare tempos from 130 through 180 BPM. Version 4 passed all 12 within 2 percent of the exact declared musical pulse. Lower-pulse, exact-180, silence, irregular-onset, and triple-meter regressions remain offline. No preview audio is committed.

UI tests cover:

- Complete golden run
- Motion permission recovery
- Audio route recovery
- Missing artwork
- No selected collection
- Playlist sheet opening, dismissal, compact two-playlist sizing, empty-library recovery, 40-playlist scrolling, selection, and current-playlist state
- Playlist-library loading with one truthful busy action and selected-playlist identity preserved during replacement
- Exact analysis progress with Start unavailable until a runnable import exists
- Partial import with separate ready truth and Review skipped action, an enabled ready-track Start, and every typed reason available in the result sheet
- Skipped reasons first, temporary retry beside its relevant section, ready tracks last, same-playlist retry, choose-another recovery, and authorization-specific recovery
- Long playlist names at standard and accessibility XXXL sizes
- In-run aperture click-wheel reveal, clockwise and counterclockwise angular adjustment, fixed Auto bounds, protected center, Manual ownership, and return to Auto
- Normal no-argument Simulator launch through local demo music and cadence lock
- Hidden Debug screen with separate song BPM and step SPM, four Apple Music result states, fresh-song reset, accessibility XXXL, and Reduce Motion

App-model tests cover ready mapping, start transition, atomic store round trips, corrupt persistence, restored selection, cancellation of stale replacement work, complete typed import presentation, ordered three-track import batches, retry of the same playlist, retry after relaunch, distinct authorization and import failures, playlist context for missing or empty imports, current selection during replacement, deterministic empty, compact, 40-playlist, long-name, and selected-loading fixtures, schema-version-9 rolling run diagnostics, unfinished-run survival, a reducer-driven diagnostic timeline through finish, hidden Debug calculations, private launch-argument redaction, immediate Simulator demo readiness, and replacement with a second local playlist.

## Visual proof

The final setup-craft contact sheet is `Evidence/Simulator/2026-07-27-setup-craft-contact-sheet.jpg`. Its 17 fresh iPhone 17 Pro frames cover empty setup; normal, compact, empty, current-selection, and scrolled 40-playlist picker states; loading with and without an existing selection; exact `2 / 8` analysis; partial and complete readiness; full skipped-results disclosure; temporary retry placement; import and authorization failures; a long name; accessibility XXXL; and Reduce Motion.

Two captured visual passes were inspected at original resolution. Pass one exposed low skipped-disclosure contrast and overlapping status/action content during the readiness handoff. Pass two raised disclosure contrast and changed the handoff to a 100-millisecond exit, 10-millisecond seam, and 100-millisecond entry. The normal and Reduce Motion review videos remain under `Evidence/Temp/setup-pass3/`. The normal sequence has no simultaneous old and new labels; the reduced sequence replaces the stage immediately with no positional travel.

The accessibility UI test uses the system `UICTContentSizeCategoryAccessibilityXXXL` launch value and proves the primary control is wider than 75 percent of the window. The final frame keeps the wrapped playlist identity above readiness, full-width Start, and Change playlist.

Earlier released frames cover locked run, controls, summary, Home Screen icon, BPM Auto fine-tune, the Manual safety limit, accessibility-size BPM controls, the resting `Turn` affordance, the prior rotary BPM click wheel, and normal local-demo readiness. Evidence/Previews/ covers other accessibility and state-specific visual checks.

The 2026-07-23 runtime review launched the normal app on iPhone 17 Simulator and inspected the ready and active-run screens. The focused rotary UI test made four strong clockwise turns, reached a requested target above 188 BPM, settled simulated Music BPM at the truthful 185 BPM boundary within two seconds, kept the same song, and never showed `Changing song`.

## Truth boundary

Simulator verifies interaction, accessibility structure, reducer behavior, resource packaging, and deterministic motion. Normal Debug Simulator launches use two local placeholder playlists, simulated cadence, and silent simulated playback. This path is disabled on physical devices and in Release builds. Simulator cannot validate physical cadence quality, real headphone route behavior, audible tempo adaptation, listening artifacts, or the tactile character of haptics.

The `Samadhi MusicKit Gate` scheme verifies that the harness and framework calls compile. Physical traces separately prove authorization, library loading, automatic token generation, strict catalog resolution, preview decoding, playback, mechanical rate writes, pause, and resume. Bluetooth listening, background, controlled interruption, and route checks remain separate physical gates.

## Current device checks

- Unsigned generic iPhone build: passed
- Signed generic and physical iPhone builds: passed
- Current BPM-control exact-profile signed build, installation, launch, and running process check: passed
- Physical iPhone installation and gate launch: passed
- Normal Simulator app: launched and visually checked
- Normal Debug Simulator local-demo flow: two playlists, start, cadence lock, rotary BPM, transport, transition, finish, and summary passed without Apple Music
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
- Real playlist selection and analysis: the July import passed at 13 ready, 8 unreadable, and 4 unavailable tracks from a 25-track physical selection; the latest pulled collection has 15 saved ready analyses
- Reinstall and relaunch restoration: passed with the selected collection checksum unchanged and the physical ready screen showing 13 of 25 ready
- Production-player progress: passed from a pulled schema-version-2 trace advancing from 0 through 6 seconds on one stable catalog identity
- Imported natural track transition: not yet physically run
- BPM control: deterministic command truth, rapid-detent coalescing, compatible-track response, rotary UI interaction, and Simulator design pass; physical audible response and directional click-wheel feel remain open
- Blinded perceptibility harness: 0.92 versus 1.08 sequence, direction answer, MusicKit read-back trace, the known 0.90 and 1.10 controls, and the candidate 0.85 and 1.15 controls compile in the debug gate scheme
- Paired iPhone state on 2026-07-21: connected over the local network; the exact-profile MusicKit harness built, installed, launched, and showed Beoplay Eleven as its Bluetooth A2DP route
- Exact profile state on 2026-07-21: embedded `Samadhi Development` profile verified with application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`; it expires on 2026-07-23 UTC
- One-track perceptibility result: 0.90 versus 1.10 was clearly audible on `LITE SPOTS` through Beoplay Eleven, with repeated requested and reported rate agreement
- Full perceptibility protocol: open; 0.90 versus 1.10 is the only physically heard pair. The 0.85 through 1.15 candidate needs full-song endpoint quality and matching Apple Music read-back before release.
- Production track-fit and rotary-control build: exact-profile signing, embedded application identifier, wireless installation, foreground launch, and normal setup rendering passed on the restored iPhone on 2026-07-22
- First normal field run: historical red evidence; 497 wheel adjustments and a 59-BPM requested span produced only a 0.056 MusicKit read-back span, while the summary reported 99 percent from automatic-only eligible samples
- Field-run remediation: privacy-safe replay, truthful command states, prompt read-back, nearest-boundary behavior, noncommitting candidate preparation, target reapplication, and honest coverage pass deterministically
- Import remediation: full six-track disclosure fixture, typed failure sections, retry after relaunch, ordered three-track batching, and timing persistence pass in Simulator and model tests
- Exact BPM and fresh Auto repair: formatter lint, 97 package tests, 15 app-model tests, 10 UI tests, exact `Samadhi Development` signing, application identifier verification, physical build, and installation passed on 2026-07-22; foreground launch waited on the locked phone and was not claimed
- Physical remediation check: open for audible direction, command latency, compatible track change, clockwise versus counterclockwise haptics, and real import wall time
- Historical July release profile: `Samadhi Development` UUID `982e709d-7aa8-4d79-aca3-7759c8f70fc5` expired on 2026-07-30 UTC and embedded `ZL5U59XBJ6.com.samaydhawan.Samadhi`. A later device build must inspect its own embedded profile.
- Current response-latency build: clean commit `66e0616`, exact-profile build, signature inspection, physical installation, and selected-collection checksum preservation passed; foreground launch was blocked by the locked phone
- Current setup-craft build: clean commit `0a59b64`, exact-profile build, embedded identity and signature inspection, in-place physical installation, and selected-collection checksum preservation passed; foreground launch was blocked by the locked phone
- 2026-08-15 exact phone build: profile `Samadhi Development 2026-08-15`, embedded identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`, app signature match, in-place install, and selected-collection checksum preservation passed
- 2026-08-15 phone baseline: 16 numeric Core Motion readings ranged from 151.56 to 158.10 SPM; 14 were about 2.57 seconds old and failed the 2.0-second freshness check, leaving only two accepted readings when three are required to lock
- 2026-08-15 Apple Music baseline: Manual and Auto rate writes were reported in about 0.04 to 0.07 seconds; one Auto read-back differed from the requested rate by about 1.19 SPM
- 2026-08-17 fingerprinted workout: the pulled file matched source fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498`; four supported delayed readings acquired 133 SPM, and Apple Music reported the exact 1.0390625 command after 0.066 seconds
- 2026-08-17 activity mix: 57 of 61 retained numeric cadence readings were below the current 120 SPM contract; substantial lifting occurred during the same period, so the low readings and elapsed time cannot all be attributed to walking
- Walking-range tuning: use a clean walking-only check before calling the 90 SPM floor and five-second delay physically tuned

## Felt-synchronization gate

Use five analyzed songs with prominent, stable beats. Compare 0.92, 1.00, and 1.08 on the supported Bluetooth route, then test 0.90 and 1.10 only if the first endpoints remain clean. Log requested rate, MusicKit read-back, route, audible artifacts, and blinded faster-or-slower recognition. Pass only if Samay identifies direction in at least four of five comparisons and calls the largest clean pair obvious rather than subtle.

The complete sequence, pivot rules, phase questions, and final evidence packet live in [FELT-SYNCHRONIZATION-EXECUTION-SPEC.md](FELT-SYNCHRONIZATION-EXECUTION-SPEC.md).

The current candidate adds a deterministic dirty-source fingerprint, safe replay of the delayed phone pattern, and a separate settled Auto target. Target tests cover 90, 100, and 110 SPM walking acquisition; 120, 130, 140, and 160 SPM running acquisition; ordinary noise; one spike; sustained faster and slower rhythms; walk-to-jog and jog-to-walk changes; missing readings; broken lifting-like values; and time-based behavior at the saved phone callback interval. The close-control tests verify a 44-point hit area outside the dial, clean dismissal, no run-state mutation, accessibility XXXL, Reduce Motion, and Increased Contrast. Fresh frames live under `Evidence/Simulator/2026-08-17-auto-target-close/`.

The final walking candidate passed 152 package tests, 27 app-model tests, and 28 serial UI tests. Resource-inclusive Debug and Release Simulator builds passed, and the hidden Debug interface was absent from Release. The exact-profile app recorded source fingerprint `9137f9db705f06e69d358178d56c090c9ff05f54cd9aa7109c37d3d32e03748b` and was installed in place. The selected collection checksum stayed `81a9b31fbc115d607bc766dd25374ecff6874b079276b68c3719cb122cea3f52`. A clean walking and listening check remains.

The later expanded-rate candidate passed 153 package tests, 27 app-model tests, 28 serial UI tests, source-fingerprint tests, and resource-inclusive Debug and Release Simulator builds. The hidden Debug interface remained absent from Release. Its exact-profile phone build records source fingerprint `fd8120ad2ac14e1090a687438e6564beb65bde0a61d58fab04d4ec7295535684`. It was installed in place, and the selected collection checksum stayed `81a9b31fbc115d607bc766dd25374ecff6874b079276b68c3719cb122cea3f52`. The phone locked before launch. In-app identity, 0.85 and 1.15 read-back, and listening remain open.

The later Auto feedback gate is physical. It must test faster and slower recognition, three coarse size levels, cue fatigue, screen lock, engine interruption and reset, iPhone speaker, primary Bluetooth headphones, first-play delay, Apple Music ducking or gaps, route changes, and sound-disabled and haptic-disabled fallbacks. Use the acceptance test in `Docs/AUTO-CHANGE-INTERACTION-SPEC.md`. Simulator can verify reducer triggers and asset packaging only.

The focused Simulator UI flow proves that Manual remains active before a requested song change and returns to Auto only after the player confirms a different song. It also proves that the explicit close action restores playback controls, including with accessibility XXXL text and Reduce Motion. Frames live under `Evidence/Simulator/2026-08-15-manual-close/`.

The phone baseline and pulled diagnostic live under `Evidence/Device/2026-08-15-core-reset/`. The later fingerprinted workout summary lives under `Evidence/Device/2026-08-17-auto-target/`. It confirms source identity, repaired acquisition, and one exact Apple Music reply. Samay also confirmed that Auto was audible but felt jarring and unexplained. Haptic feel, locked-screen cue delivery, known-cause natural transition behavior, broader listening quality, and sustained running feel remain open.

## Known environment behavior

iOS 27 beta Simulator can terminate concurrent UI test runners. Test script disables parallel execution. Serial suite is required gate.

The MacBook continuation gate passed on 2026-08-13 with 118 Swift package tests and 46 serial iPhone 17 Pro Simulator tests. The current simulator is the only local device kept for Samadhi. Physical-device checks remain distinct and require the available paired iPhone.
