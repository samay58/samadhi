# Product ethos

## Promise

**Music in stride.**

Samadhi should make movement and music feel like one calm system. Name refers to meditative consciousness: absorbed attention, steady motion, reduced self-consciousness.

Runner opens app, presses Start, begins moving. Music finds their rhythm. Interface confirms lock, then withdraws.

## North star

Samadhi is done for the first real product milestone when Samay can go for a normal outdoor run with one imported Apple Music playlist, hear an unmistakable response when rhythm changes, and feel his stride settle onto the music without thinking about the app.

Done means:

- Import one Apple Music playlist
- Analyze enough tracks locally to build a usable queue
- Start a run in one or two clear actions
- Sense cadence from one declared phone placement
- Choose a track whose native pulse fits the requested rhythm
- Apply fine playback-rate correction inside a physically proven quality envelope
- Let the runner fine-tune the automatic match or choose a manual BPM without leaving the run
- Make a deliberate rhythm change audible enough to verify without watching a number
- Keep audio stable, pitch-stable, and continuous through lock, pause, resume, and route recovery
- Show honest progress and tempo-matched summary
- Make failure states calm, legible, and recoverable
- Pass one 20-minute outdoor run with listening notes and saved evidence

Done does not mean perfect recommendation, a claim of beat lock without phase evidence, exhaustive music support, dashboard history, GPS fitness tracking, social features, or a polished App Store business. Those can wait. First milestone earns the right to exist by making one real run feel meaningfully better.

If a proposed feature does not improve that run, reduce risk in that run, or make the app easier to trust during that run, defer it.

## Felt outcome

Success is not more workout data. Success is runner forgetting app and feeling inside music.

Experience should create:

- Fast arrival into rhythm
- Stable sensation despite noisy body data
- Clear confidence without constant metrics
- Music-led attention
- Safe, honest recovery when sensing or audio fails

## Product laws

### One action before motion

Returning runner starts with one deliberate action.

### Music first

Cadence is input, not content. Song, atmosphere, and rhythm outrank telemetry.

### Confirm, then withdraw

UI becomes visible during preparation, uncertainty, and direct manipulation. Stable playback should feel quiet.

### Control without clutter

Automatic matching is the default. When it feels wrong, the runner can reveal one precise rhythm control, correct it, and return attention to the music. Manual control must not become a settings screen or a permanent telemetry panel.

### Continuity over spectacle

Objects transform in place. Motion explains state. No transition competes with music.

### Stability over responsiveness theater

Raw sensor changes never drive frantic UI. Product should feel composed when input is noisy.

### Honest capability

Never imply beat-perfect adaptation, real cadence quality, or audio quality before physical proof exists.

### No Samadhi backend

No Samadhi account, cloud backend, remote listening history, analytics SDK, ad identifier, or model call. Music provider access is allowed only when the runner selects it. Tempo analysis and Samadhi persistence remain local.

### No product inflation

No dashboard, map, coaching layer, streak, social surface, recommendation feed, or tab bar. Central interaction must carry product.

## Design character

Warm, tactile, restrained, native. Depth signals hierarchy, not decoration.

- One visual owner at a time
- Open typography instead of passive cards
- Glass only for raised interactive controls
- Full-screen atmosphere that supports music identity
- Motion frozen or reduced when tempo aperture owns attention
- Readable text across palette, Dynamic Type, high contrast, and Reduce Motion

Design benchmark research lives in [DESIGN-BENCHMARKS.md](DESIGN-BENCHMARKS.md).

## Current product test

Current build answers one question: can complete run interaction feel calm, legible, and coherent before real sensing and audio exist?

Answer: the interaction is calm and the mechanical loop works, but the core feeling is not yet proven. A corrected 59-second run averaged 155 SPM and measured 98 percent tempo matched from MusicKit read-back. The runner did not hear enough change in an earlier narrow-rate check. One real 25-track playlist restores with 13 ready tracks. Samadhi must now prove an obvious clean tempo change, select tracks by fit instead of source order alone, and establish whether public MusicKit can support measured beat-phase work.

## Current exclusions

Core Motion and the Apple Music adapter now enter the normal run flow when an imported collection has ready tracks. Spotify, GPS, maps, pace, distance, coaching, plans, social features, accounts, analytics, subscriptions, and backend remain outside the useful product build.
