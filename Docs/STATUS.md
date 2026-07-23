# Current status

## At a glance

| Area | State | Evidence |
| --- | --- | --- |
| Product interaction | Complete prototype | Golden UI flow |
| Visual system | Complete prototype | Final Simulator frames |
| Accessibility | Covered in prototype | Dynamic Type, Reduce Motion, contrast, VoiceOver behavior |
| State architecture | Complete for prototype | Pure reducer tests |
| Cadence | Core Motion connected; stale and invalid samples now force reacquisition | Deterministic freshness, filter, and 29-second iPhone walk evidence |
| Audio timing | Real for imported ready tracks; deterministic in fixtures | Production player contract and beat-clock tests |
| Playlist import | Complete results, typed failures, retry, and bounded analysis implemented | Full-list Simulator proof, import timing diagnostics, model tests, and prior physical collection evidence |
| Tempo analysis | Version 4 keeps measured musical pulse separate from an independently supported stride pulse; the public corpus passes 12 of 12 | Generated regressions, private playlist replay, and opt-in Apple preview validation |
| Adaptation policy | Manual commits apply directly; Auto settles across the proven range in about five seconds; an unreachable request uses the nearest honest rate | Identified effects, MusicKit read-back, boundary behavior, and deterministic replay tests |
| Track fit | Connected to run start and next-song preparation without hidden transport changes | Deterministic pulse, envelope, coalescing, identity, order, and retention tests |
| In-run BPM control | The wheel stays pinned during a turn, previews detents, then commits one absolute Manual BPM at finger-up | Exact-target, compatible-track, read-back, accessibility, and UI tests |
| Simulator development loop | Local placeholder playlists and silent simulated playback available in Debug | Normal no-argument launch, model tests, UI flow, screenshot, and interaction recording |
| Apple Music feasibility | Source selected; 0.90 versus 1.10 was clearly audible on one Bluetooth track; broader quality and long-form reliability remain | Exact-profile traces and explicit product decision |
| Spotify feasibility | Rejected for adaptive playback | Remote-control architecture, missing music rate control, and content policy conflict |
| Production player | Apple Music selected; imported ready tracks enter the real player | Source-neutral contract, exact-profile build, and device install |
| Physical run validation | First field run failed; remediation build installed for a short focused retest | Audible response, directional haptic feel, import timing, reliability, and final outdoor run remain open |

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
- Added bounded adaptation with ramp limits, deadband, update interval, confidence hold, and calm return to normal speed
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
- Kept requested BPM distinct from the nearest achievable Music BPM when one song reaches its rate boundary
- Extended latest-run diagnostics with control mode, correction or Manual target, requested BPM, derived rate, MusicKit read-back, and limit state
- Resolved the control as direct manipulation of the existing tempo aperture with large touch targets, restrained haptics, VoiceOver adjustment, Dynamic Type, increased contrast, and Reduce Motion support
- Reviewed final Auto fine-tune, Manual safety-limit, and accessibility-size frames in the iPhone 17 Pro Simulator without changing the wider visual system
- Added a debug-only blinded 0.92 versus 1.08 comparison that captures rate read-back and direction recognition with optional 0.90 and 1.10 endpoint controls
- Started adaptive runs on the ready song whose measured running-range pulse requires the least safe correction, using 168 BPM only as an initial prior
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
- Replayed the first field failure without committing personal library metadata
- Made every BPM command resolve against requested BPM, achievable BPM, commanded rate, and player read-back without treating incompatibility as a transport command
- Made rapid wheel turns coalesce toward the latest requested target while keeping MusicKit read-back authoritative
- Made compatible large BPM changes prepare only the latest better-fitting track; only Skip or a player-confirmed natural boundary may commit it
- Required at least 80 percent verified measurement coverage before showing a tempo-matched percentage
- Preserved Automatic and Manual seconds in the completed-run diagnostic summary
- Replaced the truncated import result with three calm preview rows plus a complete grouped track sheet
- Preserved distinct rhythm, preview, catalog, download, and decode outcomes and added retry after relaunch
- Limited concurrent import work to three ordered tracks and added private stage timing diagnostics
- Preserved clockwise and counterclockwise direction through stronger ordinary and five-BPM haptic events
- Kept the rhythm control pinned for the full wheel gesture so its timeout cannot hide the surface mid-turn

## Proof

The current serial gate passed on 2026-07-22:

- 102 Swift package tests
- 15 app-model tests
- 10 UI tests
- Swift formatter lint
- Resource-inclusive Simulator build
- Exact-profile physical iPhone build
- Embedded profile and application identifier verification

The repaired build is signed and ready. Samay's paired iPhone was unavailable at the end of this gate, so this specific build was not installed. Earlier physical installations remain recorded below.

Durable logs and final visual frames live under Evidence/.

The diagnostics slice passes formatter lint, a Simulator build, the full serial gate, an exact-profile physical build, physical installation, and foreground launch.

The production track-fit and rotary-control slice passes formatter lint, 83 package tests, 11 app-model tests, 10 UI tests, and an exact-profile signed iPhone build. Commit `c8e195e` was installed and launched over the local network on the restored iPhone on 2026-07-22. A direct device capture confirmed the normal setup screen rendered cleanly.

The MusicKit harness and normal app launch in Simulator and on the physical iPhone. Signing uses the Apple Development certificate for team `ZL5U59XBJ6`. The import-capable normal build is installed. Its build and installation record is under `Evidence/Device/`.

## Known limits

The field report exposed two more defects. Version 3 rejected lower musical pulses because it searched only 120 through 210 BPM, and prepared-track completion could call Skip after a large or repeated wheel change. Version 4 now records the measured musical pulse separately from an independently supported stride pulse. A private replay of the current 18-track selection projects 14 ready tracks, up from 10 under version 3 and 11 in the prior saved analysis. The current song now stays in place while Manual or Auto moves it to the nearest truthful rate. A prepared replacement can commit only after Skip or a player-confirmed natural boundary. One device reimport and a short playback check remain before these field failures are physically closed.

## WHERE WE LEFT OFF

Apple Music remains the selected player. The signed repair build contains tempo estimator version 4 and removes the hidden wheel-to-Skip path. Install it when the paired iPhone reconnects, reimport the saved playlist once, confirm the visible ready count reaches the private replay expectation of about 14 of 18, then start one song and make several large wheel changes. Requested BPM should move, Music BPM should stop truthfully at the song's reachable boundary, and the song must not change until Skip or its natural end. Pull the import and run diagnostics afterward. That is the shortest remaining physical check.
