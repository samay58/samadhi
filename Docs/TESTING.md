# Verification

## Full gate

~~~sh
./Scripts/gate.sh
~~~

This regenerates the project and fails if it drifted from `project.yml`, runs the formatter lint, the source-fingerprint tests, the Swift package tests, and the app-model and interface tests serially on iPhone 17 Pro Simulator. It then builds Debug and Release and proves the Debug-only screens are absent from Release, with a control string on each side.

GitHub Actions repeats the lint, fingerprint, and package tests on every push. Interface tests and phone checks stay on a real Mac.

The latest gate passed on 2026-11-02 on the Mac Mini with Xcode 27.2 and the iOS 27.0 Simulator: 209 package tests, 67 app-model tests, and 32 interface tests in 4 minutes 28 seconds, at source fingerprint `1b649fd7b86d142f0553c57a50a60947d2b28d4b787acb444925bdb974d9b975`. Nine of the app-model tests are direct screen tests, described in [DEVELOPMENT.md](DEVELOPMENT.md). The physical checks in [PHONE-CHECK.md](PHONE-CHECK.md) are unaffected and remain open.

The gate passed again on 2026-11-05 with 210 package tests, 68 app-model tests, and 32 interface tests, at source fingerprint `51414f3f7e6bd8431dcce6395ada4c21b14352a75dea125f92712e86450e13b3`, for the color refresh and rename. It adds `PaletteContrastTests`, a dark environment for every parameterized screen test, and `everyScreenDrawsInBothAppearances`, which draws 16 screens in light and dark. `./Scripts/sim.sh matrix` now captures dark as a sixth environment.

## Coverage

Domain tests cover:

- Adaptive and fixed starts
- Stale cadence and timeout tokens
- Paused-time exclusion
- Resume reacquisition with cadence prior
- Permission fallback
- Route loss and explicit resume
- Each recovery naming its own cause, an immediate retry after a playback failure, and ending the run from any recovery even if the route never returns
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
- One Auto feedback transaction per meaningful change, with a verified start, a verified arrival, and no cue for raw or filtered cadence, an unsettled candidate, an intermediate ramp reply, a pending, mismatched, rejected, or stale reply, a reaffirmed target, a transport tap, or an old song
- Replacement, manual takeover, a lost Auto target, route loss, interruption, playback failure, finish, pause, and recovery each producing the intended cancel, preserve, or forget result, with no cue replayed after recovery
- One selection tick for an accepted Previous or Next request and one soft impact when Finish arms
- Song-change causes for an explicit Previous or Next, a natural end inside the 10-second window, and an outside change
- Boundary look-ahead inside the last 45 seconds of a song: a queued song that fits stays, an unfit queued song with a fit available is replaced once and the choice is kept, an unfit queued song with no fit proceeds with the state saying so, the window is respected, the queue anchor stays on the song that was playing when a prepared song arrives, and an explicit Skip drops the plan (`RunReducerBoundaryLookAheadTests`)
- The reach rule: a mostly-faster collection is named once after twenty held seconds and never again, the slower direction gets its own single notice, a reachable collection never speaks, Manual takeover pauses the count, and the direction follows the unreachable majority (`RunReducerReachTests`)

Design tests cover clockwise and counterclockwise one-BPM detents, partial-turn accumulation, reverse hysteresis, direction reversal, angle wraparound, multiple revolutions, reset between gestures, exactly 30 BPM per revolution, and readiness feedback only for a genuine transition to a newly runnable import.

Audio tests cover the simulated player's scripted events: a natural boundary, an external boundary, an interruption, an interruption end, and a same-song callback, each guarded by the current operation identity so a stale call cannot fire one.

Motion tests cover:

- The simulation and production provider boundary
- Five-observation stable lock
- Three-observation resume lock with the prior estimate as a smoothing seed
- Purposeful walking acquisition, below-range rejection, broken rep-like movement, isolated spikes, and sustained missing cadence
- A scripted settled-change profile that holds one cadence long enough for Auto to settle, then moves to a second cadence, which is how each Auto feedback size band is driven on demand in Simulator

The Core Motion adapter compiles for a generic iPhone target. A 29-second physical walk produced changing cadence and a 142 SPM average. A privacy-safe replay now covers the exact 2026-08-15 delivery shape: callbacks advance about every 2.56 seconds while most samples are about 2.57 seconds old. Advancing timestamps allow those delayed new samples. Old first samples, repeats, backward timestamps, out-of-order callbacks, unexplained gaps, missing cadence, and values outside the supported range still fail. A second replay covers steady delayed walking samples near 100 SPM. Full placement calibration is not covered by automated tests.

The saved replay was run before the timing change and failed because it never locked. The same replay passed after the new advancing-timestamp rule.

Tempo-analysis tests cover:

- Periodic onset detection at 120, 150, 168, and 190 BPM
- Exact running-pulse agreement within 2 percent
- Alternating accents
- Strong every-third-beat accents reject instead of producing a confident triple-meter error
- Silence and irregular-onset rejection
- Mono and stereo audio-file decoding through the public analysis interface

These generated fixtures validate the module seam. The opt-in `TempoCorpusValidator` adds network evidence against 12 provider-hosted Apple previews whose catalog titles declare tempos from 130 through 180 BPM. Version 5 passed all 12 within 2 percent of the exact declared musical pulse. Lower-pulse, exact-180, silence, irregular-onset, triple-meter, swing, and dotted-eighth regressions remain offline. No preview audio is committed.

The opt-in `TempoProbe` tool takes Apple catalog song identifiers, fetches each preview through the public lookup service, and prints the analyzer's decision, confidence, and strongest tempo candidates. It exists to explain a rejection, not to prove one; it is how the version 5 repair was found and checked. On 2026-08-19 it was run over the 48 songs of one real playlist and the 138 version 4 results cached on the phone: 41 of 48 ready where version 4 had 38, no song lost from the 48, and of the 138 cached answers 132 unchanged, 5 changed, 1 newly rejected. Every changed answer that could be checked against a public BPM listing matched the listing; the newly rejected one had been wrong under version 4.

App-model tests add the run record and the feedback service: the buffer evicting per-second ticks before any story entry when a run outgrows it (oldest tick first, song changes and finish intact, `runDiagnosticsEvictPerSecondTicksBeforeTheStoryOfTheRun`), cue delivery and engine events written as their own entries with transaction identifier, moment, family, sound path, outcome, and detail (`runDiagnosticsRecordCueDeliveryAndEngineEvents`), and the service reporting every outcome through a fake player factory: played through the engine, local sound only, engine unavailable, pattern missing, a start the engine refused, and an arrival cancelled while held (`autoFeedbackServiceRecordsWhatBecameOfEveryCue`, `autoFeedbackServiceForwardsEngineEvents`).

Run them with:

~~~sh
swift test --package-path Packages/SamadhiKit --filter "BoundaryLookAhead|Reach"
xcodebuild test -project Samadhi.xcodeproj -scheme Samadhi \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -only-testing:SamadhiTests -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
~~~

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
- The rebuilt transport bar and armed Finish control captured in five environments: normal, accessibility XXXL, Reduce Motion, Increased Contrast, and Reduced Transparency
- The out-of-reach line from the `-SAMADHI_OUT_OF_REACH=faster` scripted walk, appearing once, leaving on its own, and not returning, in default, Reduce Motion, Increase Contrast, and accessibility L environments, plus the slower direction; and the Debug screen's `Next song` row and cue delivery section
- An early Finish release that resets the fill with no animation, followed by a full hold that completes the run
- A recorded pressed state for each transport region and for the whole hold, used to pull key frames at 30 fps

App-model tests cover ready mapping, start transition, atomic store round trips, corrupt persistence, restored selection, cancellation of stale replacement work, complete typed import presentation, ordered three-track import batches, retry of the same playlist, retry after relaunch, distinct authorization and import failures, playlist context for missing or empty imports, current selection during replacement, deterministic empty, compact, 40-playlist, long-name, and selected-loading fixtures, schema-version-10 rolling run diagnostics, Auto cue and same-song-callback diagnostic entries, unfinished-run survival, a reducer-driven diagnostic timeline through finish, hidden Debug calculations, private launch-argument redaction, immediate Simulator demo readiness, replacement with a second local playlist, and the catalog tie rule.

App-model and demo fixtures take their analysis version from `LocalTempoAnalyzer.analysisVersion`, so a version bump re-imports stale stored analyses in the product and the tests follow it. App-model tests cover the catalog tie rule: an explicit and a clean edit resolve to the library track's own rating, an unknown library rating prefers the explicit edit, a candidate outside the half-second tie window loses to the closer duration, tied unrated candidates choose deterministically regardless of input order, and nothing within three seconds means no match. The MusicKit wiring of that rule, including the catalog identifier read from play parameters, is read by hand and proved only by a phone import.

App-model tests also cover the packaged Auto feedback prototypes. Every AHAP file in the bundle parses through `CHHapticPattern(contentsOf:)`. The asset catalog resolves a URL for each family, direction, and size, and for each arrival sound. Each arrival sound's own WAV header is read back from the bundle and must report 48000 Hz, one channel, 16 bits, and a duration inside 0.18 to 0.45 seconds. The feedback service plays each moment of a transaction once, holds an arrival that would land on top of its own start, clears pending arrivals on `cancelAll`, and stops only the named transaction on `cancel(transactionID:)`.

## Visual proof

The current interface is on one sheet at `Evidence/Simulator/2026-11-02-design-refresh/`. Launch arguments for Reduce Motion and Increased Contrast did not reach the app's design overrides before 2026-11-02, and a Reduce Motion capture showed animation still running, so older frames labeled with those two environments are not proof of them.

The July setup-craft contact sheet, now only in Git history, was `Evidence/Simulator/2026-07-27-setup-craft-contact-sheet.jpg`. Its 17 fresh iPhone 17 Pro frames cover empty setup; normal, compact, empty, current-selection, and scrolled 40-playlist picker states; loading with and without an existing selection; exact `2 / 8` analysis; partial and complete readiness; full skipped-results disclosure; temporary retry placement; import and authorization failures; a long name; accessibility XXXL; and Reduce Motion.

Two captured visual passes were inspected at original resolution. Pass one exposed low skipped-disclosure contrast and overlapping status/action content during the readiness handoff. Pass two raised disclosure contrast and changed the handoff to a 100-millisecond exit, 10-millisecond seam, and 100-millisecond entry. The normal and Reduce Motion review videos remain under `Evidence/Temp/setup-pass3/`. The normal sequence has no simultaneous old and new labels; the reduced sequence replaces the stage immediately with no positional travel.

The accessibility UI test uses the system `UICTContentSizeCategoryAccessibilityXXXL` launch value and proves the primary control is wider than 75 percent of the window. The final frame keeps the wrapped playlist identity above readiness, full-width Start, and Change playlist.

Earlier released frames, kept in the [evidence archive](https://github.com/samay58/samadhi/releases/tag/evidence-archive-2026-08-19), cover locked run, controls, summary, Home Screen icon, BPM Auto fine-tune, the Manual safety limit, accessibility-size BPM controls, the resting `Turn` affordance, the prior rotary BPM click wheel, and normal local-demo readiness. Evidence/Previews/ covers other accessibility and state-specific visual checks.

The 2026-07-23 runtime review launched the normal app on iPhone 17 Simulator and inspected the ready and active-run screens. The focused rotary UI test made four strong clockwise turns, reached a requested target above 188 BPM, settled simulated Music BPM at the truthful 185 BPM boundary within two seconds, kept the same song, and never showed `Changing song`.

The glass-circle transport that replaced the capsule bar on 2026-08-19 is described in `Evidence/Simulator/2026-08-19-transport-glass/`, whose frames are now only in Git history: normal, paused, accessibility XXXL, Reduce Motion, Increased Contrast, Reduced Transparency, armed, and early-release frames, each opened and read. The earlier capsule-bar rebuild is recorded in `Evidence/Simulator/2026-08-18-transport-finish/`. Its 39 images, each opened and read at original size, are in the [evidence archive](https://github.com/samay58/samadhi/releases/tag/evidence-archive-2026-08-19). The before frames show the three floating pills and both overflow causes on a 30 fps contact sheet: two capsule borders and two labels visible at once for about eight frames, then a second capsule edge offset below and left of the pressed pill. The after frames cover the capsule bar and the armed Finish control at normal size, accessibility XXXL, Reduce Motion, Increased Contrast, and Reduced Transparency, plus pressed key frames for each transport region and a 54-frame contact sheet of the hold from arming through cancel, completion, and handoff. No fill edge crosses the border in any after frame. Both bar variants are kept, so the rejected divided bar stays inspectable. Press feel, haptic character, and daylight legibility are physical and are not shown here. The Increased Contrast frame was captured with `simctl ui increase_contrast enabled`, because the launch argument alone did not reach `colorSchemeContrast` on this runtime.

The Auto feedback prototype record lives in `Evidence/Audio/2026-08-18-auto-feedback-prototypes/`. It holds the sound manifest with parameters and checksums, a stacked waveform sheet for all six arrival sounds, the audition screenshot, and the Release isolation counts.

## Truth boundary

Simulator verifies interaction, accessibility structure, reducer behavior, resource packaging, and deterministic motion. Normal Debug Simulator launches use two local placeholder playlists, simulated cadence, and silent simulated playback. This path is disabled on physical devices and in Release builds. Simulator cannot validate physical cadence quality, real headphone route behavior, audible tempo adaptation, listening artifacts, or the tactile character of haptics.

Release isolation is checked by reading the built binaries, and the Debug side needs care. A Debug build keeps its code in `Samadhi.app/Samadhi.debug.dylib`; `Samadhi.app/Samadhi` is a small launcher stub that reports zero matches for everything, including code that is certainly present. A grep against that stub passes without proving anything. Read the dylib for the Debug side and `Samadhi.app/Samadhi` for Release, and keep a known-present control string in the comparison.

The `Samadhi MusicKit Gate` scheme verifies that the harness and framework calls compile. Physical traces separately prove authorization, library loading, automatic token generation, strict catalog resolution, preview decoding, playback, mechanical rate writes, pause, and resume. Bluetooth listening, background, controlled interruption, and route checks remain separate physical gates.

## Felt-synchronization gate

Use five analyzed songs with prominent, stable beats. Compare 0.92, 1.00, and 1.08 on the supported Bluetooth route, then test 0.90 and 1.10 only if the first endpoints remain clean. Log requested rate, MusicKit read-back, route, audible artifacts, and blinded faster-or-slower recognition. Pass only if Samay identifies direction in at least four of five comparisons and calls the largest clean pair obvious rather than subtle.

The complete sequence, pivot rules, phase questions, and final evidence packet live in [FELT-SYNCHRONIZATION-EXECUTION-SPEC.md](Archive/FELT-SYNCHRONIZATION-EXECUTION-SPEC.md).

The current candidate adds a deterministic dirty-source fingerprint, safe replay of the delayed phone pattern, and a separate settled Auto target. Target tests cover 90, 100, and 110 SPM walking acquisition; 120, 130, 140, and 160 SPM running acquisition; ordinary noise; one spike; sustained faster and slower rhythms; walk-to-jog and jog-to-walk changes; missing readings; broken lifting-like values; and time-based behavior at the saved phone callback interval. The close-control tests verify a 44-point hit area outside the dial, clean dismissal, no run-state mutation, accessibility XXXL, Reduce Motion, and Increased Contrast. Fresh frames live under `Evidence/Simulator/2026-08-17-auto-target-close/`.

The final walking candidate passed 152 package tests, 27 app-model tests, and 28 serial UI tests. Resource-inclusive Debug and Release Simulator builds passed, and the hidden Debug interface was absent from Release. The exact-profile app recorded source fingerprint `9137f9db705f06e69d358178d56c090c9ff05f54cd9aa7109c37d3d32e03748b` and was installed in place. The selected collection checksum stayed `81a9b31fbc115d607bc766dd25374ecff6874b079276b68c3719cb122cea3f52`. A clean walking and listening check remains.

The later expanded-rate candidate passed 153 package tests, 27 app-model tests, 28 serial UI tests, source-fingerprint tests, and resource-inclusive Debug and Release Simulator builds. The hidden Debug interface remained absent from Release. Its exact-profile phone build records source fingerprint `fd8120ad2ac14e1090a687438e6564beb65bde0a61d58fab04d4ec7295535684`. It was installed in place, and the selected collection checksum stayed `81a9b31fbc115d607bc766dd25374ecff6874b079276b68c3719cb122cea3f52`. The phone locked before launch. In-app identity, 0.85 and 1.15 read-back, and listening remain open.

The software half of the Auto feedback gate now exists: a reducer-owned transaction, an app-shell service, three prototype families, and a Debug audition screen. The rest of that gate is physical. It must test faster and slower recognition, three coarse size levels, cue fatigue, screen lock, engine interruption and reset, iPhone speaker, primary Bluetooth headphones, first-play delay, Apple Music ducking or gaps, route changes, and sound-disabled and haptic-disabled fallbacks. Use the acceptance test in `Docs/AUTO-CHANGE-INTERACTION-SPEC.md`. Simulator can verify reducer triggers and asset packaging only.

The focused Simulator UI flow proves that Manual remains active before a requested song change and returns to Auto only after the player confirms a different song. It also proves that the explicit close action restores playback controls, including with accessibility XXXL text and Reduce Motion. Frames live under `Evidence/Simulator/2026-08-15-manual-close/`.

The phone baseline and pulled diagnostic live under `Evidence/Device/2026-08-15-core-reset/`. The later fingerprinted workout summary lives under `Evidence/Device/2026-08-17-auto-target/`. It confirms source identity, repaired acquisition, and one exact Apple Music reply. Samay also confirmed that Auto was audible but felt jarring and unexplained. Haptic feel, locked-screen cue delivery, known-cause natural transition behavior, broader listening quality, and sustained running feel remain open.

## Known environment behavior

The iOS 27 Simulator can terminate concurrent UI test runners, so the suite runs serially. Running Simulator commands under a second Xcode version while tests run restarts the shared Simulator service and kills the run.
