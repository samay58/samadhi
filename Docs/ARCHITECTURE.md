# Architecture

## Shape

Samadhi uses a functional core with an actor-ready shell.

- `SamadhiDomain` contains pure state, events, effects, fixtures, and summary calculation.
- `SamadhiMotion` exposes cadence-provider boundaries and simulated cadence only in Milestone 1.
- `SamadhiAudio` exposes a beat-clock boundary and simulated beat clock only in Milestone 1.
- `SamadhiDesign` owns SwiftUI screens, components, motion tokens, and preview fixtures.
- `SamadhiDiagnostics` owns debug-only fixture controls.
- The app target owns a single main-actor presentation model and executes simulated effects.

## State ownership

`RunReducer` is pure and deterministic. It is the only authority for phase changes. `RunPresentationModel` owns one `RunState`, sends events through the reducer, and executes the bounded simulated effects. Views receive the model explicitly and do not start services.

## Milestone boundaries

Milestone 1 does not import CoreMotion, AVFoundation, MediaPlayer, HealthKit, or networking frameworks. The simulated beat clock uses monotonic elapsed time and publishes phase through a narrow protocol. This preserves the production seam without pretending that audio is implemented.

## Cancellation

The presentation model owns acquisition and controls-timeout tasks. Each replacement cancels the prior task. Finishing and returning to ready cancel all pending tasks.

