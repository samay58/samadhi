# Architecture

## Shape

Samadhi uses functional core with main-actor shell.

~~~text
SwiftUI screens
    ↓ RunAction
RunPresentationModel
    ↓ RunEvent
RunReducer
    ↓ RunEffect
App shell services and task store
~~~

Reducer owns product state transitions. App shell owns time, UIKit, haptics, tasks, and simulated services. Views render RunViewState and send intent.

## Modules

| Module | Responsibility |
| --- | --- |
| SamadhiDomain | Run models, source-neutral music and cadence values, adaptation policy, state, events, effects, reducer, summary |
| SamadhiMotion | Cadence provider boundary, deterministic filtering and simulation, Core Motion adapter |
| SamadhiAudio | Beat timing boundary and current deterministic simulation |
| SamadhiDesign | Screens, controls, fluid field, aperture, previews, tokens |
| App target | Presentation mapping, effect execution, UIKit, task ownership |

No diagnostics module exists. Empty marker target was removed.

## State ownership

RunReducer is sole authority for phase changes. Mutually exclusive phases use enums. Reducer remains free of SwiftUI, Core Motion, audio frameworks, UIKit, and wall-clock access.

RunPresentationModel owns one RunState, maps it to RunViewState, and executes reducer effects. RunTaskStore owns replacement, cancellation, and stale-generation protection for async work.

## View structure

SamadhiScreen keeps continuous atmospheric surface and routes state to focused screens:

- ReadyScreen
- ActiveRunScreen
- RunRecoveryScreen
- RunSummaryScreen

Run controls, summary metrics, duration formatting, aperture, and fluid field live in dedicated types. Views contain thin UI actions only. Business transitions remain in reducer.

## Cancellation

Every replaceable task has RunTaskKind. Starting replacement cancels prior generation. Pausing cancels acquisition, control timeout, and ticker. Route loss and finishing cancel all session work before pause or stop effect.

Stale events carry session, acquisition, timeout, or hold identifiers. Reducer ignores mismatches.

## Collection navigation

Reducer receives track count. App passes TrackMetadata.demoTracks.count. Domain no longer assumes collection size.

## Production seams

Milestone 2 replaces simulated motion and audio behind current boundaries according to [MILESTONE-2-SPEC.md](MILESTONE-2-SPEC.md). Do not bypass reducer from SwiftUI. Do not let Core Motion, MusicKit, or audio callbacks mutate view state directly.

Production services need:

- Async event streams
- Explicit start, pause, resume, and stop lifecycle
- Cancellation-safe teardown
- Session identity on callbacks
- Deterministic adapters for tests

The music-source feasibility gate selects one production player. The codebase must not retain both Apple Music and local file playback as competing implementations after the decision.

The debug-only MusicKit harness sits in the app target and is not a production player. It exists only to settle the source decision on a physical iPhone. For tempo-source feasibility, it resolves opaque library tracks through strict title, artist, album, and duration agreement, stores the returned numeric catalog identity, downloads the catalog preview into temporary storage, decodes local PCM, and deletes the temporary file. The normal app still composes simulation.

## Invariants

- UI reports capability honestly
- Paused and acquiring time do not inflate active summary
- Route restoration never auto-resumes active playback
- Finish requires visible control plus hold
- Progress resets on track navigation
- Reduce Motion freezes ambient motion
- No Samadhi backend; Apple Music is the only allowed production network path if it passes the physical gate
- Tempo match measurement enters the reducer as evidence from the app shell; the reducer does not infer a match from cadence alone
