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
| Apple Music feasibility | Token and tempo-source passed; speaker listening passed; headphones and recovery open | Exact-profile trace with 10 of 10 decoded previews |
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
- Saved five early physical-device traces proving authorization, 40-playlist loading, real playback, live 0.94, 1.00, and 1.06 rate writes, pause, and resume
- Used the early traces to isolate two blockers: library tracks had no direct previews or ISRC, and the wildcard profile could not obtain Apple's automatic developer token
- Evaluated Spotify and rejected it as a production source because it does not provide an app-owned audio signal or documented music rate control, and its policy prohibits altering or analyzing Spotify content
- Added a source-resolution spec with explicit token, tempo-source, listening, background, and fallback gates
- Installed exact profile `Samadhi Development` and verified the signed application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`
- Passed automatic developer-token generation with repeated direct catalog responses
- Added strict title, artist, album, and duration catalog resolution that fails closed on ambiguity and persists the returned numeric catalog ID
- Downloaded remote preview assets into temporary app storage and decoded 10 of 10 City Pocket previews to PCM
- Recorded a clean built-in-speaker listening pass across the safe-rate endpoints; Bluetooth listening remains required

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

No physical run has validated cadence quality. Built-in-speaker listening found no major pitch change or unpleasant artifacts at the safe-rate endpoints, but Bluetooth listening remains open. The normal app still uses silent bundled media, simulated cadence, and simulated beat timing. Apple authorization, library loading, automatic token generation, catalog resolution, 10 of 10 preview decodes, playback, live rate writes, pause, and resume pass. Spotify is not a viable substitute for adaptive playback. Track change, screen-lock playback, controlled interruption, and route loss remain unproven.

## WHERE WE LEFT OFF

Milestone 2 safe groundwork is built. The exact Samadhi profile fixed automatic token generation. City Pocket passed strict catalog resolution and local PCM decoding at 10 of 10 tracks. Apple Music remains the active candidate. Complete headphone listening at 0.94, 1.00, and 1.06, then prove five locked minutes, next track, controlled interruption, and route loss. Any load-bearing failure still selects local files. The full decision is in [MUSIC-SOURCE-RESOLUTION-SPEC.md](MUSIC-SOURCE-RESOLUTION-SPEC.md).
