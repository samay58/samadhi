# Current status

## At a glance

| Area | State | Evidence |
| --- | --- | --- |
| Product interaction | Complete prototype | Golden UI flow |
| Visual system | Complete prototype | Final Simulator frames |
| Accessibility | Covered in prototype | Dynamic Type, Reduce Motion, contrast, VoiceOver behavior |
| State architecture | Complete for prototype | Pure reducer tests |
| Cadence | Production boundary and Core Motion adapter built; app still simulated | Deterministic filter tests and generic iPhone build |
| Audio timing | Simulated only | Deterministic beat-clock tests |
| Playlist import | Specified, not started | Milestone 2 spec |
| Tempo analysis | Version 2 passes a narrow 12-preview real-music corpus | Generated regression tests and opt-in Apple preview validation |
| Adaptation policy | Built, not connected to a real player | Deterministic policy tests |
| Apple Music feasibility | Source selected; Bluetooth route and rate writes passed; long-form reliability deferred | Exact-profile traces and explicit product decision |
| Spotify feasibility | Rejected for adaptive playback | Remote-control architecture, missing music rate control, and content policy conflict |
| Production player | Apple Music selected; adapter built behind a core-loop launch path | Source-neutral contract and generic iPhone build |
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
- Added a dedicated `Samadhi Apple Music Core Loop` scheme, then replaced its provisional track with verified catalog fixture `1066177773`
- Added one local audio analysis interface, off-main PCM decoding, a versioned tempo estimator, and generated tempo and rejection fixtures
- Connected the MusicKit harness to report estimated tempo and confidence for resolved previews
- Replaced frame-energy onset detection with Accelerate spectral flux and fractional-lag autocorrelation after real previews exposed a confident triple-meter error
- Added an opt-in 12-track Apple preview corpus with published tempo references; version 2 passed 12 of 12 within the accepted tempo family
- Selected catalog track `1066177773` as the verified 170 BPM core-loop fixture

## Proof

The current serial gate passed:

- 38 Swift package tests
- 2 app-model tests
- 4 UI tests
- Swift formatter lint
- Resource-inclusive Simulator build
- Unsigned generic iPhone build
- Signed physical iPhone build with the exact development profile

Durable logs and final visual frames live under Evidence/.

The MusicKit harness launches in Simulator and on the connected physical iPhone. Signing uses the Apple Development certificate for team `ZL5U59XBJ6`. Raw physical traces and their SHA-256 hashes are stored under `Evidence/Device/`.

## Known limits

No physical run has validated cadence quality. Built-in-speaker listening found no major pitch change or unpleasant artifacts at the safe-rate endpoints. Bluetooth routing and rate writes pass, but no separate Bluetooth listening note was recorded. The tempo estimator passes its narrow 12-preview reference corpus, but broad music accuracy and public-distribution permission for preview analysis remain open. The normal app still defaults to silent bundled media, simulated cadence, and simulated beat timing. Track change, five locked minutes, controlled interruption, and route loss remain reliability gates.

## WHERE WE LEFT OFF

Apple Music is selected. The player contract, Apple Music adapter, version 2 tempo analyzer, 12-preview validation corpus, real progress events, and focused core-loop scheme are built. Catalog track `1066177773` is the verified 170 BPM fixture. Next, run that fixture through the production adapter, then connect Core Motion and bounded adaptation. Long-form reliability checks remain mandatory before Milestone 2 completion, but no longer block implementation.
