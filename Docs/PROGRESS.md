# Progress

## 2026-07-15. Foundation

- Created iOS 26 app, local Swift package, XcodeGen project, tests, previews, and evidence structure
- Established pure reducer and simulated cadence and beat timing
- Proved full interaction and recovery flow in Simulator

## 2026-07-15. Design refinement

- Replaced square artwork with full-screen native fluid field
- Removed passive white cards
- Enlarged tempo aperture and linked outer ring to song progress
- Kept one motion owner and reduced field update cadence
- Verified large Dynamic Type, Reduce Motion, contrast, and missing artwork

## 2026-07-15. Identity

- Renamed product, target, scheme, package, tests, bundle, docs, repository, and local handoff to Samadhi
- Installed refined app icon
- Added Midjourney repository cover with “music in stride” outside ribbon loop
- Pushed tested prototype to GitHub main

## 2026-07-15. Cleanup

- Removed empty diagnostics module
- Split design and domain monoliths into focused types
- Isolated async task lifecycle
- Configured track count from active collection
- Added track wraparound test
- Added reproducible Swift formatter gate
- Consolidated docs around product, status, plan, architecture, proof, and progress
- Removed stale evidence, rejected exports, completed prompts, and superseded handoff
- Passed 15 package tests, 2 app-model tests, and 4 UI tests after cleanup

## 2026-07-15. Code navigation

- Added sparse plain-English guidance at the state, effect, task, accessibility, motion, and screen-routing seams
- Recorded the comment standard in repository instructions so later work stays readable without becoming noisy
- Re-ran formatter, 15 package tests, 2 app-model tests, and 4 UI tests

## 2026-07-15. Milestone 2 specification

- Specified playlist import, real cadence, tempo analysis, adaptive playback, background continuity, recovery, and physical proof
- Chose import before generation and one production player after an Apple Music feasibility gate
- Corrected the measurement boundary from implied footfall phase to honest tempo matching
- Updated active product, plan, architecture, decisions, status, and repository guide

## 2026-07-15. Milestone 2 safe groundwork

- Inspected the actual Xcode 27 SDK, signing state, connected-device list, and project capabilities
- Found no connected physical iPhone and no configured Apple development team, so the Apple Music gate remains open
- Added source-neutral music, tempo, cadence, progress, adaptation, and honest measurement models
- Added deterministic adaptation tests for normalization, bounds, ramping, deadband, confidence loss, incompatible tracks, and match timing
- Added a cadence-provider boundary, deterministic filter, Core Motion adapter, and motion tests
- Renamed the summary measurement to tempo matched and made fixed rhythm report Not measured
- Added music and motion permission text and verified background audio configuration
- Added the source-controlled `Samadhi MusicKit Gate` scheme and debug harness with JSON evidence export
- Passed Simulator and unsigned generic iPhone builds; recorded the exact physical and signing blocker
- Passed formatter, 29 package tests, 2 app-model tests, and 4 UI tests on the final tree

## 2026-07-15. Physical MusicKit gate opened

- Registered the explicit `com.samaydhawan.Samadhi` App ID and received user confirmation that its MusicKit App Service is enabled
- Saved Apple team `ZL5U59XBJ6` in `project.yml` and regenerated the Xcode project
- Confirmed signed generic and physical iPhone builds with the Apple Development certificate
- Confirmed Samay's physical iPhone 17 Pro on iOS 27.0 with Developer Mode enabled
- Installed and launched the `Samadhi MusicKit Gate` harness on the physical phone
- Left the source decision open pending authorization, playlist, decoded-preview, playback, listening, background, interruption, and route evidence

## 2026-07-15. Physical MusicKit traces

- Saved five JSON traces from the iPhone with checksums and a durable evidence analysis
- Passed contextual Music authorization, 40-playlist loading, real playback, live 0.94, 1.00, and 1.06 rate writes, pause, and resume
- Observed 0 of 10 direct-library preview coverage across every tested sample
- Added one focused ISRC-based catalog-resolution check because the installed SDK supports catalog lookup and catalog songs may carry previews absent from library tracks
- Built, signed, installed, and launched the retry harness on the same physical iPhone
- Found no ISRC on 40 sampled tracks and added the SDK's equivalent-ID lookup as the final documented catalog path
- Pulled the live trace directly from the phone and matched it byte-for-byte to the user export
- Recorded 40 `.developerTokenRequestFailed` results, leaving catalog preview feasibility honestly blocked rather than passed or failed

## 2026-07-15. Music source resolution

- At that checkpoint, verified Apple Music automatic-token configuration requirements and the meaning of `developerTokenRequestFailed`
- At that checkpoint, found only the Xcode-managed wildcard `ZL5U59XBJ6.*`; the exact Samadhi profile was installed the following day
- Limited remediation to one clean build signed with a fresh exact-App-ID development profile
- Rejected embedded private keys, committed tokens, and a Samadhi token backend
- Evaluated Spotify's current iOS SDK, player surface, development-mode rules, and Developer Policy
- Rejected Spotify as an adaptive player because it cannot provide the required app-owned, analyzable, rate-controlled audio path
- Specified token, tempo-source, listening, background, recovery, and local-file fallback gates in `MUSIC-SOURCE-RESOLUTION-SPEC.md`

## 2026-07-16. Apple token and preview gates

- Installed and verified the exact `Samadhi Development` profile and signed identifier
- Passed automatic token generation with repeated direct catalog responses
- Added a focused launch-argument token probe to the debug-only harness
- Rejected nonnumeric library IDs as equivalent-ID inputs and added strict title, artist, album, and duration catalog resolution
- Downloaded remote catalog previews to temporary app storage before local decoding
- Passed strict catalog identity and decoded PCM coverage at 10 of 10 City Pocket tracks
- Recorded a clean built-in-speaker listening result with no major pitch change or unpleasant artifacts at the safe-rate endpoints
- Saved the user export and byte-matched device trace under `Evidence/Device/`
- Passed the full serial test gate, rebuilt with the exact profile, and installed the final harness build on the physical iPhone
- Left headphone listening, background, track change, controlled interruption, and route loss honestly open

## 2026-07-16. Production player selected

- Reached Beoplay Eleven through Bluetooth A2DP and applied 0.94, 1.00, and 1.06 during real playback
- Stopped the repetitive manual trace loop after Samay explicitly deferred the remaining drills
- Selected Apple Music as the one production source while keeping long-form reliability checks open
- Added a source-neutral player contract, deterministic player, Apple Music adapter, and identified progress and recovery events
- Added a focused Apple Music core-loop scheme around one real catalog track
- Preserved the normal deterministic app flow until playlist import is ready
- Passed formatting, 32 package tests, 2 app-model tests, and 4 UI tests on the implementation tree

## 2026-07-16. Tempo-analysis seam

- Added one local audio-file analysis interface for Apple Music previews and future imported files
- Moved PCM decoding off the main actor and reduced multichannel audio to mono
- Added a versioned onset and autocorrelation estimator
- Added generated 120, 150, 168, and 190 BPM fixtures plus silence and irregular-onset rejection
- Connected the MusicKit harness to record estimated BPM, confidence, and analysis version
- Kept real-music accuracy and the twelve-excerpt corpus explicitly open
- Passed formatting, 37 package tests, 2 app-model tests, 4 UI tests, and the exact-profile physical iPhone build

## 2026-07-16. Real-preview tempo validation

- Built an opt-in 12-track Apple preview corpus using catalog titles that declare tempos from 130 through 180 BPM
- Found that analyzer version 1 passed 11 of 12 but confidently labelled one 180 BPM mix as 60 BPM
- Replaced frame-energy onset detection with Accelerate spectral flux and fractional-lag autocorrelation
- Added a public-seam regression for the triple-meter failure and conservative rejection when the correct tempo family lacks support
- Passed 12 of 12 real previews within 2 percent of the published tempo or its half or double
- Selected catalog track `1066177773` as the verified 170 BPM core-loop fixture
- Kept provider-hosted audio temporary and stored only the corpus manifest, JSON result, checksum, and analysis
- Passed formatting, 38 package tests, 2 app-model tests, 4 UI tests, and the exact-profile physical iPhone build

## 2026-07-16. Body-to-music core loop

- Connected the verified 170 BPM Apple Music fixture to Core Motion cadence in the focused core-loop scheme
- Kept normal runs and previews on deterministic simulation
- Continued cadence sensing after first lock so stable changes and confidence loss remain observable
- Made the reducer own adaptation state and emit bounded rate effects through `MusicPlaybackProviding`
- Added session, operation, rate-request, and track identity to applied-rate feedback
- Connected tempo-matched measurement to the player-reported applied rate
- Added deterministic coverage for stable cadence, rate feedback, confidence loss, stale callbacks, provider failure, and replacement sessions
- Passed formatting, 43 package tests, 2 app-model tests, 4 UI tests, an unsigned iPhone build, and the exact-profile physical build
- Installed the body-to-music-capable app build on Samay's iPhone; focused scheme launch remained blocked because the phone was locked, and direct icon launch remains the normal simulation

## 2026-07-16. Physical cadence seam

- Launched the focused configuration with its required device argument
- Observed changing Core Motion cadence during a 29-second physical walk and recorded a 142 SPM average
- Confirmed the 0 percent tempo-matched summary was honest because 142 SPM is outside the original 170.25 BPM fixture's safe rate range
- Replaced the focused fixture with validated catalog track `1434921088`, estimated at 139.5 BPM, so the next short walk can exercise automatic rate response without weakening safety limits

## 2026-07-16. Objective rate diagnostics

- Recorded no perceptible speed change during the 139.5 BPM follow-up
- Found that the Apple Music adapter immediately echoed its commanded rate as applied instead of reading MusicKit state back
- Changed applied-rate feedback to carry MusicKit's observed playback rate with the original request and track identities
- Added a focused-only panel showing cadence, target rate, applied rate, and pending feedback
- Selected validated catalog track `1558215042`, estimated at 149.75 BPM, for a clearer bounded ramp around the observed 142 SPM cadence
- Added a deterministic regression covering the expected 1.00, 0.98, 0.96, and target-rate sequence
- Passed 44 package tests, 2 app-model tests, 4 UI tests, formatter lint, documentation links, and the exact-profile iPhone build
- Left physical installation open because the iPhone became unavailable to Xcode

## 2026-07-16. Automatic rate response

- Installed and launched the corrected build after the iPhone reconnected
- Completed a 59-second focused run with a 155 SPM average, one song, and 98 percent tempo matched
- Confirmed the result depends on MusicKit read-back; a fixed 1.00 rate on the 149.75 BPM fixture cannot satisfy the three-SPM match tolerance at the observed cadence
- Saved the user-supplied completed-run frame with a checksum and confirmed direct device capture is available for future live checks
- Closed the automatic rate-response gate

## Current checkpoint

Milestones 0 and 1 are complete. Apple Music is the selected Milestone 2 source. Live Core Motion cadence and automatic MusicKit rate response pass together on the physical iPhone. The narrow 12-preview corpus passes. The normal app remains deterministic until import is connected. Next comes playlist import and persistence, followed by three-track analysis, real progress, and transitions. Long-form background and recovery checks remain before Milestone 2 completion.
