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

1. Run the Apple Music feasibility gate on a physical iPhone.
2. Choose Apple Music or local file import as the one production source.
3. Prove real cadence and one known-tempo track through the selected player.
4. Add tempo analysis and import at least three usable tracks.
5. Connect real progress, honest lock, summary, background playback, and recovery.
6. Pass automated, calibration, listening, and outdoor-run gates.

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
