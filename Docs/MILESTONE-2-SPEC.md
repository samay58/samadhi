# Milestone 2 specification

## Adaptive audio and playlist import

Status: Ready for implementation

This document is the source of truth for the next build milestone. It replaces the proposed Milestone 2 boundary in `PLAN.md`.

## Problem Statement

Samadhi currently proves that the interaction can feel calm, legible, and coherent. It does not yet do the job the product exists to do. Cadence is simulated, music is silent demo data, and the displayed lock and summary do not come from a physical run or real audio.

A useful version needs both halves of the loop:

- Music the runner already wants to hear
- Real cadence that changes the music without making it sound damaged or unstable

Building playlist browsing without adaptive playback would create a conventional music player. Building adaptive playback around one bundled test file would prove engineering but still leave the product awkward to use. This milestone must connect an imported collection to real cadence and real playback.

Apple Music is the selected production player. Its song metadata does not include tempo, so Samadhi resolves preview audio, analyzes it locally, and applies the result to Apple Music playback. A narrow 12-preview reference corpus now passes. The verified fixture, Core Motion, bounded adaptation, and applied-rate feedback are connected in a focused device configuration. Broad music accuracy, physical response, and long-form reliability remain open product risks.

Tempo matching is also narrower than beat-perfect synchronization. Live pedometer cadence provides steps per minute, not a reliable timestamp for every foot strike. Milestone 2 matches the music's tempo to stable cadence. It does not claim that each footfall lands on a specific beat.

## Solution

The runner chooses one existing collection, presses Start, and begins moving. Samadhi plays real music, acquires real cadence, selects the musically equivalent beat rate for the current track, and gently adjusts playback speed within a conservative range. Once the rate settles, the interface confirms that the tempo is matched and withdraws.

Playlist import comes before playlist generation. Apple Music was selected after the device feasibility work resolved token, tempo-source, playback, Bluetooth routing, and live-rate risk:

- Use Apple Music as the one production playback system.
- Keep long-form background, interruption, route-loss, and listening checks as Milestone 2 completion gates.
- Do not build a local-file player, Spotify player, or second production system in this milestone.

The existing run interface stays recognizable. Ready gains a focused music-selection path. The active run screen reuses its aperture, progress, controls, recovery, and finish behavior. Labels become honest about measured capability.

Milestone 2 is complete only when one imported collection with at least three playable tracks survives a physical outdoor run with real cadence, real audio adaptation, screen lock, pause and resume, route loss, skip, finish, and locally saved evidence.

## User Stories

1. As a runner opening Samadhi for the first time, I want one clear way to choose music, so that I can make the app useful before starting a run.
2. As an Apple Music user, I want Samadhi to request music access only after I choose Apple Music, so that permission appears in context.
3. As an Apple Music user, I want to see my library playlists, so that I can choose music I already know.
4. As a runner, I want to select one playlist rather than build a new queue, so that setup stays brief.
5. As a runner, I want Samadhi to preserve playlist order, so that the collection behaves predictably.
6. As a runner, I want the chosen collection to remain selected after relaunch, so that returning runs still begin with one action.
7. As a runner, I want replacing the selected collection to be explicit, so that setup never changes by surprise.
8. As a runner, I want Samadhi to analyze imported tracks before a run, so that playback does not pause for heavy work while I am moving.
9. As a runner, I want to see simple analysis progress, so that I know whether the collection is ready.
10. As a runner, I want unsupported or uncertain tracks identified plainly, so that Samadhi never silently pretends they are adaptive.
11. As a runner, I want at least one ready track before Start becomes available, so that a run cannot enter a dead playback state.
12. As a runner, I want to change my selected collection from Ready, so that music selection does not require settings or a tab bar.
13. As a runner, I want real music to begin after one Start action, so that the interaction remains immediate.
14. As a runner, I want Samadhi to detect cadence from the iPhone I already carry, so that I do not need another account or sensor.
15. As a runner, I want the app to wait for stable cadence before claiming a match, so that the interface earns my trust.
16. As a runner, I want tempo changes to arrive gradually, so that I feel the music settle rather than hear the software working.
17. As a listener, I want vocals and instruments to retain their pitch, so that adaptive playback still sounds like the original recording.
18. As a runner, I want small gait noise ignored, so that the music does not hunt around my stride.
19. As a runner, I want Samadhi to hold a stable rate when cadence briefly becomes uncertain, so that a few bad samples do not disturb the song.
20. As a runner, I want Samadhi to ease back to normal speed when cadence stays unavailable, so that failure remains calm and honest.
21. As a runner, I want incompatible tracks handled without unsafe stretching, so that audio quality outranks forcing every song into range.
22. As a runner, I want Skip to choose the next usable track in collection order, so that controls remain predictable.
23. As a runner, I want pause to stop cadence work and freeze the current song position, so that the session does not advance while I am stopped.
24. As a runner, I want resume to reacquire cadence using the prior estimate as a starting point, so that returning to rhythm feels quick without faking confidence.
25. As a runner, I want headphone disconnection or audio interruption to pause safely, so that music never restarts unexpectedly.
26. As a runner, I want an explicit Resume after route recovery, so that I remain in control of sound in public.
27. As a runner, I want music and cadence adaptation to continue when the screen locks, so that the phone can stay in my pocket.
28. As a runner, I want the song-progress ring to reflect the actual playing track, so that the visual has a truthful purpose.
29. As a runner, I want the lock confirmation to say that tempo is matched, so that Samadhi does not imply beat-perfect footfall alignment.
30. As a runner, I want the summary to use measured active time, cadence, songs, and tempo-matched time, so that the result describes the run that occurred.
31. As a runner using fixed rhythm after denied motion access, I want the summary to say tempo matching was not measured, so that zero is not confused with failure.
32. As a runner using VoiceOver, Dynamic Type, Reduce Motion, or increased contrast, I want setup and running controls to remain complete, so that production capability does not regress accessibility.
33. As a privacy-conscious runner, I want imported audio, analysis results, and run evidence to remain on device, so that Samadhi does not need its own backend.
34. As a returning runner, I want unchanged tracks to reuse cached analysis, so that relaunch and setup stay fast.
35. As a developer, I want simulation to remain available behind the same interfaces, so that automated tests do not depend on Apple Music, physical motion, or headphones.
36. As a developer, I want stale cadence, analysis, and playback callbacks rejected by identity, so that cancelled work cannot mutate a newer run.
37. As a developer, I want one selected production playback system, so that the codebase does not accumulate two partially reliable audio stacks.
38. As a product owner, I want physical evidence and listening notes before any audio-quality claim, so that the prototype remains honest.

## Implementation Decisions

### Build gates

Work proceeds through gates. A failed gate changes the implementation path before surrounding product work begins.

#### Apple Music feasibility gate

Time-box the first implementation pass to one focused engineering day. Use a physical iPhone and one real library playlist.

The gate passes only if all of the following are true:

- Music authorization succeeds from an explicit user action.
- A library request returns playlists and at least ten tracks from the chosen playlist.
- At least 80 percent of those tracks expose analyzable preview audio or another documented local tempo source.
- `ApplicationMusicPlayer` plays the selected tracks and accepts live rate changes at 0.94, 1.00, and 1.06.
- Rate changes sound pitch-stable and free of clicks, gaps, or obvious warble on the supported headphone route.
- Playback continues for five minutes with the screen locked and background-audio mode enabled.
- Pause, resume, track change, interruption, and route loss can be observed and mapped to the existing state machine.

If any item fails, stop the MusicKit player work. Keep only reusable source-selection or metadata code. Use local file import and `AVAudioEngine` for the production path.

Preview analysis is a technical prototype assumption, not a public-distribution decision. Before App Store work, verify that deriving local tempo metadata from preview assets complies with the current Apple Music terms.

#### Core loop gate

Before building the final import surface, prove one known-tempo track end to end:

- Real cadence enters through Core Motion.
- The pure adaptation policy produces a bounded target rate.
- The selected production player applies the rate.
- The rate settles without audible damage.
- Pause, resume, route loss, and finish tear down work correctly.

#### Imported collection gate

After the core loop passes, connect the selected source to at least three analyzed tracks. Only then refine the music-selection surface and complete the physical run.

### Music source

Import is the product priority. Playlist generation and recommendations are deferred.

Use `MusicAuthorization`, `MusicLibraryRequest<Playlist>`, playlist track relationships, and `ApplicationMusicPlayer`. Persist stable Apple Music identifiers and locally derived tempo metadata. Do not download or store protected full-track audio.

The collection record stores identity, display name, ordered track identities, title, artist when available, duration, base tempo, analysis confidence, analysis version, and source fingerprint. It does not store listening history.

Exactly one collection is selected at a time. Replacing it is explicit. Imported source order remains the default playback order.

### Tempo analysis

Samadhi needs base tempo before it can adapt a track. Apple Music song metadata includes duration, identifiers, artwork, and playback parameters, but no BPM. The same local tempo-analysis interface should accept either a MusicKit preview asset or a local audio file.

Use Apple frameworks only for the first implementation. Decode a mono analysis window, build an onset-strength signal, and estimate tempo with Accelerate-based spectral flux and autocorrelation. The exact signal-processing internals may change without changing the interface.

Analysis rules:

- Evaluate tempo candidates from 60 through 200 BPM.
- Normalize half-time and double-time candidates later against running cadence instead of forcing one interpretation during analysis.
- Produce base BPM, confidence from 0 through 1, analyzed duration, and analysis version.
- A track is adaptive-ready at confidence 0.72 or higher.
- A lower-confidence track remains visible but is excluded from automatic adaptive selection.
- Wrong confident tempo is worse than rejection. Prefer “Could not read tempo” over a false result.
- Cache successful analysis by stable track identity plus analysis version.
- Run analysis before the run and off the main actor.

The validation corpus contains generated metronome and syncopation fixtures plus twelve provider-hosted Apple previews whose exact catalog titles declare tempos from 130 through 180 BPM. The validator downloads those previews temporarily and does not redistribute them. At least ten of twelve music excerpts must land within 2 percent of the accepted tempo or its half/double equivalent. The analyzer must reject rather than confidently mislabel deliberately ambiguous fixtures. Public-distribution permission for preview analysis remains a separate requirement.

### Cadence acquisition

Use `CMPedometer` live updates as the first production cadence source. Convert `currentCadence` from steps per second to steps per minute. Keep the current simulated provider behind the same boundary.

The controlled test placement is an iPhone secured in the runner's right-front shorts pocket, screen facing inward, top edge upward. Hand-held and loose-jacket placement are not supported by this milestone.

Cadence rules:

- Accept values from 120 through 210 SPM as running cadence.
- Keep the latest six observations.
- Initial lock requires at least five valid observations and median absolute deviation no greater than 3 SPM.
- Target lock time is 8 seconds or less. The hard timeout is 12 seconds.
- Smooth the locked cadence with an exponential moving average using alpha 0.20.
- Limit the published cadence change to 2 SPM per observation.
- Ignore changes inside a 2 SPM deadband.
- On resume, require three valid observations and use the prior locked cadence only as a smoothing seed.
- A permission denial retains the existing fixed-rhythm recovery path.
- A sensor error or sustained nil cadence returns the product to acquiring without inventing a number.

### Adaptation policy

Adaptation is a pure domain policy. It receives stable cadence, base track tempo, analysis confidence, prior rate, and elapsed time. It returns a decision that the reducer turns into an audio effect.

For a base tempo `B` and cadence `C`, consider `B / 2`, `B`, and `B * 2`. Keep candidates inside the running range, then choose the candidate that requires the smallest speed change. The target playback rate is `C / candidate`.

Safety and stability rules:

- Clamp target rate to 0.94 through 1.06 for Milestone 2.
- A track is cadence-compatible only when its unclamped target falls inside that range.
- Apply an initial lock ramp no faster than 2 percentage points of rate per second.
- After lock, change rate no faster than 0.5 percentage points per second.
- Recompute the target at most once every 2 seconds.
- Do not change rate for cadence movement inside the 2 SPM deadband.
- If cadence confidence drops, hold the last good rate for 6 seconds.
- If confidence does not recover, ease to 1.00 over 4 seconds and return to acquiring.
- Never claim matched until the applied player rate is within 0.5 percent of target for at least 1 second.
- Do not jump to a new track merely because cadence drifts. Finish the current track safely and choose a compatible next track.

At run start, choose the first ready track compatible with the last reliable cadence. If no prior cadence exists, use 168 SPM only for initial track selection, never as measured cadence. Start that track at normal speed. Once real cadence locks, adapt it if compatible. If it is incompatible, keep normal playback and choose a compatible track at the next natural transition.

Skip chooses the next adaptive-ready track in original collection order. If no compatible track exists, playback may continue at 1.00, but the interface must say “Music steady” rather than “Tempo matched.”

### Honest measurement

Milestone 2 measures frequency matching, not foot-strike phase.

Rename the internal summary measure from `timeInStepPercent` to `tempoMatchedPercent`. A second is eligible only when playback is active, cadence is reliable, track tempo is known, and the player reports an applied rate. It counts as matched when effective track tempo is within 3 SPM of smoothed cadence.

The lock brief uses “Tempo matched” with the measured cadence. The summary uses “tempo matched.” Fixed-rhythm runs show “Not measured.” The phrase “in step” may remain in brand language, but it cannot label a measurement until real foot-strike phase exists.

### Audio implementation

Expose one high-level production playback boundary to the app shell. It prepares a collection, plays, pauses, resumes, stops, skips, changes rate, reports current track and progress, and streams interruption, route, completion, and failure events.

The app shell translates those events into `RunEvent`. Audio code never mutates SwiftUI state directly.

`ApplicationMusicPlayer` is the implementation. Its observable state and queue drive real progress and track changes. Rate writes go through its player state. Background audio mode is required.

Use `AVAudioSession` playback category. Observe interruptions and route changes. An interruption or lost output route pauses audio and enters existing recovery. Route restoration never auto-resumes.

The app must continue playback and cadence work with the screen locked. Lock Screen artwork and custom remote controls remain out of scope, but background continuity is not optional.

### State and module changes

Keep the existing functional-core, main-actor-shell shape.

`SamadhiDomain` gains source-neutral music collection and track models, tempo analysis results, cadence observations, adaptation decisions, real progress, and new run events and effects. The reducer remains the sole owner of run phase changes.

`SamadhiMotion` gains a cadence-provider protocol, a Core Motion implementation, filtering input types, and deterministic fixtures. Core Motion callbacks produce observations only.

`SamadhiAudio` gains the tempo analyzer, the selected production player boundary and implementation, audio events, progress, and deterministic fakes. The app target depends on `SamadhiAudio` directly.

`SamadhiDesign` receives source-neutral collection and track presentation data. Demo track metadata leaves the design module once real import is connected.

The app target owns dependency composition, authorization requests, the selected collection store, task lifetime, audio-session observation, and translation between service events and reducer events.

Use existing session, acquisition, timeout, and hold identities. Add track-analysis and playback-operation identities where stale callbacks could otherwise affect a replacement task.

### Music-selection experience

Do not add a tab bar, dashboard, settings screen, or stack of cards.

When no collection exists, Ready presents “Choose music” as the primary action. Music choice opens one native sheet that lists Apple Music library playlists.

After selection, Ready shows the collection name, total tracks, and ready count as quiet text with a “Change” action. Start appears when one track is ready. Analysis uses a plain progress line and compact track list. Errors are written in human language, such as “Protected file,” “Unsupported format,” or “Could not read tempo.”

The active run keeps the current visual hierarchy. Track identity, real progress, cadence, controls, recovery, and summary use production state. The aperture follows the applied tempo, not the desired rate, so visual and audio truth cannot diverge.

Every new control needs VoiceOver labels, Dynamic Type behavior, increased-contrast treatment, Reduce Motion behavior, and deterministic preview state.

### Persistence and privacy

Persist only the selected collection, copied local audio when local import wins, tempo-analysis cache, last reliable cadence for initial track selection, and debug evidence explicitly captured during development.

Do not add an account, Samadhi backend, analytics, ad identifier, cloud listening history, or model call. If MusicKit wins, Apple Music authorization and network playback are the only new remote dependency. Update the product law from “local by default” to “no Samadhi backend; local analysis by default” in that branch.

### Diagnostics and evidence

Add a lightweight debug-only session trace using system logging or a small local value logger. Do not recreate a decorative diagnostics module.

Capture timestamped entries for authorization, cadence observations, lock and confidence changes, target and applied rates, track changes, audio interruptions, route changes, task cancellation, and failures. Never log audio samples or account tokens.

Evidence for the milestone includes the chosen source decision, device and OS, phone placement, headphone route, test collection, analyzer results, cadence calibration, automated test result, outdoor-run trace, and listening notes.

## Testing Decisions

Good tests assert behavior visible at a module boundary. They do not inspect private helpers, sleep for real time, depend on a personal Apple Music library, or make network calls in the normal automated gate.

The main scenario seam remains `RunEvent` into the reducer and `RunState` plus `RunEffect` out. This is the highest existing seam and should cover most product behavior. Real adapters receive smaller contract and device tests.

### Domain tests

Extend the current reducer suite to cover:

- Start with and without a ready collection
- Stable cadence lock and timeout
- Half-time and double-time tempo normalization
- Rate bounds, deadband, ramp limits, and target update interval
- Confidence loss, hold, and return to normal rate
- Incompatible current and next tracks
- Skip order through excluded tracks
- Real progress reset on track change
- Pause and resume reacquisition
- Stale cadence, analysis, playback, and progress events
- Route loss cancellation and explicit resume
- Honest lock and summary measurement
- Fixed-rhythm “Not measured” result

Use a manual clock and deterministic cadence and audio fixtures. Existing reducer tests are the prior art.

### Motion tests

Test cadence filtering with recorded numeric fixtures, not Core Motion itself. Cover stable running, gradual acceleration, single spikes, nil gaps, walking-range values, impossible values, pause, resume, and cancellation.

Run physical calibration at 160, 170, and 180 SPM for 60 seconds each. The locked median must be within 3 SPM of the controlled target, with no false relock from isolated spikes.

### Tempo-analysis tests

Use generated fixtures for exact tempo, half-time ambiguity, syncopation, silence, long intro, tempo drift, and low confidence. Add legally usable music excerpts with documented reference tempo.

The corpus gate is at least ten of twelve music excerpts within 2 percent of accepted tempo or its half/double equivalent. Version 2 passes 12 of 12 tempo-declared Apple previews. A confident wrong answer still fails harder than a rejection, so broader music coverage remains conservative.

### Audio tests

The production-player fake must prove preparation, play, pause, resume, stop, skip, rate application, progress, completion, interruption, route loss, cancellation, and stale-event rejection.

For a local engine, use offline or controlled rendering to verify expected duration change at 0.94 and 1.06 while the dominant pitch remains within a declared tolerance. Device tests verify there are no clicks, gaps, or audio-thread failures during rate ramps and track transitions.

For MusicKit, automated tests stop at the adapter boundary. A separate physical-device checklist verifies authorization, library loading, queue behavior, live rate writes, background playback, and recovery.

### UI tests

Inject deterministic library and analysis fixtures through launch configuration. Cover no collection, analyzing, partially ready, ready, import failure, real run, cadence unavailable, route recovery, and summary. Do not automate the system document picker or depend on a personal Apple Music account in the repeatable UI suite.

Re-run existing golden flow, missing artwork, permission recovery, route recovery, Dynamic Type, Reduce Motion, increased contrast, and VoiceOver checks.

### Physical completion gate

The milestone requires all of the following:

- Five cold cadence starts. At least four lock within 8 seconds and none take longer than 12 seconds.
- Controlled cadence calibration at 160, 170, and 180 SPM within 3 SPM.
- One imported collection with at least three adaptive-ready tracks.
- Listening checks at 0.94, 1.00, 1.06, initial ramp, ongoing correction, pause and resume, skip, and natural track transition.
- No audible click, gap, pitch jump, obvious warble, rapid hunting, or unexpected restart.
- One 20-minute outdoor run with 5 minutes easy, 10 minutes steady, and 5 minutes moderately faster.
- iPhone secured in the declared pocket placement and one Bluetooth A2DP headphone model recorded in evidence.
- Screen locked for at least 10 continuous minutes during that run.
- One deliberate pause and resume, one skip, one safe route-loss exercise while stationary, and one finish.
- No orphaned audio, motion, analysis, or timer work after finish.
- No thermal warning or audio-render failure.
- Trace and listening notes agree with what the interface claimed.

## Out of Scope

- Playlist generation, recommendations, catalog search, or AI curation
- Spotify or another streaming provider
- Maintaining Apple Music and local file playback as two production paths
- Beat-by-beat foot-strike phase detection or downbeat alignment
- Claiming a true footfall “in step” percentage
- GPS, route maps, distance, pace, coaching, plans, streaks, or social features
- Run history, cloud sync, accounts, analytics, subscriptions, or a backend
- Lock Screen artwork, Live Activities, widgets, custom remote-command controls, or App Intents
- Crossfade design beyond preventing an accidental gap
- Broad device, placement, and headphone compatibility
- Public App Store release or legal sign-off for preview analysis
- A large visual redesign of the completed run interface

## Further Notes

### Where we are now

Milestones 0 and 1 are complete. Apple Music is the selected Milestone 2 source. A validated 139.5 BPM fixture, Core Motion cadence, bounded reducer adaptation, identified applied-rate feedback, and honest measurement are connected in the focused core-loop scheme. Analyzer version 2 uses Accelerate spectral flux and fractional-lag autocorrelation and passes the narrow 12-preview corpus. A 29-second physical walk produced changing cadence and a 142 SPM average. The normal app remains simulated until import is connected. Automatic rate response remains unproven.

### Build order

1. Prove the connected fixture, physical cadence, and automatic rate response with one brief walk or jog.
2. Connect playlist import, persistence, real progress, and track transitions.
3. Expand analyzer coverage only when new real tracks expose a specific failure.
4. Complete repeatable automated gates.
5. Run cadence calibration, listening, background, recovery, and the outdoor completion gate.
6. Save evidence, update active documentation, and push main.

Do not redesign the app before the source decision and core audio loop pass. Do not build playlist generation before imported music works. Do not keep a failed player path “for later.”

### Verified Apple platform facts

- [`MusicLibraryRequest`](https://developer.apple.com/documentation/musickit/musiclibraryrequest) fetches items, including playlists, from the user's music library.
- [`ApplicationMusicPlayer`](https://developer.apple.com/documentation/musickit/applicationmusicplayer) supports app-specific playback and background continuation when background audio mode is present.
- [`MusicPlayer.State.playbackRate`](https://developer.apple.com/documentation/musickit/musicplayer/state-swift.class/playbackrate) is writable, but listening quality and usable range still require device proof.
- [`Song`](https://developer.apple.com/documentation/musickit/song) and [Apple Music song attributes](https://developer.apple.com/documentation/applemusicapi/songs/attributes-data.dictionary) expose duration, identifiers, artwork, and previews but do not document BPM.
- [`CMPedometerData.currentCadence`](https://developer.apple.com/documentation/coremotion/cmpedometerdata/currentcadence) reports steps per second.
- [`AVAudioUnitTimePitch`](https://developer.apple.com/documentation/avfaudio/avaudiounittimepitch) provides independent playback-rate and pitch processing for an app-owned audio signal.
- [`AVAudioPlayerNode`](https://developer.apple.com/documentation/avfaudio/avaudioplayernode) schedules audio files and exposes a player timeline.
- [SwiftUI file import](https://developer.apple.com/documentation/swiftui/view/fileimporter%28ispresented%3Aallowedcontenttypes%3Aallowsmultipleselection%3Aoncompletion%3A%29) returns security-scoped URLs that must be accessed and released correctly.
- Apple documents separate handling for [audio interruptions](https://developer.apple.com/documentation/avfaudio/handling-audio-interruptions) and [audio route changes](https://developer.apple.com/documentation/avfaudio/responding-to-audio-route-changes).
