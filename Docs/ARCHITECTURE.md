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
| SamadhiDomain | Run models, source-neutral music and cadence values, track-fit planning, adaptation policy, state, events, effects, reducer, summary |
| SamadhiMotion | Cadence provider boundary, deterministic filtering and simulation, Core Motion adapter |
| SamadhiAudio | Local tempo analysis, source-neutral playback contract, deterministic player, beat timing, and playback events |
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

Run controls, rhythm control, summary metrics, duration formatting, aperture, and fluid field live in dedicated types. Views contain thin UI actions only. Business transitions remain in reducer.

## Cancellation

Every replaceable task has RunTaskKind. Starting replacement cancels prior generation. Pausing cancels acquisition, control timeout, and ticker. Route loss and finishing cancel all session work before pause or stop effect.

Stale events carry session, acquisition, timeout, or hold identifiers. Reducer ignores mismatches.

## Collection navigation

Reducer receives the selected tracks. Production composition passes only adaptive-ready imported tracks while deterministic fixtures retain their configured collection. Domain no longer assumes collection size.

`TrackMatchPlanner` is the source-neutral coarse-matching seam. Given a requested musical BPM and a quality envelope, it ranks ready tracks across half-time, full-time, and double-time pulses by required stretch. It preserves source order for ties and retains the current song when switching would provide only a marginal improvement. Production connection remains a reducer and player-queue task, not a SwiftUI responsibility.

## Production seams

Milestone 2 replaces simulated motion and audio behind current boundaries according to [MILESTONE-2-SPEC.md](MILESTONE-2-SPEC.md). Do not bypass reducer from SwiftUI. Do not let Core Motion, MusicKit, or audio callbacks mutate view state directly.

Production services need:

- Async event streams
- Explicit start, pause, resume, and stop lifecycle
- Cancellation-safe teardown
- Session identity on callbacks
- Deterministic adapters for tests

Apple Music is the selected production player. `AppleMusicPlaybackController` is main-actor owned in the app target and implements the source-neutral `MusicPlaybackProviding` boundary. Restored imported collections compose it with `CoreMotionCadenceProvider` in the normal app. Automated fixtures and previews keep deterministic simulation. The codebase does not contain a second production player.

Stable cadence enters the reducer with session and acquisition identity. The reducer owns `AdaptationState`, evaluates the current track's tempo, and emits a bounded rate effect carrying session, playback operation, rate request, and track identity. Player feedback must match all four identities before the reducer records the applied rate. Cadence sensing continues after lock so confidence loss can hold, ease toward normal speed, and return to acquisition without direct platform mutation.

`RhythmControlState` is source-neutral run state. Auto applies a bounded correction to reliable cadence. Manual supplies a musical target without inventing cadence. Both enter the same `AdaptationPolicy`, so rate limits, ramping, deadband, confidence handling, compatibility, and identified MusicKit feedback stay authoritative. The SwiftUI control freezes its displayed target during a drag, sends intent through `RunPresentationModel`, and never writes the player directly.

The debug-only MusicKit harness sits in the app target and is not a production player. It resolves opaque library tracks through strict title, artist, album, and duration agreement, downloads each preview into temporary storage, passes the local file through `TempoAnalyzing`, records the estimate, and deletes the file. `LocalTempoAnalyzer` owns off-main PCM decoding. `TempoEstimator` owns versioned Accelerate spectral-flux and fractional-lag autocorrelation behavior behind the same small interface.

`AppleMusicImportService` reuses the strict resolver, analyzes tracks sequentially, and reports honest progress. `MusicCollectionStore` atomically persists the selected collection and versioned analysis cache. `MusicSelectionModel` owns replacement identity and ignores stale import callbacks. SwiftUI only sends choose, change, and start intent.

`TempoCorpusValidator` is an opt-in development executable. It validates fixed catalog identities whose published titles declare tempo, analyzes temporary provider-hosted previews, writes JSON evidence, and removes the audio. Normal automated tests remain offline.

Debug builds overwrite one local latest-run diagnostic file after finish. `RunDiagnosticsRecorder` observes accepted reducer transitions from the app shell and records control mode, requested BPM, derived and applied rates, limit state, player progress, cadence, track changes, recovery events, and summary truth. `RunDiagnosticsStore` writes that snapshot atomically under Application Support. It does not change reducer state or create product run history.

## Invariants

- UI reports capability honestly
- Paused and acquiring time do not inflate active summary
- Route restoration never auto-resumes active playback
- Finish requires visible control plus hold
- Progress resets on track navigation
- Reduce Motion freezes ambient motion
- No Samadhi backend; Apple Music is the only allowed production network path if it passes the physical gate
- Tempo match measurement enters the reducer as evidence from the app shell; the reducer does not infer a match from cadence alone
- Playback progress and recovery callbacks carry session and operation identity before entering the reducer
- Applied-rate callbacks also carry request and track identity; stale feedback cannot alter a replacement run
