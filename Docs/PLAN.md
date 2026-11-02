# Product plan

## Completed gates

### Repository foundation

Project generates, builds, tests, and stores evidence without production dependencies.

### Interaction prototype

Every meaningful state renders deterministically. Golden flow and recovery paths pass. Visual hierarchy, accessibility, progress, controls, finish safety, and summary are resolved at prototype level.

### Music setup chain

Empty selection, playlist loading and selection, exact analysis progress, partial and complete readiness, typed result disclosure, and action-specific recovery now share one continuous playlist instrument. Identity stays stable while truthful status and actions hand off around it. Fresh iPhone 17 Pro Simulator evidence covers compact, empty, current-selection, large-library, long-name, accessibility XXXL, and Reduce Motion edges.

### Core reset software baseline

Every Debug run records its base commit, branch, dirty state, source fingerprint, build time, app version, and build number. It explains the current song speed, phone rhythm, settled Auto target, requested playback change, Apple Music reply, delay, result, and remaining difference. Deterministic tests cover the reported current behaviors. Fresh Simulator frames cover low-tempo two-step music, all four command results, song reset, accessibility XXXL, Reduce Motion, and Increased Contrast.

### Track-scoped Manual and tempo close

Manual remains active on the same confirmed song through pause, resume, route loss, and recovery. It returns to Auto only after the player confirms a different song or the runner chooses Auto. The tempo wheel has an accessible close action that restores playback controls without changing playback or rhythm.

### Transport, song-change cause, and the first Auto feedback prototype

Play, Pause, Previous, Next, and Finish are one control system: three separate interactive Liquid Glass circles with a larger tinted primary, and a quiet Finish button below them that arms a hold whose fill is clipped by its own capsule. Both causes of the reported Finish overflow were reproduced on video and removed. Every confirmed song change carries a cause of natural end, outside change, or explicit Previous or Next, and the hidden Debug screen shows it. A reducer-owned transaction decides when one directional Auto cue is valid, and three prototype haptic families with paired arrival sounds can be played by hand from a Debug audition screen. Physical feel, sound quality, and Apple Music coexistence remain open.

### Milestone 2 specification

Playlist import, real cadence, adaptive playback, honest measurement, source selection, testing, and physical completion are specified in [MILESTONE-2-SPEC.md](MILESTONE-2-SPEC.md).

## Active milestone

Milestone 2 turns the interaction prototype into a useful music product.

The finish line is one real outdoor run, not a feature checklist. Samay should be able to import one Apple Music playlist, start running, hear music settle into his cadence, lock the phone, recover from normal interruptions, finish, and trust the summary. Stop expanding scope until that run works.

The wheel keeps one release-blocking contract. It cannot display or commit a BPM the current song cannot produce inside its proven playback-rate envelope. At either boundary, value movement and detent feedback stop together, one restrained terminal haptic marks the limit, and reversing responds immediately.

Continue in this order:

1. Install the current build, then walk Easy Miles and read the record. This answers what the August 19 walk could not: whether cues played, what happened at a boundary, and whether the reach line fired. It is also the first chance to hear the crossfade.
2. Run [PHONE-CHECK.md](PHONE-CHECK.md): endpoint listening, transport and Finish feel, blinded direction trials, song-change causes, and lock, call, and route recovery.
3. Complete one 20-minute outdoor run with an imported playlist. It must feel good, survive normal phone conditions, and end with an honest summary.

After that run, the open question is beat phase. Tempo match and beat lock stay distinct until phase is measured. The gate and the app-owned audio pivot are written in [FELT-SYNCHRONIZATION-EXECUTION-SPEC.md](Archive/FELT-SYNCHRONIZATION-EXECUTION-SPEC.md).

The source decision and deferred reliability requirements live in [MUSIC-SOURCE-RESOLUTION-SPEC.md](Archive/MUSIC-SOURCE-RESOLUTION-SPEC.md). A later reliability failure must be fixed before Milestone 2 completion. It does not reopen Spotify or a second-provider project.

## Decision waiting on Samay

This came out of the November sweep. It has not been built, because it changes the product.

1. Keep or remove Auto fine-tune. `PRODUCT.md` and `CONTEXT.md` describe it, and the reducer supports it, but no control sends `adjustRhythmControl` since the wheel moved to `commitRhythmTarget`. Either the wheel gains it back or the reducer path and its tests go.

## Known debt before any public Release

Nothing here affects today's Debug phone builds.

- Diagnostics and simulator launch flags still compile into Release, although Release never records and the Debug screens are absent. Wrap them in `#if DEBUG` before an App Store build.
- `RunReducer.init(trackCount:)` exists only for tests, and it keeps a `demo-0` fallback in the domain. Move those tests to `init(tracks:)`.
- `FeedbackAuditionView` plays cues directly. It is a Debug harness that goes away once a cue family is chosen.
- If `resume` is still in flight when the runner pauses, Apple Music can start after the pause. The ticker no longer restarts, but playback itself is unguarded.

## Milestone boundary

Included:

- One imported collection
- One selected production playback system
- Core Motion cadence from one declared phone placement
- Local tempo analysis
- Compatible-track selection plus fine correction inside a declared envelope that passes physical listening
- One calm in-run BPM control for automatic matching, manual targeting, and small corrections
- Background continuity with screen lock
- Existing pause, resume, skip, route recovery, finish, and summary behavior
- Physical calibration, listening evidence, and one 20-minute outdoor run

Excluded:

- Playlist generation and recommendations
- Spotify or a second production music provider
- A beat-lock claim before phase and latency are measured
- Run history, GPS, coaching, social features, backend, subscriptions, and broad hardware support

## Stop rule

Do not redesign the app or build playlist generation before imported music and the physical body-to-music loop work. The BPM control is part of that loop, not a settings feature. If public MusicKit cannot make a clean change that Samay can reliably feel, reopen the source decision. The complete mechanics and evidence thresholds live in [ADAPTIVE-AUDIO-PLAYBOOK.md](ADAPTIVE-AUDIO-PLAYBOOK.md).
