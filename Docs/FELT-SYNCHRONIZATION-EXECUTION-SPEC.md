# Felt synchronization execution spec

Status: Active

Updated: 2026-07-21

## Outcome

Samadhi must make a runner hear and feel music respond to movement. A changing number, a successful MusicKit write, or a high tempo-matched percentage does not complete the product.

This phase is complete when Samay can import one Apple Music playlist, start a normal outdoor run, hear an unmistakable but musical response, settle onto the beat, lock the phone, recover from ordinary interruptions, and trust the summary.

The research basis and source links live in [ADAPTIVE-AUDIO-PLAYBOOK.md](ADAPTIVE-AUDIO-PLAYBOOK.md). Product terms live in [CONTEXT.md](CONTEXT.md).

## Current truth

- Apple Music authorization, playlist import, catalog resolution, preview analysis, playback, bounded rate writes, pause, resume, live cadence, and mechanical automatic adaptation pass.
- A 59-second physical run averaged 155 SPM and reported 98 percent tempo matched from MusicKit read-back.
- The earlier rate near 1.02 was not perceptible. Mechanical correctness has not yet produced the required feeling.
- The current production queue follows playlist order. It does not yet use `TrackMatchPlanner` to choose compatible music.
- `TrackMatchPlanner` is source-neutral and passes deterministic tests for half-time, full-time, double-time, quality-envelope, source-order, and current-track retention behavior.
- The debug MusicKit harness can run a blinded 0.92 versus 1.08 comparison and record requested rate, read-back, and direction recognition. Optional 0.90 and 1.10 controls are available only for a clean follow-up.
- Public MusicKit exposes playback rate but no documented beat grid, full-track PCM callback, phase-control primitive, or processing-quality guarantee.
- The paired iPhone reconnected on 2026-07-21. On `LITE SPOTS` through Beoplay Eleven, Samay clearly heard 0.90 versus 1.10 and reported approximately 95 percent confidence that the mechanic worked. The broader blinded and full-song quality checks remain open, and the installed exact development profile expires on 2026-07-23 UTC.

## Priority map

| Priority | Question | Why it comes now | Done condition |
| --- | --- | --- | --- |
| Critical | Can MusicKit create an obvious, clean change? | Every Apple Music implementation choice depends on this answer. | Physical pass-or-pivot decision with saved evidence |
| Next | Can Samadhi choose music that naturally fits the requested rhythm? | Track choice creates range without abusing time stretching. | Planner connected to normal Auto and Manual runs |
| Then | Can the app change tracks and control ownership without breaking flow? | A correct match still fails if it feels abrupt or unstable. | One musical transition with no stale feedback or control jump |
| After | Can public MusicKit support credible beat-phase work? | Tempo frequency alone may not create a bodily lock. | Measured feasibility decision with honest product language |
| Finish | Does the complete run survive real phone conditions? | Reliability is part of the listening experience. | One successful 20-minute outdoor run and evidence packet |

Do not begin surrounding product work until the Critical question is answered.

## Critical: MusicKit perceptibility decision

### Preparation

- Reconnect the physical iPhone and renew the exact profile if it has expired.
- Use the `Samadhi MusicKit Gate` scheme and one supported Bluetooth A2DP route.
- Choose five analyzed tracks with a prominent, stable beat and clear vocals or transients that expose artifacts.
- Keep the normal app and existing selected playlist unchanged during this gate.

### Procedure

For each of five tracks:

1. Start real Apple Music playback.
2. Place the phone face down and run the blinded 0.92 versus 1.08 comparison.
3. Record which sample sounded faster.
4. Listen for clicks, gaps, pitch movement, vocal smearing, warble, or unstable playback.
5. Confirm the requested rates and MusicKit read-back in the exported trace.

Use 0.90 and 1.10 only if 0.92 and 1.08 remain clean. Do not expand the production envelope from property writes alone.

### Pass

Apple Music passes only when all of these are true:

- Faster versus slower is identified correctly on at least four of five blinded comparisons.
- The largest clean pair is described as obvious, not subtle.
- Every proposed production endpoint remains listenable for a full song on the supported Bluetooth route.
- Requested rate and MusicKit read-back agree without gaps, route failure, or playback instability.

Save the exported JSON, checksum, route, device, OS, tracks, results, and listening notes under `Evidence/Device/`.

### Decision

- If the gate passes, record the widest clean envelope and keep Apple Music for the next stage.
- If the gate fails, reopen the source decision immediately. Do not spend another product cycle polishing the current Apple Music path.
- A narrow range that is technically correct but still imperceptible is a failure for this product.

## Next: production track fit

Connect `TrackMatchPlanner` only after MusicKit passes.

### Behavior

- At run start, rank adaptive-ready tracks against the last reliable cadence. Use 168 BPM only as an initial selection prior, never as measured cadence.
- Evaluate half-time, full-time, and double-time native pulses inside the proven rate envelope.
- Choose the candidate requiring the least logarithmic stretch.
- Preserve playlist order as the tie-breaker.
- Keep the current song when another candidate is only marginally better.
- When the current song remains incompatible for five seconds, prepare a compatible next song. Do not switch in response to one noisy cadence update.
- Manual BPM uses the same planner. A target outside the current song's envelope should produce a better-track plan, not a dead `At limit` interaction.
- If no track fits, keep playback at a truthful steady rate and say `Music steady`.

### Architecture

- `RunReducer` owns when a selection or transition becomes product state.
- `TrackMatchPlanner` remains pure and source-neutral.
- SwiftUI sends Auto, Manual, skip, and adjustment intent only.
- The app shell translates the selected plan into identified player effects.
- Track, operation, rate-request, and session identities remain mandatory. Stale callbacks cannot change a replacement plan.

### Tests

- Initial selection with and without prior cadence
- Manual target before cadence lock
- Compatible and incompatible current tracks
- Five-second incompatibility hold
- Current-track retention and candidate oscillation prevention
- Playlist-order tie behavior
- No compatible candidate
- Stale selection, transition, and rate feedback
- Honest `Music steady` and `Tempo matched` states

### Done

A deterministic scenario and one physical imported-playlist run must show requested BPM, selected track, selected pulse, required rate, MusicKit read-back, and effective BPM agreeing.

## Then: musical transition and soft control

### Transition

- Select the next compatible track before the current track ends.
- Do not promise a beat-matched crossfade that public MusicKit cannot control.
- Let the current track finish unless the runner explicitly skips or the track becomes unusable.
- Start the incoming track at a stable rate and ramp through the existing adaptation policy.
- Recompute adaptation from the new track identity and reject feedback from the old track.

### Control ownership

- Auto follows stable cadence and stays visually quiet after settling.
- Manual leads. Opening Manual seeds from the currently applied musical BPM so ownership transfers without a jump.
- Fine adjustment remains one BPM per detent.
- When a target requires another track, use calm forward language such as `Finding a better fit`. Do not expose implementation jargon.
- The normal run screen remains one composition. Do not add a mixer, deck interface, settings panel, or permanent telemetry.

### Done

One physical run must cross a natural track boundary without a gap, stale applied-rate update, abrupt control jump, or false matched claim.

## After: beat-phase feasibility

Tempo match and beat lock remain distinct. This is a focused feasibility spike, not a broad analyzer rewrite.

### Questions

- Can the preview-derived beat grid be mapped reliably to full-track playback time?
- Can Core Motion step timestamps and MusicKit playback time share a stable enough clock for phase measurement?
- How much latency and variance come from sensing, filtering, player response, buffering, and Bluetooth?
- Can a bounded correction reduce phase error without audible mechanical jumps?

### Gate

- Record step timestamps, predicted beat timestamps, route, requested rate, read-back, and observed latency.
- Repeat across at least three strong-beat tracks and the supported Bluetooth route.
- Require repeatable phase behavior before adding `Beat locked` or `In step` as a measured claim.

### Decision

- If MusicKit supports stable phase observation and gentle correction, specify the smallest phase controller next.
- If preview timing does not map to the full stream or latency is not controllable, keep `Tempo matched` and record beat lock as a MusicKit limitation.
- If the product cannot feel synchronized without beat lock, pivot to app-owned audio rather than disguising the limitation with UI.

## Pivot: app-owned audio

Take this branch only if the MusicKit perceptibility gate fails or phase control proves essential and unavailable.

### First spike

- Import a small set of DRM-free local tracks.
- Prove pitch-stable playback across a conservative range using `AVPlayer` with spectral time pitch.
- Compare quality and latency with `AVAudioEngine` plus `AVAudioUnitTimePitch` only if scheduled phase control is required.
- Measure before introducing a third-party engine.

### Pass

- An obvious faster-versus-slower comparison remains clean.
- Host or sample-time scheduling supports repeatable phase measurement.
- Background playback, route recovery, and track transitions remain viable.

### Discipline

- Do not maintain Apple Music and local audio as simultaneous production players.
- Preserve source-neutral collection, cadence, planner, reducer, diagnostics, and presentation work.
- Remove rejected adapter or spike residue after the source decision.
- A commissioned adaptive catalog is a later business and rights decision, not part of this milestone.

## Finish: real-run gate

After the chosen player, track fit, transition, and honest measurement work together:

- Import and restore one real playlist or local collection.
- Start in one or two actions.
- Acquire cadence from the declared phone placement.
- Hear a meaningful response and settle onto a prominent beat.
- Exercise Auto fine-tune and Manual once without stopping the run.
- Play for five continuous minutes with the screen locked.
- Pause, resume, survive one controlled interruption, lose the headphone route, reconnect, and resume explicitly.
- Cross at least one natural track transition.
- Complete one 20-minute outdoor run.
- Save diagnostics and listening notes.
- Confirm the summary reports only measured cadence and tempo-matched time.

Milestone 2 closes only when the whole run passes. Individual subsystem success is not enough.

## Craft gate

Visual refinement follows mechanic proof and is limited to surfaces touched by the new behavior.

- Keep the aperture as the single rhythm-control owner.
- Make requested, applied, waiting, steady, and matched states legible without adding cards or dashboards.
- Use motion to explain transfer and settling, not to simulate energy the audio does not have.
- Keep text readable across artwork, Dynamic Type, increased contrast, and Reduce Motion.
- Validate every changed state in real Simulator frames and the final control on the physical phone.

Do not redesign the app while the audio decision is open.

## Evidence packet

| Gate | Automated proof | Physical proof | Durable output |
| --- | --- | --- | --- |
| MusicKit perceptibility | Harness build and trace schema | Five blinded comparisons and full-song endpoint listening | JSON trace and concise analysis |
| Track fit | Domain and reducer tests | Imported track selection at a stable cadence | Latest-run diagnostics |
| Transition | Identity and stale-callback tests | One natural transition | Diagnostics and listening note |
| Beat phase | Deterministic timing fixtures | Three-track latency observations | Feasibility decision |
| Reliability | Full serial gate | Lock, interruption, route loss, outdoor run | Milestone evidence summary |

## Scope boundary

Do not add playlist generation, Spotify, GPS, maps, pace, distance, coaching, social features, accounts, analytics, a backend, run history, a dashboard, or a second production player.

## WHERE WE LEFT OFF

The research, source-neutral planner, production track-fit connection, and aperture click wheel are complete. Adaptive runs start from the best ready fit using 168 BPM only as a prior. A stable five-second mismatch prepares a better-fitting next song while keeping the current song playing, and identified callbacks prevent stale preparation from winning. The exact-profile harness and trace proved an obvious 0.90 versus 1.10 change on one Bluetooth track. Apple Music remains authoritative, but the normal-run envelope stays at 0.94 through 1.06 until full-song quality is proven. The next action is one physical imported-playlist run through a natural prepared transition. Renew the exact development profile before another install after its 2026-07-23 UTC expiration.
