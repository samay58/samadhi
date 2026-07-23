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

The first normal field run disproved the original product mechanic. A later report exposed three more causes: stale Core Motion cadence could stay locked, the wheel sent a player command for every detent, and a matched Auto ramp could take about 20 seconds to traverse 10 percent. Half-time analysis could also label a perceptually slow 90 BPM pulse as 180 BPM. Those paths now have deterministic repairs.

Continue in this order:

1. Open the installed exact-profile build and let the saved playlist reanalyze once under tempo estimator version 3.
2. Run one short physical product check. Turn to a clearly different BPM, release, and confirm the main number and `Music` read-back agree. Return to Auto, move at a fresh cadence, and confirm the audible tempo follows within roughly five seconds rather than preserving an old sample.
3. Pull `latest-run-diagnostics.json`, `latest-import-diagnostics.json`, and the selected collection. Record requested BPM, analyzed pulse, commanded and applied rate, latency, cadence freshness, track change, and import result without committing personal metadata.
4. If audible response or command truth fails, stop and repair that recorded chain. Do not proceed to reliability or visual work.
5. If the focused physical check passes, prove a natural compatible transition, five locked minutes, controlled interruption, route loss, accessibility, and cadence calibration.
6. Complete one 20-minute outdoor run with an imported playlist. The run must feel good, survive normal phone conditions, and end with a summary whose measurement coverage and Automatic versus Manual time are honest.

## Current gate state

- Apple Music feasibility: authorization, library loading, automatic token generation, strict catalog resolution, 10 of 10 local preview decodes, playback, rate writes, pause, and resume passed
- Token remediation: complete; exact profile `Samadhi Development` fixed catalog access
- Tempo-source feasibility: passed for City Pocket at 10 of 10 decoded previews
- Tempo-analysis implementation: version 3 uses Accelerate spectral flux and fractional-lag autocorrelation inside the 120 through 210 BPM running-pulse range; 11 of 12 tempo-declared Apple previews pass exact-pulse validation and one is conservatively rejected
- Spotify feasibility: rejected for adaptive playback; it cannot supply the required app-owned, analyzable, rate-controlled audio path
- Source decision: Apple Music selected on 2026-07-16; remaining manual drills moved to the reliability gate
- Source-neutral domain and adaptation rules: bounded rate behavior and coarse track fit are connected; a five-second stable mismatch prepares the next better fit with stale-selection protection
- Cadence boundary, deterministic filter, and Core Motion adapter: connected in the focused core loop and normal imported run; a 29-second walk produced live cadence and a 142 SPM average, but calibration remains open
- Production playback: validated catalog fixture `1558215042`, live cadence updates, bounded reducer effects, identified MusicKit read-back, and honest measurement are connected
- Playlist import and persistence: implemented with strict resolution, local preview analysis, versioned cache keys, atomic replacement, complete typed per-track results, retry after relaunch, three-track bounded concurrency, private timing diagnostics, and ready-only production filtering
- Normal run composition: restored imported tracks use Apple Music playback and Core Motion; Debug Simulator uses isolated local placeholder playlists with simulated cadence and silent playback
- Automated body-to-music gate: 97 package tests, 15 app-model tests, 10 UI tests, formatter, normal Simulator build, exact-profile signed build, embedded-profile verification, and physical installation pass
- Physical body-to-music observation: passed; the corrected 59-second run averaged 155 SPM and measured 98 percent tempo matched from MusicKit read-back
- Physical imported-collection gate: real playlist selection, local analysis, reinstall and relaunch restoration, and basic progress passed at 13 of 25 ready tracks; a natural transition remains open
- Device evidence: debug builds persist one latest completed-run diagnostic file for direct container retrieval; the BPM-control build, installation, and launch pass on the physical iPhone
- Rhythm control: detents preview locally with haptics, the control stays pinned throughout a turn, finger-up commits one absolute Manual BPM and one player command, and Auto resets cadence ownership; physical audible and tactile proof remains open
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
