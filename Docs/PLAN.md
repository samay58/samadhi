# Product plan

## Completed gates

### Repository foundation

Project generates, builds, tests, and stores evidence without production dependencies.

### Interaction prototype

Every meaningful state renders deterministically. Golden flow and recovery paths pass. Visual hierarchy, accessibility, progress, controls, finish safety, and summary are resolved at prototype level.

### Music setup chain

Empty selection, playlist loading and selection, exact analysis progress, partial and complete readiness, typed result disclosure, and action-specific recovery now share one continuous playlist instrument. Identity stays stable while truthful status and actions hand off around it. Fresh iPhone 17 Pro Simulator evidence covers compact, empty, current-selection, large-library, long-name, accessibility XXXL, and Reduce Motion edges.

### Milestone 2 specification

Playlist import, real cadence, adaptive playback, honest measurement, source selection, testing, and physical completion are specified in [MILESTONE-2-SPEC.md](MILESTONE-2-SPEC.md).

## Active milestone

Milestone 2 turns the interaction prototype into a useful music product.

The finish line is one real outdoor run, not a feature checklist. Samay should be able to import one Apple Music playlist, start running, hear music settle into his cadence, lock the phone, recover from normal interruptions, finish, and trust the summary. Stop expanding scope until that run works.

The first normal field run disproved the original product mechanic. Later field evidence exposed stale cadence, over-sensitive wheel movement, startup selection against an invented 168 SPM prior, and a cadence range too narrow for the current playlist. The current repair addresses cadence freshness, source-order startup, transport authority, rolling diagnostics, and control sensitivity. Honest cadence compatibility improves only from 13 to 16 of 56 representative matrix cells, so broad range remains an open mechanics decision rather than a solved UI problem.

Manual control has one additional release-blocking contract. The wheel cannot display or commit a BPM the current song cannot produce inside its proven playback-rate envelope. Its integer range must come from the current cadence projection and player limits. At either boundary, value movement and detent feedback stop together, one restrained terminal haptic marks the limit, and reversing responds immediately. Playlist-wide range remains available through explicit Skip or a natural boundary. It must not appear as unreachable wheel travel.

Continue in this order:

1. Run one short physical check. The first ready track must stay current. Make one deliberate Manual turn into each reachable boundary, return to Auto, change cadence, and confirm display, MusicKit read-back, audible direction, boundary feel, and reverse response. Pull the rolling diagnostics even if the run is abandoned.
2. If that trace passes, prove explicit Skip, one natural boundary, five locked minutes, controlled interruption, and route loss. If cadence coverage still feels constrained, reopen the source and mechanics decision before more interface work.
3. Complete one 20-minute outdoor run with an imported playlist. The run must feel good, survive normal phone conditions, and end with a summary whose measurement coverage and Automatic versus Manual time are honest.

## Current gate state

- Apple Music feasibility: authorization, library loading, automatic token generation, strict catalog resolution, 10 of 10 local preview decodes, playback, rate writes, pause, and resume passed
- Token remediation: complete; exact profile `Samadhi Development` fixed catalog access
- Tempo-source feasibility: passed for City Pocket at 10 of 10 decoded previews
- Tempo-analysis implementation: version 4 searches 60 through 210 BPM, preserves the measured musical pulse, records an independently supported alternate stride pulse separately, passes 12 of 12 tempo-declared Apple previews, and rejects silent, irregular, and triple-meter ambiguity
- Spotify feasibility: rejected for adaptive playback; it cannot supply the required app-owned, analyzable, rate-controlled audio path
- Source decision: Apple Music selected on 2026-07-16; remaining manual drills moved to the reliability gate
- Source-neutral domain and adaptation rules: bounded rate behavior and coarse track fit are connected; a mismatch may prepare only the latest better fit, while Skip or a player-confirmed natural boundary remains the only commit authority
- Cadence boundary, deterministic filter, and Core Motion adapter: connected in the focused core loop and normal imported run; a 29-second walk produced live cadence and a 142 SPM average, but calibration remains open
- Production playback: validated catalog fixture `1558215042`, live cadence updates, bounded reducer effects, identified MusicKit read-back, and honest measurement are connected
- Playlist import and persistence: implemented with strict resolution, local preview analysis, versioned cache keys, atomic replacement, complete typed per-track results, retry after relaunch, three-track bounded concurrency, private timing diagnostics, and ready-only production filtering
- Normal run composition: restored imported tracks use Apple Music playback and Core Motion; Debug Simulator uses isolated local placeholder playlists with simulated cadence and silent playback
- Last released body-to-music gate: 103 package tests, 15 app-model tests, 10 UI tests, formatter, normal Simulator build, focused rotary-control UI proof, runtime screen review, renewed exact-profile build, embedded application identifier verification, and physical installation pass
- Physical body-to-music observation: passed; the corrected 59-second run averaged 155 SPM and measured 98 percent tempo matched from MusicKit read-back
- Physical imported-collection gate: real playlist selection, local analysis, reinstall and relaunch restoration, and basic progress passed at 13 of 25 ready tracks; a natural transition remains open
- Device evidence: the candidate persists one bounded latest diagnostic during the run and after completion; setup commit `cd07fd4` is installed and running with the selected collection preserved
- Rhythm control: the candidate uses 30 BPM per revolution, reverse hysteresis, a current-song integer BPM envelope, one terminal boundary haptic, frozen visual travel at the boundary, one Manual command at finger-up, and explicit return to Auto; physical audible and tactile proof remains open
- Candidate software verification: formatter lint, 118 package tests, a resource-inclusive Simulator build, 25 app-model tests, and 21 UI tests pass. Setup motion was reviewed in normal and Reduce Motion videos after two visual iteration passes.
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
