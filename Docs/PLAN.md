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

Build in this order:

1. Run one catalog track with a verified tempo through the Apple Music adapter.
2. Connect Core Motion cadence and bounded rate adaptation through the existing reducer boundary.
3. Add tempo analysis and import at least three usable playlist tracks.
4. Connect persistent selection, real progress, track transitions, honest lock, and summary.
5. Complete five locked minutes, next track, interruption, route loss, accessibility, and recovery checks.
6. Pass cadence calibration, listening, and the outdoor-run gate.

## Current gate state

- Apple Music feasibility: authorization, library loading, automatic token generation, strict catalog resolution, 10 of 10 local preview decodes, playback, rate writes, pause, and resume passed
- Token remediation: complete; exact profile `Samadhi Development` fixed catalog access
- Tempo-source feasibility: passed for City Pocket at 10 of 10 decoded previews; analyzer accuracy remains a later gate
- Spotify feasibility: rejected for adaptive playback; it cannot supply the required app-owned, analyzable, rate-controlled audio path
- Source decision: Apple Music selected on 2026-07-16; remaining manual drills moved to the reliability gate
- Source-neutral domain and adaptation rules: complete for the current slice
- Cadence boundary, deterministic filter, and Core Motion adapter: built but not physically calibrated or connected to the normal run flow
- Production playback: source-neutral contract, deterministic player, Apple Music adapter, identified events, real duration progress, and a core-loop scheme are built
- Device harness: exact-profile catalog search, strict identity resolution, temporary preview download, local PCM decoding, playback, rate controls, route observation, and trace export remain available on the physical iPhone 17 Pro

The source decision and deferred reliability requirements live in [MUSIC-SOURCE-RESOLUTION-SPEC.md](MUSIC-SOURCE-RESOLUTION-SPEC.md). A later reliability failure must be fixed before Milestone 2 completion. It does not reopen Spotify or a second-provider project.

## Milestone boundary

Included:

- One imported collection
- One selected production playback system
- Core Motion cadence from one declared phone placement
- Local tempo analysis
- Pitch-stable playback-rate adaptation from 0.94 through 1.06
- Background continuity with screen lock
- Existing pause, resume, skip, route recovery, finish, and summary behavior
- Physical calibration, listening evidence, and one 20-minute outdoor run

Excluded:

- Playlist generation and recommendations
- Spotify or a second production music provider
- Beat-perfect footfall phase alignment
- Run history, GPS, coaching, social features, backend, subscriptions, and broad hardware support

## Stop rule

Do not redesign the app or build playlist generation before imported music and the physical body-to-music loop work. If Apple Music fails its gate, stop that player path. If cadence or audio quality fails, fix the core loop before adding surrounding product.
