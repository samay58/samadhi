# Product plan

## Completed gates

### Repository foundation

Project generates, builds, tests, and stores evidence without production dependencies.

### Interaction prototype

Every meaningful state renders deterministically. Golden flow and recovery paths pass. Visual hierarchy, accessibility, progress, controls, finish safety, and summary are resolved at prototype level.

### Milestone 2 specification

Playlist import, real cadence, adaptive playback, honest measurement, source selection, testing, and physical completion are specified in [MILESTONE-2-SPEC.md](MILESTONE-2-SPEC.md).

## Active milestone

Milestone 2 turns the interaction prototype into a useful music product.

The finish line is one real outdoor run, not a feature checklist. Samay should be able to import one Apple Music playlist, start running, hear music settle into his cadence, lock the phone, recover from normal interruptions, finish, and trust the summary. Stop expanding scope until that run works.

The first normal field run disproved the original product mechanic. Its deterministic replay now passes after repairing command truth, prompt MusicKit read-back, immediate compatible-track changes, rapid-detent coalescing, honest summary coverage, complete import disclosure, bounded import work, and directional haptic grammar. The detailed failure and remediation boundary live in `Evidence/Device/2026-07-22-field-run-failure-analysis.md`.

Continue in this order:

1. Run one short physical product check on the installed remediation build. Import or retry one real playlist, turn far enough to require a compatible track, confirm the audible direction and response, and judge clockwise versus counterclockwise haptics.
2. Pull `latest-run-diagnostics.json`, `latest-import-diagnostics.json`, and the selected collection immediately after that check. Record command latency, requested and achievable BPM, commanded and applied rate, track change, complete import outcomes, and import wall time without committing personal metadata.
3. If audible response or command truth fails, stop and repair that recorded chain. Do not proceed to reliability or visual work. If import is still slow, use the stage timings to fix the measured bottleneck rather than increasing concurrency blindly.
4. If the focused physical check passes, prove a natural compatible transition, five locked minutes, controlled interruption, route loss, accessibility, and cadence calibration.
5. Complete one 20-minute outdoor run with an imported playlist. The run must feel good, survive normal phone conditions, and end with a summary whose measurement coverage and Automatic versus Manual time are honest.

## Current gate state

- Apple Music feasibility: authorization, library loading, automatic token generation, strict catalog resolution, 10 of 10 local preview decodes, playback, rate writes, pause, and resume passed
- Token remediation: complete; exact profile `Samadhi Development` fixed catalog access
- Tempo-source feasibility: passed for City Pocket at 10 of 10 decoded previews
- Tempo-analysis implementation: version 2 uses Accelerate spectral flux and fractional-lag autocorrelation; 12 of 12 tempo-declared Apple previews pass the narrow corpus gate
- Spotify feasibility: rejected for adaptive playback; it cannot supply the required app-owned, analyzable, rate-controlled audio path
- Source decision: Apple Music selected on 2026-07-16; remaining manual drills moved to the reliability gate
- Source-neutral domain and adaptation rules: bounded rate behavior and coarse track fit are connected; a five-second stable mismatch prepares the next better fit with stale-selection protection
- Cadence boundary, deterministic filter, and Core Motion adapter: connected in the focused core loop and normal imported run; a 29-second walk produced live cadence and a 142 SPM average, but calibration remains open
- Production playback: validated catalog fixture `1558215042`, live cadence updates, bounded reducer effects, identified MusicKit read-back, and honest measurement are connected
- Playlist import and persistence: implemented with strict resolution, local preview analysis, versioned cache keys, atomic replacement, complete typed per-track results, retry after relaunch, three-track bounded concurrency, private timing diagnostics, and ready-only production filtering
- Normal run composition: restored imported tracks use Apple Music playback and Core Motion; Debug Simulator uses isolated local placeholder playlists with simulated cadence and silent playback
- Automated body-to-music gate: 92 package tests, 14 app-model tests, 10 UI tests, formatter, normal Simulator build, exact-profile signed build, embedded-profile verification, and physical installation pass
- Physical body-to-music observation: passed; the corrected 59-second run averaged 155 SPM and measured 98 percent tempo matched from MusicKit read-back
- Physical imported-collection gate: real playlist selection, local analysis, reinstall and relaunch restoration, and basic progress passed at 13 of 25 ready tracks; a natural transition remains open
- Device evidence: debug builds persist one latest completed-run diagnostic file for direct container retrieval; the BPM-control build, installation, and launch pass on the physical iPhone
- Rhythm control: the aperture is the one rotary click wheel with Auto fine-tune, Manual target, soft takeover, one-BPM detents, verified command states, compatible-track response, prompt read-back, directional haptics, diagnostics, and accessibility; physical audible and tactile proof of this remediation remains open
- Felt-synchronization research: complete enough to set direction; Weav used adaptive arrangements, djay separates BPM from beat sync, and published running work supports compatible-track selection plus phase-aware control
- Device harness: exact-profile catalog search, strict identity resolution, temporary preview download, local PCM decoding, playback, rate controls, route observation, and trace export remain available on the physical iPhone 17 Pro
- Perceptibility result: 0.90 versus 1.10 was clearly audible on `LITE SPOTS` through Beoplay Eleven; Apple Music stays authoritative while broader blinded and full-song quality evidence remains open

The source decision and deferred reliability requirements live in [MUSIC-SOURCE-RESOLUTION-SPEC.md](MUSIC-SOURCE-RESOLUTION-SPEC.md). A later reliability failure must be fixed before Milestone 2 completion. It does not reopen Spotify or a second-provider project.

## Milestone boundary

Included:

- One imported collection
- One selected production playback system
- Core Motion cadence from one declared phone placement
- Local tempo analysis
- Compatible-track selection plus pitch-stable fine correction inside a physically proven quality envelope
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
