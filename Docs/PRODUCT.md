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
- Apply fine playback-rate correction inside a declared envelope that passes physical listening
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

### Understandable without looking

An automatic music change must make sense when the phone is locked or in a pocket. Do not depend on temporary screen text. Use sparse touch and sound only for meaningful, verified changes, then return attention to the music.

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

The interaction is calm and the mechanical loop works, but the core feeling is not yet proven. A fingerprinted workout confirmed that fresh delayed phone readings can settle Auto and that Apple Music can return the requested speed. It also exposed a practical gap: most retained movement readings sat in the brisk-walking range below the old 120 SPM floor, and Samay found audible changes jarring and unexplained.

The current software candidate accepts steady movement from 90 through 210 SPM. Walking needs five seconds of steady evidence. Running can settle after the motion filter locks. Broken gym movement does not build a target, and raw cadence cannot change the music before the separate Auto target settles. The next physical check must prove that this feels useful during clean walking and does not react to lifting.

The run controls are now one glass capsule bar with a quiet hold-to-finish below it, and the two causes of the reported Finish border overflow were reproduced on video and removed. Every confirmed song change records whether it was a natural end, an outside change, or an explicit Previous or Next. The directional Auto feedback from the workout complaint now exists as a prototype: the app decides when one cue is valid and can play three haptic families with paired arrival sounds. None of that has been felt or heard. Press feel, tactile recognition, sound quality against real music, and locked-screen delivery are all unproved, and no family has been chosen.

The current candidate can change one song from 85 to 115 percent of normal speed. This gives Auto and Manual more useful reach without changing songs as often. The app ramps an automatic change by at most two percentage points per second, so moving from normal speed to either endpoint takes at most eight seconds. Correct commands and Apple Music read-back are software and device checks. Clean sound at the new endpoints still requires Samay's listening approval.

## Current exclusions

Core Motion and the Apple Music adapter now enter the normal run flow when an imported collection has ready tracks. Spotify, GPS, maps, pace, distance, lifting adaptation, coaching, plans, social features, accounts, analytics, subscriptions, and backend remain outside the useful product build.
