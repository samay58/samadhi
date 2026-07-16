# Current status

## At a glance

| Area | State | Evidence |
| --- | --- | --- |
| Product interaction | Complete prototype | Golden UI flow |
| Visual system | Complete prototype | Final Simulator frames |
| Accessibility | Covered in prototype | Dynamic Type, Reduce Motion, contrast, VoiceOver behavior |
| State architecture | Complete for prototype | Pure reducer tests |
| Cadence | Core Motion connected; brief physical observation passed | Deterministic filter tests and 29-second iPhone walk |
| Audio timing | Real for imported ready tracks; deterministic in fixtures | Production player contract and beat-clock tests |
| Playlist import | Implemented; physical playlist result open | Import model tests and Simulator states |
| Tempo analysis | Version 2 passes a narrow 12-preview real-music corpus | Generated regression tests and opt-in Apple preview validation |
| Adaptation policy | Physical automatic rate-response check passed | Identified reducer effects, deterministic feedback tests, and 59-second device result |
| Apple Music feasibility | Source selected; Bluetooth route and rate writes passed; long-form reliability deferred | Exact-profile traces and explicit product decision |
| Spotify feasibility | Rejected for adaptive playback | Remote-control architecture, missing music rate control, and content policy conflict |
| Production player | Apple Music selected; imported ready tracks enter the real player | Source-neutral contract, exact-profile build, and device install |
| Physical run validation | Source feasibility complete; outdoor run not started | Requires tempo, cadence, adaptation, and route evidence |

## Completed

### Foundation

- Reproducible XcodeGen project targeting iOS 26
- Local Swift package separating domain, motion, audio timing, and design
- Pure run reducer with explicit events, effects, cancellation, and recovery
- Serial Xcode test gate for current beta Simulator behavior

### Interaction

- Ready, preparing, acquiring, locked, controls, paused, resumed, finish hold, summary, permission recovery, and audio-route recovery
- Song progress linked to outer ring
- Tempo aperture linked to simulated cadence
- Controls hidden until requested
- Explicit resume after route loss
- Fixed-rhythm fallback after denied motion access

### Design and brand

- Full-screen fluid field replaced square cover treatment
- Passive white cards removed
- Open type hierarchy and native raised controls established
- Samadhi name, icon, tagline, project, scheme, package, tests, and repository aligned
- GitHub cover and app icon installed

### Cleanup

- Removed empty diagnostics module
- Split 633-line screen into focused screen and control types
- Split domain models from reducer
- Moved task cancellation bookkeeping into dedicated task store
- Replaced hard-coded three-track navigation with configured collection size
- Added formatter config and clean lint gate
- Added newcomer guidance at load-bearing architectural and interaction seams
- Removed stale pre-final evidence, rejected cover exports, completed-generation prompts, and superseded build handoff

### Milestone 2 groundwork

- Inspected Xcode 27, iOS 27 SDK interfaces, signing, connected devices, and current project capabilities
- Configured Apple team `ZL5U59XBJ6`, registered the explicit App ID, and received user confirmation that the MusicKit App Service is enabled
- Built, signed, installed, and launched the gate harness on a physical iPhone 17 Pro with Developer Mode enabled
- Added source-neutral collection, track, tempo, cadence, progress, adaptation, and tempo-measurement models
- Added bounded adaptation with half and double tempo normalization, ramp limits, deadband, update interval, confidence hold, and calm return to normal speed
- Added cadence-provider events, deterministic cadence filtering, and a Core Motion provider that compiles for iPhone
- Renamed the summary measurement to tempo matched and made fixed rhythm report Not measured
- Added a debug-only MusicKit gate scheme with playlist loading, decoded PCM preview coverage, playback, rate controls, route and interruption observation, and JSON trace export
- Added music and motion permission text plus verified background audio mode
- Saved five early physical-device traces proving authorization, 40-playlist loading, real playback, live 0.94, 1.00, and 1.06 rate writes, pause, and resume
- Used the early traces to isolate two blockers: library tracks had no direct previews or ISRC, and the wildcard profile could not obtain Apple's automatic developer token
- Evaluated Spotify and rejected it as a production source because it does not provide an app-owned audio signal or documented music rate control, and its policy prohibits altering or analyzing Spotify content
- Added a source-resolution spec with explicit token, tempo-source, listening, background, and fallback gates
- Installed exact profile `Samadhi Development` and verified the signed application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`
- Passed automatic developer-token generation with repeated direct catalog responses
- Added strict title, artist, album, and duration catalog resolution that fails closed on ambiguity and persists the returned numeric catalog ID
- Downloaded remote preview assets into temporary app storage and decoded 10 of 10 City Pocket previews to PCM
- Recorded a clean built-in-speaker listening pass across the safe-rate endpoints; Bluetooth listening remains required
- Reached Beoplay Eleven over Bluetooth A2DP and applied 0.94, 1.00, and 1.06 during real playback
- Selected Apple Music as the one production source after Samay explicitly deferred further repetitive manual drills
- Added a source-neutral production player contract, deterministic player, Apple Music adapter, and identified progress and recovery events
- Added a dedicated `Samadhi Apple Music Core Loop` scheme, then replaced its provisional track with a validated tempo fixture
- Added one local audio analysis interface, off-main PCM decoding, a versioned tempo estimator, and generated tempo and rejection fixtures
- Connected the MusicKit harness to report estimated tempo and confidence for resolved previews
- Replaced frame-energy onset detection with Accelerate spectral flux and fractional-lag autocorrelation after real previews exposed a confident triple-meter error
- Added an opt-in 12-track Apple preview corpus with published tempo references; version 2 passed 12 of 12 within the accepted tempo family
- Selected catalog track `1066177773` as the initial verified 170 BPM core-loop fixture
- Connected the focused core-loop scheme to `CoreMotionCadenceProvider` while preserving simulation for normal runs and repeatable tests
- Kept cadence sensing alive after first lock so stable updates, confidence loss, and reacquisition continue through the run
- Made the reducer own adaptation state and emit bounded, identified playback-rate effects
- Required session, operation, request, and track identity before applied-rate feedback can change run state
- Connected honest tempo-matched measurement to the player-reported applied rate instead of assuming every locked second matched
- Launched the focused configuration on the physical iPhone and observed changing Core Motion cadence during a 29-second walk
- Recorded an honest 142 SPM average and 0 percent tempo matched because the initial 170.25 BPM fixture could not safely reach that cadence
- Switched the first follow-up to validated catalog track `1434921088`, estimated at 139.5 BPM, without changing the safe rate range or stability policy
- Recorded no perceptible speed change during that follow-up, leaving automatic rate response unproven
- Removed the adapter's immediate command echo so applied rate now comes from MusicKit read-back
- Added a focused-only diagnostic panel for cadence, target rate, applied rate, and pending feedback
- Switched the objective check to validated catalog track `1558215042`, estimated at 149.75 BPM, which produces a clearer safe ramp around the observed cadence
- Installed and launched the corrected build after the iPhone reconnected
- Completed a 59-second run averaging 155 SPM with 98 percent tempo matched from MusicKit read-back
- Added contextual Apple Music playlist selection using the native library response
- Preserved playlist order while resolving each track strictly to a numeric catalog identity
- Added sequential, cancellation-aware preview analysis with honest ready, unreadable, and unavailable states
- Added versioned tempo caching keyed by track identity, source fingerprint, and analyzer version
- Added atomic selected-collection persistence under Application Support
- Filtered the production queue to adaptive-ready tracks without hiding failed tracks from setup
- Connected restored imported music to `AppleMusicPlaybackController` and `CoreMotionCadenceProvider` in the normal app
- Added deterministic empty, loading, analyzing, partial, authorization-failure, and import-failure states
- Installed and launched the import-capable test build on the physical iPhone

## Proof

The current serial gate passed:

- 48 Swift package tests
- 7 app-model tests
- 8 UI tests
- Swift formatter lint
- Resource-inclusive Simulator build
- Unsigned generic iPhone build
- Signed physical iPhone build with the exact development profile

Durable logs and final visual frames live under Evidence/.

The MusicKit harness and normal app launch in Simulator and on the physical iPhone. Signing uses the Apple Development certificate for team `ZL5U59XBJ6`. The import-capable normal build is installed. Its build and installation record is under `Evidence/Device/`.

## Known limits

Live cadence and automatic cadence-driven rate response pass on the physical iPhone. The completed summary releases transient target and applied values, so future exact diagnostics should be captured during the run or persisted by the focused harness. Built-in-speaker listening found no major pitch change or unpleasant artifacts at the safe-rate endpoints. Bluetooth routing and rate writes pass, but no separate Bluetooth listening note was recorded. The tempo estimator passes its narrow 12-preview reference corpus, but broad music accuracy and public-distribution permission for preview analysis remain open. Import and persistence pass deterministic gates, but one real playlist with at least three ready tracks and relaunch restore is not yet physically proven. Five locked minutes, controlled interruption, next track, route loss, accessibility on imported states, and the outdoor run remain open.

## WHERE WE LEFT OFF

Apple Music is selected. Playlist import, local analysis, persistence, ready-track filtering, and the normal real-player composition are implemented and installed on Samay's iPhone. Automated gates pass. Next, select one moderate real playlist, confirm at least three tracks become ready, relaunch to prove restore, and run those tracks. Long-form reliability checks remain mandatory before Milestone 2 completion.
