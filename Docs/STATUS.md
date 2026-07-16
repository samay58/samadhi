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
| Adaptation policy | Built, not connected to a real player | Deterministic policy tests |
| Apple Music feasibility | Final exact-App-ID token repair specified | Five saved traces from iPhone 17 Pro |
| Spotify feasibility | Rejected for adaptive playback | Remote-control architecture, missing music rate control, and content policy conflict |
| Production player | Undecided | Physical gate required |
| Physical run validation | MusicKit feasibility run in progress; outdoor run not started | Requires completed source decision and route matrix |

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
- Saved three physical-device traces proving authorization, 40-playlist loading, real playback, live 0.94, 1.00, and 1.06 rate writes, pause, and resume
- Found 0 of 10 direct-library preview coverage across every sample
- Found no ISRC on 40 sampled library tracks, then exercised equivalent-ID catalog lookup
- Observed 40 `.developerTokenRequestFailed` results before any catalog response, so catalog preview coverage remains blocked rather than failed
- Verified that the Mac has only the Xcode-managed wildcard profile `ZL5U59XBJ6.*`; no exact Samadhi development profile is installed, making one fresh exact-App-ID profile the final bounded Apple token test
- Evaluated Spotify and rejected it as a production source because it does not provide an app-owned audio signal or documented music rate control, and its policy prohibits altering or analyzing Spotify content
- Added a source-resolution spec with explicit token, tempo-source, listening, background, and fallback gates

## Proof

The current serial gate passed:

- 29 Swift package tests
- 2 app-model tests
- 4 UI tests
- Swift formatter lint
- Resource-inclusive Simulator build
- Unsigned generic iPhone build
- Signed physical iPhone build and install

Durable logs and final visual frames live under Evidence/.

The MusicKit harness launches in Simulator and on the connected physical iPhone. Signing uses the Apple Development certificate for team `ZL5U59XBJ6`. Raw physical traces and their SHA-256 hashes are stored under `Evidence/Device/`.

## Known limits

No physical run has validated cadence quality. No listening test has validated tempo changes or audio artifacts. The normal app still uses silent bundled media, simulated cadence, and simulated beat timing. Music authorization, library loading, playback, live rate writes, pause, and resume pass. Direct library previews fail at 0 of 10. Catalog resolution is blocked by automatic developer-token failure. Spotify is not a viable substitute for adaptive playback. Track change, screen-lock playback, controlled interruption, and route loss remain unproven.

## WHERE WE LEFT OFF

Milestone 2 safe groundwork is built. Five physical traces are saved. Authorization, playlist loading, playback, rate writes, pause, and resume pass. Direct library previews fail. Equivalent-ID catalog requests cannot obtain Apple's automatic developer token in the current wildcard-profile build. Spotify is rejected. Create one fresh development profile bound to `com.samaydhawan.Samadhi`, sign and inspect a clean physical build, then run one minimal catalog request. If that request still returns `developerTokenRequestFailed`, record Apple Music as rejected and begin the local-file player. The full decision is in [MUSIC-SOURCE-RESOLUTION-SPEC.md](MUSIC-SOURCE-RESOLUTION-SPEC.md).
