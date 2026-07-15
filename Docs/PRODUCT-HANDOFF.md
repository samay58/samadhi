# In Step
## Codex Build Handoff
### A design-led cadence music player for iPhone

**Status:** Implementation brief  
**Audience:** Codex working locally with Xcode and an iPhone  
**Working title:** In Step  
**Primary objective:** Build the smallest possible app that makes running feel musically locked-in, with exceptional interaction quality and no fitness-app clutter.

---

# 0. Read this first

This is not a request to make a generic running app.

Do not add a dashboard, coaching, maps, plans, social features, streaks, AI recommendations, chat, gamification, calories, achievements, or a subscription funnel.

The product is a body-aware music player:

> Press Start. Begin running. The music quietly finds your stride. The interface confirms the lock, then disappears.

The app should feel authored rather than generated. Every visible element must earn its place. Every transition must preserve physical and conceptual continuity. The result should be useful with almost nothing in it.

There must be **no AI functionality in the shipped app**. Codex may use every available agentic development capability to build and validate it, but the user-facing product remains local, deterministic, calm, and legible.

---

# 1. Product truth

## 1.1 The job

The runner wants to enter a zone in which their stride and the music feel like one system.

They are not primarily asking for:

- Better workout statistics
- More running content
- A coaching voice
- A social network
- A more optimized training plan

They are asking for a felt experience:

- Rhythm arrives quickly
- The body stops negotiating with the music
- Cadence becomes easier to sustain
- The interface recedes
- The run feels unusually fluid

## 1.2 Product promise

**Your run sets the rhythm. The music meets you there.**

## 1.3 Success test

The app succeeds when, after a run, the user says:

> I forgot about the app and felt completely inside the music.

The app fails when the user remembers:

- A BPM number constantly changing
- A dashboard asking for attention
- A sensor struggling to lock
- A playlist recommendation engine
- An animated visual competing with the song
- A setting they had to configure
- A subscription prompt

---

# 2. Product principles

## 2.1 One action before motion

A returning user should be able to launch the app and begin with one deliberate action.

## 2.2 Music first

Cadence is an input to the experience, not the content of the experience. Song, atmosphere, and rhythm take priority over metrics.

## 2.3 The interface confirms, then withdraws

UI is most visible during preparation, uncertainty, and direct manipulation. Once playback and cadence are stable, it should become quiet.

## 2.4 Continuity over spectacle

Views should transform rather than disappear and reappear. Motion should explain where an object came from, what changed, and where it went.

## 2.5 Stability over responsiveness theater

Do not visibly react to every raw cadence sample. The product should feel composed even when the sensor is noisy.

## 2.6 Honest capability

Never imply beat-perfect adaptation when the underlying source only supports track matching. Never present estimated cadence as exact. Never hide a lost sensor state behind fake motion.

## 2.7 Local by default

No account, cloud backend, ad identifier, third-party analytics SDK, or remote listening-history upload.

## 2.8 No product inflation

Do not add features to make the app look substantial. It should feel complete because the central interaction is resolved.

---

# 3. Scope

## 3.1 Version 0.1 includes

- One prepared demo music collection bundled with the app
- Optional import of DRM-free audio files from Files
- Cadence sensing from iPhone motion data
- Pitch-preserving tempo adaptation for compatible local audio
- Play, pause, skip, and finish
- Lock Screen, Control Center, and headphone controls
- A restrained post-run summary
- A developer-only cadence simulator and diagnostics panel
- Local session persistence
- Accessibility support
- A narrow App Intent to open the app ready to run, after the core flow is stable

## 3.2 Version 0.1 excludes

- Apple Music playback
- Spotify
- GPS and maps
- Distance and pace
- Training plans
- Heart-rate coaching
- Apple Watch app
- Live Activity
- Social sharing
- User profiles
- Cloud sync
- Recommendations
- AI features
- Voice features
- Widgets
- Public monetization
- Onboarding carousel
- Full music-library management
- Automatic analysis of every song on the phone

## 3.3 Why Apple Music is not in the first build

Apple permits MusicKit playback and library access, but its current program agreement prohibits modifying MusicKit content and requires standard media controls. Therefore, true tempo adaptation should not be architected around altering Apple Music streams.

Apple Music can later become a separate **Match provider** that chooses tracks near the runner’s cadence without modifying audio. It must not be allowed to distort the first product test.

---

# 4. Architecture decision record

## ADR-001: Deployment target

### Options

**A. iOS 18 or later**

Benefits:
- Broader compatibility
- Easier eventual public distribution

Costs:
- Fallback design system
- More visual and behavioral QA
- Less freedom to use the current platform language cleanly
- More conditional code in a tiny app

**B. iOS 26 or later**

Benefits:
- Native current SwiftUI and system materials
- Cleaner implementation
- One visual language
- Less compatibility work
- Better fit for a personal design-led build

Costs:
- Smaller addressable audience
- Requires a recent device

### Decision

**Choose iOS 26 or later for the personal prototype.**

Do not create compatibility abstractions for older releases. Revisit the deployment target only if public distribution becomes a real goal.

Use the latest stable Xcode and SDK installed locally. Do not upgrade to a beta toolchain unless a required API is unavailable and the user explicitly approves.

---

## ADR-002: Playback model

### Option A: Apple Music cadence matching

The app reads a playlist, knows or calculates track BPM, and queues songs that fit current cadence.

Benefits:
- Low music-library friction
- Familiar catalog
- Easy user value

Costs:
- Does not recreate the central Weav sensation
- Cannot safely depend on modifying streamed content
- Track changes happen at song boundaries
- BPM metadata quality becomes a separate product problem

### Option B: Arbitrary local-file time stretching

The user imports DRM-free music and the app changes rate while preserving pitch.

Benefits:
- Recreates the essential adaptive sensation
- Fully local
- No streaming dependency
- User controls musical taste

Costs:
- Import friction
- Arbitrary songs tolerate stretching differently
- BPM and beat-grid analysis can be unreliable
- Poorly prepared tracks may sound visibly worse

### Option C: Prepared adaptive soundtrack

The app ships with a tiny set of licensed or royalty-free tracks selected and prepared for adaptation. Each track has known BPM, beat offset, safe rate range, and energy metadata.

Benefits:
- Most reliable first experience
- Best audio quality
- Beat-aware visuals
- No setup before the first run
- Makes the product test about interaction, not library plumbing

Costs:
- Tiny catalog
- Requires music sourcing
- Not yet the user’s own taste

### Decision

**Use Option C plus a limited form of Option B.**

Version 0.1 ships with a prepared demo pack of approximately five excellent tracks and supports DRM-free file import as an experimental secondary path.

Create a playback-provider boundary from day one:

```swift
protocol PlaybackProvider: Sendable {
    var capabilities: PlaybackCapabilities { get }

    func prepare(collection: MusicCollection) async throws
    func play() async throws
    func pause() async
    func resume() async throws
    func skip() async throws
    func stop() async
    func setTempoTarget(_ target: TempoTarget) async
    func events() -> AsyncStream<PlaybackEvent>
}
```

Initial provider:

```text
AdaptiveLocalPlaybackProvider
```

Later provider:

```text
AppleMusicMatchPlaybackProvider
```

Do not implement the later provider until the local adaptive experience passes the product acceptance test.

---

## ADR-003: Cadence sensing

### Option A: CMPedometer cadence

Benefits:
- High-level system signal
- Small implementation surface
- Better privacy and battery posture
- Good initial reliability

Costs:
- Some latency
- Limited control over the signal
- Performance may vary by phone placement

### Option B: Raw accelerometer and gyroscope model

Benefits:
- Potentially lower latency
- Full control
- Opportunity for better step phase

Costs:
- Considerably more signal-processing work
- Placement sensitivity
- Battery cost
- Easy to build something that looks responsive but is wrong

### Option C: Apple Watch workout sensing

Benefits:
- Sensor attached to the body
- Strong long-run platform fit
- Better workout lifecycle

Costs:
- Separate target and UX
- More permissions
- More state synchronization
- Doubles the early QA surface

### Decision

**Start with CMPedometer behind a provider protocol.**

```swift
protocol CadenceProvider: Sendable {
    func start() async throws
    func stop() async
    func samples() -> AsyncStream<CadenceSample>
}
```

Implement:

```text
PedometerCadenceProvider
SimulatedCadenceProvider
RecordedFixtureCadenceProvider
```

Only build a raw-motion provider if real-device testing proves that system cadence latency breaks the experience. Only build a Watch provider after the iPhone product is worth extending.

---

## ADR-004: State architecture

### Option A: Conventional screen-level MVVM

Benefits:
- Familiar
- Fast to begin

Costs:
- Tends to mix UI, audio, sensor, and lifecycle state
- Difficult to reason about interruptions
- Easy to create boolean-state combinations that should be impossible

### Option B: Full third-party reducer framework

Benefits:
- Strong determinism
- Excellent testability
- Explicit effects

Costs:
- Too much conceptual and dependency weight for this app
- Framework conventions may dominate a tiny product
- Slower visual iteration

### Option C: Functional core, actor shell

A pure reducer governs valid state transitions. Actors own concurrent side effects such as motion and audio. SwiftUI observes a narrow presentation snapshot.

Benefits:
- Explicit behavior
- Easy fixture testing
- Safe audio and sensor serialization
- No third-party architecture dependency
- Small enough to understand completely

Costs:
- Requires discipline
- A little more initial modeling than ad hoc view models

### Decision

**Choose functional core, actor shell.**

Core pieces:

```text
RunState
RunEvent
RunReducer
RunEffect
RunCoordinator
CadenceEngine actor
AdaptiveAudioEngine actor
SessionStore actor
RunPresentationModel @Observable @MainActor
```

The reducer is pure. It decides transitions and emits effects. The coordinator executes effects and feeds results back as events.

Do not build a view model for every view. Do not put AVAudioEngine calls inside an observable UI model.

---

## ADR-005: BPM and beat metadata

### Option A: Analyze every track on-device

Benefits:
- Self-contained
- Good eventual user experience

Costs:
- Signal-processing complexity
- CPU and battery cost
- Hard to validate quickly
- Beat-one detection is harder than BPM estimation

### Option B: Depend on remote metadata

Benefits:
- Fast implementation if a dependable source exists

Costs:
- Backend and network dependency
- Licensing and coverage problems
- Fragile product foundation

### Option C: Sidecar metadata for prepared tracks, desktop preprocessing for imports

Benefits:
- Deterministic demo experience
- Easy to inspect and correct
- Keeps iPhone app small
- Creates a clean route to better analysis later

Costs:
- Imported tracks need preprocessing
- Not seamless for public release

### Decision

**Use sidecar manifests now. Build a small macOS command-line preprocessing tool inside the repository for imported files.**

Track metadata:

```swift
struct AdaptiveTrackManifest: Codable, Sendable, Identifiable {
    let id: String
    let filename: String
    let title: String
    let artist: String
    let baseBPM: Double
    let firstBeatOffsetSeconds: Double
    let beatsPerBar: Int
    let safeRateRange: ClosedRange<Double>
    let energy: Double
    let artworkAssetName: String?
    let source: TrackSource
}
```

The preprocessing tool may use a proven audio-analysis library if necessary, but the iPhone app must not take a large dependency for the initial build. Any automatically generated result must be editable in JSON.

---

## ADR-006: Visual rendering

### Option A: Static SwiftUI shapes and standard animations

Benefits:
- Simple
- Accessible
- Stable

Costs:
- May not create enough sensorial presence

### Option B: SwiftUI Canvas and a monotonic beat clock

Benefits:
- Fine control
- Native
- Efficient when kept simple
- Easy to create restrained physical motion
- No asset pipeline

Costs:
- Requires careful performance work
- Easy to overanimate

### Option C: Metal shader-led interface

Benefits:
- Rich material effects
- High visual ceiling

Costs:
- Unnecessary complexity
- More power consumption
- Can become visual theater
- Harder to maintain and tune

### Decision

**Use SwiftUI Canvas only for the central tempo surface.**

Use ordinary SwiftUI for layout and controls. Do not introduce Metal unless profiling proves a specific visual cannot be achieved smoothly otherwise.

Do not use Lottie, Rive, animation JSON, or a third-party component library.

---

## ADR-007: Persistence

### Decision

Do not use a database in version 0.1.

Persist:

- Last selected collection
- Last stable cadence
- Imported track manifests
- Small run summaries
- User preferences
- Optional local diagnostics

Use Codable files or a tiny repository abstraction over app storage. Add SwiftData only if the model becomes relational or queries become meaningful.

---

## ADR-008: System surfaces

### Include now

- Audio background mode
- Now Playing metadata
- Remote play, pause, and skip
- Headphone controls
- One narrow App Intent after the main experience works

### Defer

- Live Activity
- Dynamic Island UI
- Widget
- Apple Watch app
- Siri voice dialogue

### Reasoning

Now Playing already owns the appropriate Lock Screen media surface. A separate Live Activity risks duplicate controls and visual clutter. The best first system-level extension is a single action:

> Start In Step

The intent should open the app directly into the ready state with the last collection selected. It must reuse the same run coordinator, not create a parallel execution path.

---

# 5. Product experience

## 5.1 Information architecture

There is no tab bar.

The app has one primary spatial surface and a few transient layers:

```text
Ready
  -> Preparing
  -> Listening for stride
  -> Running
  -> Paused
  -> Finishing
  -> Summary
```

Music selection, settings, and diagnostics are sheets. They are not destinations in a navigation hierarchy.

## 5.2 First launch

Do not show an onboarding carousel.

Show the ready screen with the bundled demo pack already selected. Add one sentence beneath the primary action:

> Start moving. The music will find your stride.

When Start is tapped, request Motion & Fitness permission in context. Explain the request only if the system denies it.

Do not request notifications, location, Health, contacts, tracking, or Apple Music access.

## 5.3 Ready screen

### Content

- Small working-title mark near the top
- Selected collection artwork
- Collection title
- One primary Start control
- Small source/change control
- Optional fixed-rhythm disclosure
- No recent-run cards
- No statistics

### Suggested copy

```text
IN STEP

Run with
Night Motion

[ Start ]

Follow my stride
```

The working-title mark should be visually quiet. The selected music is the hero.

## 5.4 Start interaction

The Start action should feel committed but immediate.

### Touch down

- Primary surface compresses approximately 2 percent
- Shadow or optical elevation collapses
- Label shifts by less than one point
- One light impact haptic
- No glowing ring

### Release

- The collection artwork expands into the atmospheric background
- The Start control transforms into the tempo aperture
- The music begins at the track’s base rate
- Supporting copy becomes:

> Listening for your stride

Do not introduce a countdown unless real-world testing shows that cadence acquisition is impossible without one.

## 5.5 Acquiring cadence

The app should feel attentive, not confused.

The tempo aperture is visibly incomplete: a small gap travels slowly around its circumference. This is not a loading spinner. It is a quiet sign that the system has not closed the loop yet.

Music continues at base rate.

When confidence crosses the lock threshold:

- The gap closes
- The aperture settles into beat-synchronous motion
- A soft success haptic occurs once
- The cadence number appears briefly for approximately 1.2 seconds
- The copy dissolves
- No toast appears
- No spoken cue occurs

## 5.6 Running state

The resting screen contains:

- Atmospheric background derived from artwork
- Tempo aperture
- Track title
- Artist
- Elapsed time, very quiet
- No visible transport controls
- No persistent cadence number

### Tempo aperture

This is the signature object.

It is not a glowing orb, waveform, equalizer, heart, speedometer, or generic pulsing blob.

It is a precise circular aperture with:

- A fine outer contour
- A gently textured interior
- A small physical compression on beat
- A tiny secondary recovery after the beat
- A visual phase driven by the audio clock, not a free-running UI timer

State expression:

- **Acquiring:** open contour gap with slow travel
- **Locked:** complete circle with stable rhythmic compression
- **Adapting:** circle becomes subtly tensioned vertically, then returns
- **Paused:** motion settles over one beat and remains still
- **Interrupted:** contour dims without flashing
- **Cadence temporarily lost:** maintain the last stable rhythm; do not show an error
- **Audio route lost:** pause and show a concise recovery message

The movement should be visible in peripheral vision but uninteresting to stare at.

## 5.7 Revealing controls

A tap anywhere outside the finish region reveals controls.

The aperture moves slightly upward and scales down. Transport controls emerge from the same visual layer below it:

```text
Restart/previous    Pause/play    Skip
```

A quiet Finish control appears beneath.

Controls hide after inactivity, but never while VoiceOver focus is inside them.

Do not use an opaque card over the interface. Do not blur the whole screen to show controls.

## 5.8 Pause

Pause should feel like the surface losing energy.

- Audio pauses immediately
- Visual motion completes its current recovery and stops
- Pause control becomes Resume through shape continuity
- A medium haptic confirms the state
- The screen shows “Paused” quietly

On resume:

- Audio returns first
- Visual phase reanchors to the audio clock
- Cadence reacquisition begins without reverting the entire screen to a loading state
- Use the last stable cadence as a temporary prior

## 5.9 Traffic lights and brief stops

Do not pause automatically.

Behavior:

1. Hold the last stable rate for a short grace interval.
2. If the stop persists, ease slowly toward the track’s base rate.
3. Keep the music playing.
4. When running resumes, reacquire and adapt over several beats.
5. Do not display “cadence lost.”

Initial values to tune on-device:

- Grace interval: 6 seconds
- Return-to-base duration: 10 to 16 seconds
- Resume confirmation: 3 stable samples
- Dead zone: approximately 2 steps per minute

These are starting points, not sacred constants.

## 5.10 Finish

A quick tap must not accidentally end a run.

- Tap Finish
- The control transforms in place to “Hold to finish”
- Pressing fills the control from the touch point
- Releasing before completion returns naturally
- Successful completion has one firm haptic
- Audio eases down over a brief, musical fade
- The running surface contracts back toward the artwork

Do not use a system alert.

## 5.11 Summary

The summary should feel like a coda, not a dashboard.

Show:

```text
32:18

171 average cadence
84% in step

4 songs
```

Primary action:

```text
Done
```

Secondary action, only if imported or bundled tracks were used:

```text
View songs
```

No chart, map, achievement, percentile, calorie estimate, pace, or celebratory animation.

### Metric definition

**Time in step** is the percentage of confident running time during which the selected musical mapping remained within the configured cadence tolerance.

Do not count:

- Paused time
- Sensor-acquisition time
- Long stops
- Samples below the confidence floor

Make this metric deterministic and unit tested.

---

# 6. Visual language

## 6.1 Character

The app is:

- Musical
- Tactile
- Calm
- Editorial
- Warm
- Precise
- Slightly mysterious
- Native to iPhone without looking like a settings screen

The app is not:

- Athletic-tech blue
- Neon
- Cyber
- Glass everywhere
- Luxury black-and-gold
- A meditation app
- A DJ interface
- A health dashboard
- A generic AI gradient

## 6.2 Typography

Use San Francisco.

Rules:

- Tabular numerals for time and cadence
- Few weights
- Never use uppercase for ordinary controls
- Avoid tiny low-contrast captions
- Prefer optical hierarchy through spacing and scale
- No custom typeface in version 0.1

## 6.3 Color

Derive the environment from collection artwork, but do not let poor artwork destroy legibility.

Create a deterministic palette pipeline:

1. Downsample artwork off the main thread
2. Extract several dominant samples
3. Reject colors outside legibility constraints
4. Reduce saturation where necessary
5. Choose a background field
6. Choose an aperture tint
7. Choose foreground text colors
8. Validate contrast
9. Fall back to a warm near-black and soft ivory

Do not create a random gradient every launch.

The same track should generate the same atmosphere.

## 6.4 Materials

Use native Liquid Glass only for interactive controls that visibly sit above content:

- Start control
- Revealed transport controls
- Compact source selector
- Confirmation state for Finish

Do not apply glass to the background, summary, track title, aperture, or every container.

Glass communicates an interactive layer. It is not the visual identity.

## 6.5 Layout

Optimize for one-handed use while running:

- Primary controls in the lower half
- Finish separated from transport controls
- 44-point minimum targets, preferably larger
- No precision sliders during a run
- No edge-swipe-only actions
- Respect safe areas and Dynamic Type

## 6.6 Motion tokens

Centralize semantic motion rather than scattering durations.

```swift
enum MotionToken {
    static let immediate = Duration.milliseconds(90)
    static let control = Duration.milliseconds(180)
    static let transition = Duration.milliseconds(420)
    static let settle = Duration.milliseconds(650)
}
```

Use springs by intent:

- **Contact:** fast, little overshoot
- **Reveal:** slightly softer
- **Transformation:** critically damped or near-critical
- **Atmosphere:** slow and nearly invisible

Every animation must be interruptible.

Do not stack unrelated animations on one state change.

## 6.7 Haptics

Allowed:

- Start touch
- Cadence lock
- Pause
- Resume
- Finish completion
- Material audio-route recovery

Forbidden:

- Every step
- Every beat
- Every track change
- Control reveal
- Minor cadence drift
- Decorative success patterns

## 6.8 Sound effects

Do not add UI sound effects over music.

## 6.9 Accessibility

Implement from the first screen:

- VoiceOver labels and actions
- Reduce Motion behavior
- Dynamic Type
- Sufficient contrast independent of artwork
- No state communicated only by color
- Large hit targets
- Clear permission-denied recovery
- Controls remain visible while VoiceOver is active
- Static aperture states when Reduce Motion is enabled
- Haptics are never the only confirmation

Under Reduce Motion:

- No artwork zoom
- No rhythmic scale pulse
- Use subtle opacity and contour-weight changes
- Preserve state continuity without large movement

---

# 7. Audio system

## 7.1 Engine graph

Use:

```text
AVAudioPlayerNode
    -> AVAudioUnitTimePitch
    -> Main mixer
    -> Output
```

Own the graph inside an actor or a strictly serialized service.

Do not mutate the audio graph from SwiftUI.

## 7.2 Audio session

Configure the app as a playback experience:

- Playback category
- Background audio entitlement
- Appropriate route behavior
- Interruption handling
- Route-change handling
- Remote command support
- Now Playing metadata

Handle:

- Incoming calls
- Siri interruptions
- AirPods disconnect
- Bluetooth route change
- Another app taking audio focus
- System media-service reset
- App backgrounding
- Screen locking

## 7.3 Rate adaptation

Use pitch-preserving time stretching.

Starting constraints:

- Preferred rate range: 0.94 to 1.06
- Soft extended range: 0.90 to 1.10
- Never exceed a track’s manifest-defined safe range
- Pitch remains at zero cents
- Rate changes are ramped
- No audible discontinuities
- No reconfiguration of the graph during normal adaptation

### Adaptation planner

The cadence engine should not write raw values directly to the audio unit.

Create:

```swift
struct TempoTarget: Sendable, Equatable {
    let sourceCadenceSPM: Double
    let musicalBPM: Double
    let mapping: CadenceMapping
    let desiredRate: Double
    let confidence: Double
}

enum CadenceMapping: String, Codable, Sendable {
    case oneStepPerBeat
    case twoStepsPerBeat
    case experimentalThreeStepsPerTwoBeats
}
```

Version 0.1 enables only:

- One step per beat
- Two steps per beat

Keep the 3:2 mapping behind a developer experiment flag.

### Mapping selection

Score candidates using:

- Distance from track’s base BPM
- Required rate change
- Stability relative to current mapping
- Track safe range
- Recent mapping changes

Penalize mapping switches heavily. A stable slightly imperfect relationship is better than repeated mathematically optimal switches.

## 7.4 Rate ramp

Do not set rate continuously for every sample.

Generate a rate plan:

```swift
struct RateRampPlan: Sendable, Equatable {
    let from: Double
    let to: Double
    let duration: Duration
    let curve: RampCurve
}
```

Initial behavior:

- Ignore changes inside dead zone
- Confirm a meaningful change over multiple samples
- Ramp small changes over 2 to 4 seconds
- Ramp larger safe changes over 4 to 8 seconds
- Cancel and recompute gracefully if cadence changes during a ramp
- Anchor visual rhythm to the effective audio rate

Use a monotonic clock and small scheduled steps if the audio unit does not provide a native ramp that meets quality requirements.

## 7.5 Beat clock

For prepared tracks, sidecar metadata includes the first-beat offset.

Create an `AudioBeatClock` that derives:

- Current beat index
- Beat phase from 0 to 1
- Bar index
- Effective BPM after rate
- Confidence in phase

Do not drive the UI with a repeating Timer.

Visual updates may be presented with `TimelineView` or a display-linked mechanism, but phase must be derived from a monotonic audio anchor.

When the app pauses, preserve the correct phase relationship for resume.

## 7.6 Track transitions

Version 0.1 can use short, tasteful crossfades.

Rules:

- Preload the next player node or buffer
- Do not wait until the track ends to decode
- Use manifest cue points if available
- Avoid DJ-style effects
- Preserve energy continuity
- Reset visual phase cleanly at the new track’s known beat offset
- Do not change tracks merely because cadence briefly changes

## 7.7 Imported audio

Use a document picker and copy security-scoped files into app-managed storage after explicit user selection.

Supported initial formats should match formats reliably decoded by AVFoundation.

For each imported file:

1. Copy into app storage
2. Run or request preprocessing
3. Validate manifest
4. Mark confidence
5. Show a simple compatibility result

Possible statuses:

```text
Ready
Usable, limited range
Needs beat correction
Unsupported
```

Do not expose audio-engine terminology to the user.

---

# 8. Cadence system

## 8.1 Raw sample

```swift
struct CadenceSample: Codable, Sendable, Equatable {
    let timestamp: ContinuousClock.Instant
    let stepsPerMinute: Double?
    let source: CadenceSource
    let isMoving: Bool
    let sourceConfidence: Double
}
```

If `ContinuousClock.Instant` complicates fixture encoding, create a separate codable elapsed-time representation for fixtures.

## 8.2 Processing pipeline

```text
Raw sample
  -> freshness check
  -> plausible-range check
  -> rolling median
  -> exponential smoothing
  -> variance calculation
  -> movement-state inference
  -> confidence score
  -> cadence state machine
  -> tempo target planner
```

## 8.3 Plausibility

Initial ranges:

- Walking: approximately 70 to 135 SPM
- Running candidate: approximately 120 to 220 SPM
- Treat overlaps as uncertain rather than forcing a hard classification
- Reject impossible jumps unless sustained
- Reject stale samples
- Preserve last stable value for graceful degradation

These values must be tuned through real runs.

## 8.4 Confidence

Confidence should incorporate:

- Source confidence
- Sample freshness
- Recent variance
- Number of recent valid samples
- Movement continuity
- Agreement between raw and smoothed values

Represent confidence as a continuous value internally.

UI state uses thresholds with hysteresis:

```text
acquiring -> locked at high threshold
locked -> uncertain at lower threshold
uncertain -> lost after time threshold
```

Do not use one threshold for entry and exit.

## 8.5 Domain state

```swift
enum CadenceState: Sendable, Equatable {
    case unavailable
    case awaitingPermission
    case acquiring(priorSPM: Double?)
    case locked(spm: Double, confidence: Double)
    case adapting(fromSPM: Double, toSPM: Double, confidence: Double)
    case uncertain(lastStableSPM: Double)
    case stopped(lastStableSPM: Double)
}
```

## 8.6 Fixtures

Create JSON fixtures for:

- Steady 168 SPM run
- Noisy pocket at 168 SPM
- Warm-up walk into run
- Gradual 160 to 176 SPM progression
- Sudden sprint
- Traffic-light stop
- Repeated short stops
- Sensor dropout
- Implausible spike
- Phone moving while user is stationary
- Run with cadence oscillation
- Permission denied
- Motion unavailable

The same fixtures must drive unit tests and the developer simulator.

---

# 9. Domain state machine

## 9.1 Run phase

```swift
enum RunPhase: Sendable, Equatable {
    case ready
    case preparing
    case acquiring
    case running
    case paused
    case interrupted(InterruptionReason)
    case finishing
    case summary(RunSummary)
    case failed(RecoverableRunError)
}
```

## 9.2 Events

```swift
enum RunEvent: Sendable, Equatable {
    case startTapped
    case permissionsResolved(MotionAuthorization)
    case audioPrepared
    case preparationFailed(RecoverableRunError)
    case cadenceUpdated(CadenceState)
    case playbackEvent(PlaybackEvent)
    case controlsTapped
    case controlsTimedOut
    case pauseTapped
    case resumeTapped
    case finishRequested
    case finishHoldCompleted
    case interruptionBegan(InterruptionReason)
    case interruptionEnded(shouldResume: Bool)
    case audioRouteChanged(AudioRouteChange)
    case applicationPhaseChanged(ApplicationPhase)
    case summaryDismissed
}
```

## 9.3 Reducer

```swift
struct RunReducer {
    func reduce(
        state: RunState,
        event: RunEvent
    ) -> (RunState, [RunEffect])
}
```

Required properties:

- Pure
- Deterministic
- Exhaustively tested
- No framework imports beyond Foundation
- Invalid transitions produce no side effect and log a debug assertion
- No multiple booleans for mutually exclusive states

## 9.4 Effects

Examples:

```swift
enum RunEffect: Sendable, Equatable {
    case requestMotionPermission
    case prepareAudio
    case startCadence
    case beginPlayback
    case pausePlayback
    case resumePlayback
    case applyTempoTarget(TempoTarget)
    case fadeAndStop
    case publishNowPlaying
    case scheduleControlsTimeout
    case cancelControlsTimeout
    case persistSummary
    case emitHaptic(HapticEvent)
}
```

## 9.5 Coordinator

`RunCoordinator` is responsible for:

- Owning services
- Executing effects
- Feeding effect results back as events
- Enforcing cancellation
- Managing task lifetimes
- Publishing a small presentation snapshot

No view should independently start motion updates or audio tasks.

---

# 10. Project structure

Use one Xcode app project plus a local Swift package so that domain code, design components, previews, and tests remain isolated and easy for Codex to inspect.

```text
InStep/
  InStep.xcodeproj
  App/
    InStepApp.swift
    AppEnvironment.swift
    RootView.swift
    AppIntentRouter.swift
  Packages/
    InStepKit/
      Package.swift
      Sources/
        InStepDomain/
        InStepMotion/
        InStepAudio/
        InStepDesign/
        InStepDiagnostics/
      Tests/
        InStepDomainTests/
        InStepMotionTests/
        InStepAudioTests/
  Resources/
    DemoTracks/
    TrackManifests/
    Artwork/
    Fixtures/
  Tools/
    TrackPrepCLI/
  Docs/
    PRODUCT.md
    ARCHITECTURE.md
    DECISIONS.md
    TESTING.md
    DEVICE_RUNBOOK.md
    APP_REVIEW_NOTES.md
  AGENTS.md
  README.md
```

## Module boundaries

### InStepDomain

Pure Swift:

- Run state
- Reducer
- Cadence smoothing
- Confidence
- Mapping selection
- Rate planning
- Summary calculation
- Fixtures

No SwiftUI, CoreMotion, AVFoundation, or MediaPlayer imports.

### InStepMotion

- `CadenceProvider`
- CMPedometer adapter
- Simulated provider
- Recorded-fixture provider
- Permission mapping

### InStepAudio

- Playback provider protocol
- Adaptive local engine
- Audio session
- Beat clock
- Now Playing adapter
- Remote commands
- Track decoding and preload
- Interruption and route-change mapping

### InStepDesign

- Ready screen components
- Tempo aperture
- Transport controls
- Summary
- Motion tokens
- Type and spacing tokens
- Palette extraction
- Previews for every state

This package should be importable into SwiftUI preview tooling.

### InStepDiagnostics

Debug-only:

- Fixture picker
- Cadence slider
- Raw and smoothed values
- Confidence
- Current mapping
- Audio rate
- Beat phase
- Audio route
- State and latest event
- Local log export

Compile it out of Release where practical.

---

# 11. Design system

## 11.1 Tokens

Create a very small semantic token set.

```swift
enum Space {
    static let x1: CGFloat = 4
    static let x2: CGFloat = 8
    static let x3: CGFloat = 12
    static let x4: CGFloat = 16
    static let x6: CGFloat = 24
    static let x8: CGFloat = 32
    static let x12: CGFloat = 48
}
```

Do not create a giant abstract design-system framework.

## 11.2 Components

Keep components narrow:

```text
CollectionArtwork
PrimaryStartControl
TempoAperture
TrackIdentity
TransportCluster
FinishControl
RunSummaryCard
SourcePicker
PermissionRecoveryView
DiagnosticsOverlay
```

Each component requires:

- A preview
- VoiceOver label if interactive
- Reduce Motion preview where relevant
- Light and dark appearance check
- At least one extreme-content preview
- No service calls

## 11.3 Preview matrix

Create previews for:

- Ready, demo pack
- Ready, imported collection
- Acquiring
- Locked at low cadence
- Locked at high cadence
- Adapting
- Controls visible
- Paused
- Interruption
- Headphones disconnected
- Summary
- Motion permission denied
- Reduce Motion
- Extra-extra-large Dynamic Type
- High contrast
- Long track and artist names
- Missing artwork

---

# 12. Copy system

Use plain, restrained language.

## Approved copy

```text
Start
Run with
Follow my stride
Hold a rhythm
Listening for your stride
Paused
Resume
Hold to finish
Motion access is off
Open Settings
Headphones disconnected
Music paused
Try again
Done
View songs
Time in step
```

## Avoid

```text
Let’s crush it
Your AI-powered run
Optimizing your performance
Analyzing biometrics
Great job!
New personal best
Keep your streak alive
Unlock Pro
Premium experience
Smart cadence
Magic mode
```

Do not anthropomorphize the app.

---

# 13. Permissions and failure behavior

## Motion permission denied

Do not dead-end.

Show:

> Motion access is off  
> In Step uses step rhythm to adapt the music.

Actions:

- Open Settings
- Use fixed rhythm

Fixed rhythm is a legitimate fallback, not an error demo.

## Audio file unavailable

- Skip safely if another track exists
- Explain only when playback cannot continue
- Never crash because a security-scoped URL expired

## Headphones disconnect

Default:

- Pause immediately
- Show “Headphones disconnected”
- Resume only after explicit user action or a clearly safe route restoration

Do not blast music through the phone speaker during a run.

## Phone call or Siri

- Respect system interruption
- Preserve session
- Resume only if the system indicates resumption is appropriate
- Reanchor visual phase
- Reacquire cadence quietly

## Motion temporarily lost

- Keep music playing
- Hold stable rate
- Drift toward base only after grace period
- No warning unless the state persists long enough to materially affect the product

## App killed

Version 0.1 does not need perfect run restoration after process termination. Persist enough state to show a calm recovery message and save any valid summary data.

---

# 14. Privacy and diagnostics

## Production privacy

- No account
- No backend
- No analytics SDK
- No tracking
- No location
- No advertising
- No remote logging
- No contact or Health access
- No model inference
- No listening-history upload

## Diagnostics

Use unified logging and signposts locally.

Log categories:

```text
run-state
cadence
tempo-plan
audio-engine
audio-route
interruption
now-playing
performance
```

Do not log full file paths or unnecessary user data.

Add a user-initiated “Export diagnostics” action inside a hidden developer screen. Export:

- App and OS version
- Device model
- Sanitized state transitions
- Cadence fixture or redacted cadence samples
- Audio route events
- Error codes
- Performance signposts

---

# 15. Testing strategy

## 15.1 Unit tests

Use Swift Testing for pure domain logic where supported by the installed toolchain.

Test:

- Smoothing
- Outlier rejection
- Confidence hysteresis
- Stop behavior
- Mapping selection
- Mapping stability
- Rate clamps
- Rate-ramp cancellation
- Time-in-step
- Reducer transitions
- Invalid transitions
- Summary exclusion rules

Use parameterized tests across cadence fixtures.

## 15.2 Audio tests

Automated tests should verify:

- Engine prepares
- File decode succeeds
- Rate target is clamped
- Pause and resume preserve state
- Skip releases old nodes
- Interruption state maps correctly
- Route loss does not auto-resume unsafely

Do not claim audio quality is proven by unit tests. Audio quality requires listening.

## 15.3 UI tests

Create a deterministic launch argument:

```text
-INSTEP_USE_SIMULATED_CADENCE YES
-INSTEP_FIXTURE steady-168
-INSTEP_USE_DEMO_AUDIO YES
```

Golden-path UI test:

1. Launch ready
2. Start
3. Acquire cadence
4. Verify locked state
5. Reveal controls
6. Pause
7. Resume
8. Skip
9. Finish with hold
10. Verify summary
11. Dismiss

Additional tests:

- Permission denial
- Audio-route loss
- Reduced Motion
- Large text
- Missing artwork
- Failed track

## 15.4 Visual QA

Do not rely only on screenshots.

Review:

- Touch-down state
- Release state
- Interrupted transition
- Fast repeated taps
- Rotation policy
- Lock and unlock
- Background and foreground
- Text truncation
- Sunlight legibility
- One-handed reach
- Motion at actual running glance duration

## 15.5 Device matrix

Simulator:

- Current standard iPhone
- Smallest supported screen
- Largest supported screen
- Light and dark
- Accessibility sizes

Physical device:

- The user’s primary iPhone
- AirPods or intended running headphones
- Screen locked
- Phone in front pocket
- Phone in hand
- Phone in running belt, if used
- Low Power Mode
- Cellular and airplane mode
- Thirty-minute continuous session

## 15.6 Real-run protocol

Codex must not declare the cadence engine validated from simulator data.

For each physical run, record:

- Phone placement
- Headphones
- Route interruptions
- Time to first lock
- Lock stability
- Perceived music response
- Distracting rate changes
- Stoplight behavior
- Battery delta
- Any accidental interaction

Minimum acceptance set:

- Three steady runs
- One interval-like run
- One run with several stops
- One thirty-minute session

---

# 16. Performance budgets

These are product budgets, not marketing claims.

- Ready screen should become interactive immediately after launch
- No audio work on the main thread
- No artwork analysis on the main thread
- No repeated image extraction during a run
- Stable animation at the device’s normal refresh rate
- No continuous high-cost blur stack
- No unbounded task creation from cadence samples
- No retained audio nodes after track changes
- No significant memory growth across a thirty-minute session
- Sensor processing should be negligible relative to playback

Profile focused flows:

1. Cold launch to ready
2. Start to first rendered running frame
3. Cadence lock transition
4. Controls reveal
5. Track transition
6. Thirty-minute playback memory stability

Use code-first SwiftUI review, then runtime traces when needed.

---

# 17. Codex operating instructions

## 17.1 Use available capabilities aggressively but deliberately

Codex should use all locally available iOS development skills and tools, including:

- SwiftUI UI patterns
- SwiftUI Liquid Glass guidance
- iOS Simulator Browser
- iOS Debugger Agent
- XcodeBuildMCP
- SwiftUI performance audit
- ETTrace performance profiling
- Memory-graph tooling when leaks are suspected
- App Intents guidance
- Appshots
- Subagents
- Git worktrees
- Record & Replay, if available
- Local browser and screenshot comparison

Do not merely mention these tools. Use them and preserve evidence.

## 17.2 AGENTS.md

Create `AGENTS.md` before implementation with these rules:

```markdown
# In Step repository instructions

## Product
- This is a minimal body-aware music player, not a fitness platform.
- Do not add features not present in PRODUCT.md.
- The shipped app contains no AI or network dependency.
- Interaction quality and reliable audio behavior outrank feature breadth.

## Architecture
- Keep InStepDomain free of UI and Apple media frameworks.
- Use the functional-core, actor-shell architecture in ARCHITECTURE.md.
- Do not introduce a production dependency without documenting why.
- Do not call audio or motion services directly from SwiftUI views.
- Represent mutually exclusive states with enums, not boolean clusters.

## Design
- Use native SwiftUI.
- Use Liquid Glass sparingly and only for interactive raised controls.
- Do not add neon gradients, fake waveforms, glowing orbs, dashboards, cards, or decorative charts.
- Every interactive component needs accessibility labels and previews.
- Every animation must be interruptible and respect Reduce Motion.

## Validation
- Build after each coherent change.
- Run relevant unit tests after domain changes.
- Verify every visual milestone in a real Simulator frame.
- Capture screenshots before claiming UI completion.
- Do not claim cadence quality without physical-device evidence.
- Do not claim audio quality without a listening check.
- Keep Docs/DECISIONS.md and Docs/TESTING.md current.

## Scope discipline
- When a requested implementation implies new scope, stop and record it under Deferred rather than silently adding it.
```

Verify that Codex reports the loaded instruction sources before beginning.

## 17.3 Worktrees

Create bounded worktrees for independent spikes:

```text
spike/interaction-prototype
spike/cadence
spike/adaptive-audio
```

Do not merge all spikes automatically.

Each spike must return:

- What was proven
- What failed
- API constraints
- Screenshots or recordings
- Tests
- Recommended merge or discard decision

After decisions are made, implement the product cleanly on the main feature branch rather than merging experimental debris.

## 17.4 Subagents

Use subagents for independent, read-heavy work:

- Apple API and entitlement verification
- Audio-engine reliability review
- State-machine and cancellation review
- Accessibility review
- Test-gap review
- Performance review

Avoid having several agents edit the same files concurrently.

The main agent owns:

- Product decisions
- Final architecture
- Integration
- Visual consistency
- Release criteria

## 17.5 Appshots

Use Appshots to send the frontmost Xcode Preview, Simulator, Instruments window, error panel, or visual reference into the active task.

At each visual milestone:

1. Bring the exact Simulator or Preview state to the front.
2. Capture an Appshot.
3. Ask Codex to compare it against the product principles and current acceptance criteria.
4. Fix specific issues.
5. Capture a second Appshot.
6. Record the before-and-after decision in the build log.

Appshots are context, not proof by themselves. The app must also build and run.

## 17.6 iOS Simulator Browser

Put the design components and previews in an importable Swift package.

Use the iOS Simulator Browser capability to:

- Launch the preview host
- Mirror the correct Simulator
- Verify a live frame
- Iterate with hot reload
- Inspect every preview state
- Capture browser-visible proof

Do not report success because a preview URL opened. Verify that the Simulator frame is actually rendering.

## 17.7 XcodeBuildMCP and debugger workflow

For each integrated milestone:

1. Discover the booted Simulator.
2. Set project, scheme, configuration, and Simulator defaults.
3. Build and run.
4. Confirm launch with UI inspection or screenshot.
5. Describe the UI before tapping.
6. Exercise the flow using semantic labels where possible.
7. Capture logs around the interaction.
8. Save a screenshot of the resulting state.
9. Run tests.
10. Update the build log.

Use accessibility identifiers for stable automation, but do not expose test-oriented naming to users.

## 17.8 Physical iPhone workflow

When a trusted, connected iPhone and signing identity are available:

- Detect the device through installed Xcode tooling
- Build and install the Debug configuration
- Launch and capture local logs
- Keep a device runbook with exact signing and install steps
- Ask the user only for trust, signing, or physical movement actions that cannot be automated
- Never substitute Simulator cadence evidence for a real run

Appshots can be used on a Mac window showing Xcode device state, a mirrored iPhone screen, logs, or Instruments. Appshots do not themselves control or instrument the phone.

## 17.9 Record & Replay

After the deterministic simulated-cadence flow is stable, record one golden regression workflow:

```text
Launch -> Start -> Lock -> Reveal -> Pause -> Resume -> Skip -> Finish -> Summary
```

Turn it into a reusable local skill if Record & Replay is available. Replay it after meaningful UI refactors.

Do not use recorded computer interaction as the only automated test. Keep XCUITests as the durable source of truth.

## 17.10 Visual review prompt

Use this after each Appshot:

```text
Review this exact rendered state as a senior interaction designer.

Judge only:
1. hierarchy,
2. unnecessary visual elements,
3. material consistency,
4. one-handed usability,
5. typography,
6. state clarity,
7. whether anything looks generic, templated, AI-generated, or overdesigned.

Identify the three highest-impact changes. Do not propose new features or a different visual concept. Preserve the current product thesis.
```

## 17.11 Code review prompt

Use this before completing each milestone:

```text
Review the current diff against PRODUCT.md, ARCHITECTURE.md, AGENTS.md, and the milestone acceptance criteria.

Spawn focused reviewers for:
- state and concurrency,
- audio lifecycle,
- SwiftUI invalidation and performance,
- accessibility,
- tests and failure handling.

Wait for all reviewers. Resolve concrete issues. Do not broaden scope.
```

---

# 18. Build sequence

## Milestone 0: Repository and evidence framework

Deliver:

- Xcode project
- Local Swift package
- AGENTS.md
- Product and architecture docs
- Build log
- Decision log
- Test plan
- Working app shell
- CI or repeatable local test command

Exit criteria:

- Clean build
- Test target runs
- Codex confirms loaded instructions
- Preview package renders
- No production dependency added

## Milestone 1: Interaction prototype

Use:

- Simulated cadence
- Bundled silent or test-safe loop
- Static track metadata
- No Core Motion
- No final audio adaptation

Build the complete flow:

- Ready
- Start transformation
- Acquiring
- Lock
- Running
- Controls
- Pause and resume
- Finish hold
- Summary
- All failure-state visuals
- Accessibility states

Exit criteria:

- Every state has a preview
- Golden UI test passes
- Simulator Browser proof captured
- Appshots before and after refinement
- Reduce Motion works
- No navigation or layout churn
- User can understand the product without explanation

Do not proceed because the code is complete. Proceed only when the interaction feels coherent.

## Milestone 2: Cadence spike

Implement:

- CMPedometer provider
- Permission flow
- Smoothing
- Confidence
- Fixtures
- Diagnostics

Test on physical iPhone.

Exit criteria:

- Time-to-lock measured
- Stable run fixture passes
- Stoplight behavior passes
- Sensor dropout does not destabilize UI
- At least one physical run recorded
- Decision made on whether raw-motion research is necessary

## Milestone 3: Adaptive audio spike

Implement:

- Audio graph
- One prepared track
- Rate changes
- Pitch preservation
- Beat clock
- Interruption handling
- Route change
- Background playback
- Now Playing

Exit criteria:

- No click during safe rate changes
- Screen lock works
- AirPods controls work
- Route disconnect pauses safely
- Pause and resume preserve phase
- Listening notes recorded
- No obvious retained-node growth

## Milestone 4: Integration

Join cadence and audio through `TempoTarget`.

Add:

- Stable mapping
- Rate ramps
- Traffic-light behavior
- Visual phase
- Session summary
- Five-track demo pack
- Track transitions

Exit criteria:

- Full golden flow passes
- Thirty-minute session stable
- Physical run does not produce distracting tempo hunting
- Visual and audio lock feel causally connected
- App remains legible in daylight
- No debug UI in Release

## Milestone 5: Import and track preparation

Add:

- Files import
- App-managed storage
- TrackPrepCLI
- Manifest validation
- Compatibility state
- Imported collection selection

Exit criteria:

- Imported track survives relaunch
- Missing file failure is safe
- Bad manifest is recoverable
- User-facing copy avoids technical jargon
- Prepared demo pack remains the default first experience

## Milestone 6: System polish

Add:

- Narrow Start App Intent
- Final Now Playing metadata
- Release icon placeholder workflow
- Privacy manifest as required
- App Review notes
- TestFlight configuration

Exit criteria:

- Intent routes correctly
- No duplicate run coordinators
- Release build passes
- Privacy behavior matches documentation
- No subscription or billing code
- No backend configuration

---

# 19. Acceptance criteria

## Product

- Returning user begins with one action
- Music starts promptly
- Cadence uncertainty feels calm
- Lock is perceivable without demanding attention
- The running screen can be understood in a one-second glance
- Controls are available but not persistent
- Finish is difficult to trigger accidentally
- Summary is useful and restrained
- No feature resembles generic fitness SaaS

## Design

- No tab bar
- No dashboard
- No card grid
- No neon
- No fake waveform
- No glowing AI orb
- No gratuitous blur
- No custom font
- No animation without state meaning
- No unexplained icon-only control
- No state communicated only through color
- No visible developer diagnostics in Release

## Cadence

- Stable cadence does not visibly jitter
- Brief noise does not change mapping
- Stoplights do not cause abrupt audio changes
- Cadence loss does not stop music
- Permission denial has a useful fallback
- All processing is local

## Audio

- Rate changes remain inside declared safe range
- Pitch remains stable
- No clicks or gaps during ordinary changes
- Background playback works
- Remote controls work
- Route loss is safe
- Interruptions recover cleanly
- Visual phase derives from audio state

## Engineering

- Pure domain package has comprehensive tests
- Concurrent services are actor-isolated or otherwise strictly serialized
- No unstructured task leaks
- Cancellation behavior is explicit
- No third-party UI framework
- Production dependencies are documented
- Build and test commands are reproducible
- Architectural decisions are recorded
- Physical-device limitations are stated honestly

---

# 20. Deferred ideas

Do not implement these unless the user explicitly reopens scope:

- Apple Music Match provider
- Apple Watch cadence provider
- Raw-motion step-phase provider
- 3:2 rhythm mapping
- Live Activity
- Action Button direct start
- Session history
- HealthKit workout save
- Automatic on-device BPM analysis
- Artist-made adaptive packs
- Public one-time purchase
- Crossfade editor
- Track compatibility editor
- Collaborative playlists

The most promising future expansion is not a feature dashboard. It is a small set of artist-prepared adaptive music packs with explicit beat grids and wider safe tempo ranges.

---

# 21. Public-release posture

This is a personal prototype until proven otherwise.

If it becomes public:

- Prefer a one-time purchase
- Do not add a subscription unless real recurring music-licensing costs require it
- Do not monetize access to Apple Music
- Obtain legal and App Review guidance before adding MusicKit to a paid product
- Keep core playback useful after purchase
- Do not use manipulative trials
- Do not add analytics by default
- Keep the product comprehensible in one sentence

---

# 22. Codex kickoff instruction

Use the following as the first task after placing this document in the repository:

```text
Read this entire repository before changing files, especially AGENTS.md, Docs/PRODUCT.md, Docs/ARCHITECTURE.md, and Docs/DECISIONS.md.

Your job is to build In Step as a native iOS 26 SwiftUI app. It is a minimal, design-led cadence music player. It is not a fitness platform.

Begin with Milestone 0 and Milestone 1 only. Do not connect Core Motion or build the production audio engine yet.

First:
1. inspect the local Xcode and iOS toolchain,
2. report available Codex iOS skills, XcodeBuildMCP tools, Simulator/browser capabilities, Appshots, worktrees, subagents, and physical-device access,
3. create the repository structure and AGENTS.md,
4. write a short implementation plan with explicit acceptance criteria,
5. create an interaction-prototype worktree,
6. build the complete simulated-cadence flow,
7. render every state in SwiftUI previews,
8. run it in a real Simulator,
9. interact with it through the available iOS debugger tooling,
10. capture screenshots and Appshots,
11. critique the rendered result against the design principles,
12. refine it,
13. run tests,
14. update the build and decision logs.

Use subagents for API review, accessibility review, state-machine review, and test-gap review. Avoid parallel agents editing the same files.

Do not claim completion from code inspection. Build, run, interact, capture evidence, and verify.

Do not add any feature not specified for the active milestone.
```

---

# 23. Final standard

The app does not need to look expensive.

It needs to feel inevitable.

A runner opens it, sees their music, presses one control, and moves. The music settles into the body. The interface becomes almost absent.

That is the product.
