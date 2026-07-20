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

The BPM-control implementation and Simulator design gate are complete. Continue in this order:

1. Install the BPM-control build, then compare requested BPM, derived target rate, and MusicKit read-back at three reachable targets and one unreachable target on the physical iPhone.
2. Relaunch the physical app and prove the persisted 13-ready-track playlist restores.
3. Verify real progress, one natural track transition, honest lock, and the saved summary across imported tracks.
4. Complete five locked minutes, interruption, route loss, accessibility, and recovery checks.
5. Pass cadence calibration, listening, and the outdoor-run gate.

## Current gate state

- Apple Music feasibility: authorization, library loading, automatic token generation, strict catalog resolution, 10 of 10 local preview decodes, playback, rate writes, pause, and resume passed
- Token remediation: complete; exact profile `Samadhi Development` fixed catalog access
- Tempo-source feasibility: passed for City Pocket at 10 of 10 decoded previews
- Tempo-analysis implementation: version 2 uses Accelerate spectral flux and fractional-lag autocorrelation; 12 of 12 tempo-declared Apple previews pass the narrow corpus gate
- Spotify feasibility: rejected for adaptive playback; it cannot supply the required app-owned, analyzable, rate-controlled audio path
- Source decision: Apple Music selected on 2026-07-16; remaining manual drills moved to the reliability gate
- Source-neutral domain and adaptation rules: complete for the current slice
- Cadence boundary, deterministic filter, and Core Motion adapter: connected in the focused core loop and normal imported run; a 29-second walk produced live cadence and a 142 SPM average, but calibration remains open
- Production playback: validated catalog fixture `1558215042`, live cadence updates, bounded reducer effects, identified MusicKit read-back, and honest measurement are connected
- Playlist import and persistence: implemented with strict resolution, local preview analysis, versioned cache keys, atomic replacement, honest per-track states, and ready-only production filtering
- Normal run composition: restored imported tracks use Apple Music playback and Core Motion; deterministic fixtures remain available for tests and previews
- Automated body-to-music gate: 60 package tests, 9 app-model tests, 9 UI tests, formatter, normal Simulator build, and current exact-profile signed build pass; the prior normal installation also passed
- Physical body-to-music observation: passed; the corrected 59-second run averaged 155 SPM and measured 98 percent tempo matched from MusicKit read-back
- Physical imported-collection gate: real playlist selection and local analysis passed at 13 of 25 ready tracks; relaunch restore and multi-track run remain open
- Device evidence: debug builds persist one latest completed-run diagnostic file for direct container retrieval; the BPM-control build, installation, and launch pass on the physical iPhone
- Rhythm control: implemented with Auto fine-tune, Manual target, reset, honest limit feedback, reducer-owned safety, diagnostics, restrained haptics, and accessibility; physical MusicKit and listening proof remains open
- Device harness: exact-profile catalog search, strict identity resolution, temporary preview download, local PCM decoding, playback, rate controls, route observation, and trace export remain available on the physical iPhone 17 Pro

The source decision and deferred reliability requirements live in [MUSIC-SOURCE-RESOLUTION-SPEC.md](MUSIC-SOURCE-RESOLUTION-SPEC.md). A later reliability failure must be fixed before Milestone 2 completion. It does not reopen Spotify or a second-provider project.

## Milestone boundary

Included:

- One imported collection
- One selected production playback system
- Core Motion cadence from one declared phone placement
- Local tempo analysis
- Pitch-stable playback-rate adaptation from 0.94 through 1.06
- One calm in-run BPM control for automatic matching, manual targeting, and small corrections
- Background continuity with screen lock
- Existing pause, resume, skip, route recovery, finish, and summary behavior
- Physical calibration, listening evidence, and one 20-minute outdoor run

Excluded:

- Playlist generation and recommendations
- Spotify or a second production music provider
- Beat-perfect footfall phase alignment
- Run history, GPS, coaching, social features, backend, subscriptions, and broad hardware support

## Stop rule

Do not redesign the app or build playlist generation before imported music and the physical body-to-music loop work. The BPM control is part of that loop, not a settings feature. If cadence, tempo accuracy, or audio quality fails, fix the core loop before adding surrounding product.
