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

## Current checkpoint

Milestones 0 and 1 are complete. Apple Music is the selected Milestone 2 source. The production player boundary and adapter are built, while the normal app remains deterministic until import is connected. Next comes one verified-tempo catalog track through the adapter, real Core Motion cadence, and bounded adaptation. Bluetooth listening notes and long-form background and recovery checks remain before Milestone 2 completion.
