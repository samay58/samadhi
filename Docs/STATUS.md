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
| Playlist import | Real selection, 13 ready tracks, restoration, and basic progress passed | Physical ready screen, pulled app-container records, import model tests, and Simulator states |
| Tempo analysis | Version 2 passes a narrow 12-preview real-music corpus | Generated regression tests and opt-in Apple preview validation |
| Adaptation policy | Physical automatic rate-response check passed | Identified reducer effects, deterministic feedback tests, and 59-second device result |
| Track fit | Connected to run start and next-song planning | Deterministic pulse-family, envelope, hold, identity, order, and retention tests |
| In-run BPM control | 40-BPM aperture click wheel implemented and Simulator-verified | One revolution, visible detents, Auto and Manual ownership, honest fit feedback, accessibility, and UI tests |
| Simulator development loop | Local placeholder playlists and silent simulated playback available in Debug | Normal no-argument launch, model tests, UI flow, screenshot, and interaction recording |
| Apple Music feasibility | Source selected; 0.90 versus 1.10 was clearly audible on one Bluetooth track; broader quality and long-form reliability remain | Exact-profile traces and explicit product decision |
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
- Pulled the physical app container and verified one real 25-track playlist produced 13 ready, 8 unreadable, and 4 unavailable tracks
- Added debug-only latest-run diagnostics so progress, cadence, target and applied rates, track changes, recovery events, and summary survive finish for direct device retrieval
- Built, signed, and installed the diagnostics-capable app while preserving the selected playlist byte-for-byte; foreground launch remains blocked by the locked phone
- Added one in-run rhythm control with Auto fine-tune from minus 8 through plus 8 BPM, Manual targets from 120 through 200 BPM, and one-step return to neutral Auto
- Kept safe rate bounds, ramping, deadband, confidence handling, track compatibility, identified player feedback, and honest summary measurement authoritative in the reducer
- Added explicit `At limit` feedback when the current track cannot safely reach the requested BPM
- Extended latest-run diagnostics with control mode, correction or Manual target, requested BPM, derived rate, MusicKit read-back, and limit state
- Resolved the control as direct manipulation of the existing tempo aperture with large touch targets, restrained haptics, VoiceOver adjustment, Dynamic Type, increased contrast, and Reduce Motion support
- Reviewed final Auto fine-tune, Manual safety-limit, and accessibility-size frames in the iPhone 17 Pro Simulator without changing the wider visual system
- Added a debug-only blinded 0.92 versus 1.08 comparison that captures rate read-back and direction recognition with optional 0.90 and 1.10 endpoint controls
- Started adaptive runs on the ready song whose half-time, full-time, or double-time pulse requires the least safe correction, using 168 BPM only as an initial prior
- Kept song identity and count authoritative to real player callbacks instead of predicting the result of Previous or Skip
- Added a five-second mismatch hold that prepares a better-fitting next song while allowing the current song to finish naturally
- Protected next-song preparation with selection identity so late preparation cannot replace a newer choice
- Turned the pulsing aperture into the single rotary BPM click wheel with one-BPM angular detents, soft takeover, restrained haptics, a temporary perimeter marker, and VoiceOver adjustment
- Removed separate plus and minus controls after visual review because they weakened the single-instrument interaction
- Added a Debug Simulator-only local music path with two placeholder playlists so the normal app flow no longer depends on unavailable Simulator MusicKit state
- Anchored rotary movement to finger-down, kept the automatic range fixed through a gesture, protected the center, and emitted one state change plus one selection haptic per crossed BPM detent
- Reused prepared haptic generators so the first click is not weakened by generator startup
- Expanded Auto to a 40-BPM window around measured cadence, capped all requested targets at 120 through 210, and mapped one complete revolution to that 40-BPM span
- Added 40 restrained visual detents plus low-sharpness Core Haptics feedback, with a fuller notch every five BPM and a soft Auto landing
- Replaced the tuning sentence with one integrated `Turn` label, three resting grip notches, and one Reduce-Motion-aware teaching movement that retires after first use

## Proof

The current serial gate passed on 2026-07-21:

- 83 Swift package tests
- 11 app-model tests
- 10 UI tests
- Swift formatter lint
- Resource-inclusive Simulator build
- Unsigned generic iPhone build
- Signed generic iPhone build with the exact development profile

Durable logs and final visual frames live under Evidence/.

The diagnostics slice passes formatter lint, a Simulator build, the full serial gate, an exact-profile physical build, physical installation, and foreground launch.

The production track-fit and rotary-control slice passes formatter lint, 83 package tests, 11 app-model tests, 10 UI tests, and an exact-profile signed iPhone build. Commit `c8e195e` was installed and launched over the local network on the restored iPhone on 2026-07-22. A direct device capture confirmed the normal setup screen rendered cleanly.

The MusicKit harness and normal app launch in Simulator and on the physical iPhone. Signing uses the Apple Development certificate for team `ZL5U59XBJ6`. The import-capable normal build is installed. Its build and installation record is under `Evidence/Device/`.

## Known limits

Live cadence and automatic cadence-driven rate response pass mechanically on the physical iPhone. One Bluetooth track made 0.90 versus 1.10 unmistakable, but broader and full-song listening quality remains open, so production stays at 0.94 through 1.06. Production selection now starts on the best ready fit and prepares a better next fit only after five seconds of stable mismatch. The aperture click wheel exposes a 40-BPM Auto window without weakening the reducer's audio limits. Its geometry, direction, running bounds, protected center, state ownership, progressive three-to-40-detent affordance, and event-to-haptic contract pass in Simulator and deterministic tests. Simulator cannot prove whether the low-sharpness minor detents, five-BPM landmarks, and soft Auto landing feel warm or tiring, so one short tactile check remains. Player callbacks remain authoritative for song identity. Debug builds persist the latest completed run's exact control, progress, cadence, target and applied rates, track changes, recovery events, and summary. The tempo estimator passes its narrow 12-preview reference corpus, but broad music accuracy and public-distribution permission for preview analysis remain open. One real playlist passed import, local analysis, reinstall and relaunch restoration, and basic production-player progress with 13 ready tracks. The public MusicKit queue preparation seam compiles and is deterministic in the simulated player, but one natural imported-song transition is still not physically proven. Five locked minutes, controlled interruption, route loss, accessibility on imported states, and the outdoor run remain open.

## WHERE WE LEFT OFF

Apple Music remains the authoritative Milestone 2 player. Before the device restore, a real 25-track playlist restored with 13 ready tracks, production-player progress advanced, and Samay clearly heard 0.90 versus 1.10 on `LITE SPOTS` through Beoplay Eleven. The device restore cleared the app's local selection, and the current exact-profile build now opens at `Choose music`. The normal-run envelope remains 0.94 through 1.06 until broader quality is proven. Coarse track fit is connected to adaptive run start and identified next-song preparation. The tempo aperture is the rotary click wheel with a 40-BPM Auto window and full 120 through 210 Manual range. The next physical proof is to select one playlist again, run from its ready tracks, cross a natural prepared transition, and judge whether the rounded detents and five-BPM landmarks feel satisfying. After that come phase investigation, locked playback, recovery, and the outdoor run.
