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
| Apple Music feasibility | Harness ready; physical gate blocked | Device evidence record |
| Production player | Undecided | Physical gate required |
| Physical run validation | Not started | Requires device and route matrix |

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
- Confirmed no physical iPhone is connected and a signed build has no development team
- Added source-neutral collection, track, tempo, cadence, progress, adaptation, and tempo-measurement models
- Added bounded adaptation with half and double tempo normalization, ramp limits, deadband, update interval, confidence hold, and calm return to normal speed
- Added cadence-provider events, deterministic cadence filtering, and a Core Motion provider that compiles for iPhone
- Renamed the summary measurement to tempo matched and made fixed rhythm report Not measured
- Added a debug-only MusicKit gate scheme with playlist loading, decoded PCM preview coverage, playback, rate controls, route and interruption observation, and JSON trace export
- Added music and motion permission text plus verified background audio mode

## Proof

The current serial gate passed:

- 29 Swift package tests
- 2 app-model tests
- 4 UI tests
- Swift formatter lint
- Resource-inclusive Simulator build
- Unsigned generic iPhone build

Durable logs and final visual frames live under Evidence/.

The MusicKit harness also launches in Simulator. The signed generic iPhone build reaches the expected blocker because the project has no Apple development team.

## Known limits

No physical iPhone run has validated cadence quality. No listening test has validated tempo changes or audio artifacts. The normal app still uses silent bundled media, simulated cadence, and simulated beat timing. The MusicKit harness compiles but has not touched a real account or library. UI demonstrates intended behavior, not production sensing or playback.

## WHERE WE LEFT OFF

Milestone 2 safe groundwork is built. The Apple Music gate remains blocked because no physical iPhone is connected and the project has no Apple development team. Next work is one physical run of the `Samadhi MusicKit Gate` scheme. Do not choose a player, redesign the interface, or build playlist generation before that evidence exists.
