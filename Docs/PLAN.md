# Product plan

## Completed gates

### Repository foundation

Project generates, builds, tests, and stores evidence without production dependencies.

### Interaction prototype

Every meaningful state renders deterministically. Golden flow and recovery paths pass. Visual hierarchy, accessibility, progress, controls, finish safety, and summary are resolved at prototype level.

### Music setup chain

Empty selection, playlist loading and selection, exact analysis progress, partial and complete readiness, typed result disclosure, and action-specific recovery now share one continuous playlist instrument. Identity stays stable while truthful status and actions hand off around it. Fresh iPhone 17 Pro Simulator evidence covers compact, empty, current-selection, large-library, long-name, accessibility XXXL, and Reduce Motion edges.

### Core reset software baseline

Every Debug run records its base commit, branch, dirty state, source fingerprint, build time, app version, and build number. It explains the current song speed, phone rhythm, settled Auto target, requested playback change, Apple Music reply, delay, result, and remaining difference. Deterministic tests cover the reported current behaviors. Fresh Simulator frames cover low-tempo two-step music, all four command results, song reset, accessibility XXXL, Reduce Motion, and Increased Contrast.

### Track-scoped Manual and tempo close

Manual remains active on the same confirmed song through pause, resume, route loss, and recovery. It returns to Auto only after the player confirms a different song or the runner chooses Auto. The tempo wheel has an accessible close action that restores playback controls without changing playback or rhythm.

### Transport, song-change cause, and the first Auto feedback prototype

Play, Pause, Previous, Next, and Finish are one control system: three separate interactive Liquid Glass circles with a larger tinted primary, and a quiet Finish button below them that arms a hold whose fill is clipped by its own capsule. Both causes of the reported Finish overflow were reproduced on video and removed. Every confirmed song change carries a cause of natural end, outside change, or explicit Previous or Next, and the hidden Debug screen shows it. A reducer-owned transaction decides when one directional Auto cue is valid, and three prototype haptic families with paired arrival sounds can be played by hand from a Debug audition screen. Physical feel, sound quality, and Apple Music coexistence remain open.

### Milestone 2 specification

Playlist import, real cadence, adaptive playback, honest measurement, source selection, testing, and physical completion are specified in [MILESTONE-2-SPEC.md](MILESTONE-2-SPEC.md).

## Active milestone

Milestone 2 turns the interaction prototype into a useful music product.

The finish line is one real outdoor run, not a feature checklist. Samay should be able to import one Apple Music playlist, start running, hear music settle into his cadence, lock the phone, recover from normal interruptions, finish, and trust the summary. Stop expanding scope until that run works.

The first normal field run disproved the original product mechanic. Later field evidence exposed stale cadence, over-sensitive wheel movement, startup selection against an invented 168 SPM prior, and a cadence range too narrow for brisk walking. The current software candidate accepts steady movement from 90 through 210 SPM, waits five seconds before walking can control music, rejects broken lifting-like motion, accepts five SPM of remaining match error, and widens one-song playback from 0.85 through 1.15. The saved private collection report still reflects the prior range. A clean walking and endpoint-listening phone check remains the truth gate.

Manual control has one additional release-blocking contract. The wheel cannot display or commit a BPM the current song cannot produce inside its proven playback-rate envelope. Its integer range must come from the current cadence projection and player limits. At either boundary, value movement and detent feedback stop together, one restrained terminal haptic marks the limit, and reversing responds immediately. Playlist-wide range remains available through explicit Skip or a natural boundary. It must not appear as unreachable wheel travel.

The MacBook continuation audit and storage discipline are recorded in [MACBOOK-SETUP.md](MACBOOK-SETUP.md). The Simulator runtime, paired iPhone, and full software gate are available. A fresh exact Samadhi profile was created and used for an in-place install with app data preserved.

Continue in this order:

1. Run the phone check in [PHONE-CHECK-2026-08-19.md](PHONE-CHECK-2026-08-19.md). The candidate is installed and its in-app source fingerprint is confirmed. Take the endpoints through headphones, judge transport and Finish by hand, run the blinded faster and slower trials for all three families on both sound paths, read the recorded cause after a natural boundary and after an explicit Next, and check screen lock, an interruption, and route recovery.
2. Complete one 20-minute outdoor run with an imported playlist. The run must feel good, survive normal phone conditions, and end with an honest summary.

## Current gate state

- Apple Music feasibility: authorization, library loading, automatic token generation, strict catalog resolution, 10 of 10 local preview decodes, playback, rate writes, pause, and resume passed
- Token remediation: complete; exact profile `Samadhi Development` fixed catalog access
- Tempo-source feasibility: passed for City Pocket at 10 of 10 decoded previews
- Tempo-analysis implementation: version 5 searches 60 through 210 BPM with support lags from 30 through 420, judges each tempo together with its half or double so swung and dotted grooves keep their true beat, preserves the measured musical pulse, records an independently supported alternate stride pulse separately, passes 12 of 12 tempo-declared Apple previews, and rejects silent, irregular, and triple-meter ambiguity
- Spotify feasibility: rejected for adaptive playback; it cannot supply the required app-owned, analyzable, rate-controlled audio path
- Source decision: Apple Music selected on 2026-07-16; remaining manual drills moved to the reliability gate
- Source-neutral domain and adaptation rules: bounded rate behavior and coarse track fit are connected; a mismatch may prepare only the latest better fit, while Skip or a player-confirmed natural boundary remains the only commit authority
- Cadence boundary, deterministic filter, and Core Motion adapter: connected in the focused core loop and normal imported run; the candidate accepts 90 through 210 SPM, with longer evidence for walking and calibration still open
- Production playback: validated catalog fixture `1558215042`, live cadence updates, bounded reducer effects, identified MusicKit read-back, and honest measurement are connected
- Playlist import and persistence: implemented with strict resolution that reads a library song's own catalog identifier first and breaks explicit versus clean ties by content rating, local preview analysis, versioned cache keys, atomic replacement, complete typed per-track results, retry after relaunch, three-track bounded concurrency, private timing diagnostics, and ready-only production filtering
- Normal run composition: restored imported tracks use Apple Music playback and Core Motion; Debug Simulator uses isolated local placeholder playlists with simulated cadence and silent playback
- Last released body-to-music gate: 103 package tests, 15 app-model tests, 10 UI tests, formatter, normal Simulator build, focused rotary-control UI proof, runtime screen review, renewed exact-profile build, embedded application identifier verification, and physical installation pass
- Physical body-to-music observation: passed; the corrected 59-second run averaged 155 SPM and measured 98 percent tempo matched from MusicKit read-back
- Physical imported-collection gate: real playlist selection, local analysis, reinstall and relaunch restoration, and basic progress passed at 13 of 25 ready tracks; a natural transition remains open
- Device evidence: the baseline build recorded base commit `4f5394f`, dirty state, and build time, then produced one real Apple Music and motion trace. The exact-profile Auto candidate preserved the selected collection. Its later workout file confirmed source fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498`, real phone motion, and real Apple Music. Evidence lives under `Evidence/Device/2026-08-15-core-reset/` and `Evidence/Device/2026-08-17-auto-target/`.
- Auto software repair: the saved delayed pattern acquires in replay and acquired physically at 133 SPM; invalid timing still fails, and a separate settled target ignores ordinary noise and one spike before accepting sustained changes
- Workout result: 49 of 61 retained numeric cadence readings were from 90 through 119 SPM. The workout mixed walking, light jogging, and substantial lifting, so the trace cannot label every reading. The software candidate now covers that steady movement range. Lifting remains outside Auto.
- Transport and Finish craft: the three floating pills became one glass capsule bar, which read as a milky slab on the phone, and then became three separate interactive glass circles with a larger tinted primary and a spring press; Finish is a quiet hairline button that arms a hold drawn inside its own capsule. Both reported overflow causes were reproduced on 30 fps video before the change and are gone from the after frames. 39 Simulator images were inspected, including a 54-frame hold contact sheet. Press feel, haptic character, and daylight legibility remain physical
- Auto interaction: Samay felt the changes, but they felt jarring and unexplained. The reducer now owns one directional transaction per meaningful Auto change, an app-shell service plays it, and three prototype families with paired arrival sounds can be played by hand from a hidden Debug audition screen. Patterns, sounds, and size bands stay unapproved until the phone comparison. No screen-copy change is planned
- Song-change cause: a pure attribution rule labels every confirmed change as an explicit Previous or Next, a natural end, or an outside change, and the hidden Debug screen shows the last one. The MusicKit wiring of that rule is read by hand, not covered by an automated test
- Rhythm control: Manual is scoped to the confirmed song, and a quiet 44-point close action sits clear of the wheel and returns directly to transport; physical audible and tactile proof remains open
- Candidate verification: formatter lint, 179 package tests, source-fingerprint tests, resource-inclusive Debug and Release Simulator builds, 44 app-model tests, and 32 serial UI tests pass. Neither the hidden Debug screen nor the feedback audition screen appears in Release. Commit `67adf80` was built with the exact profile, installed in place on 2026-08-19, and read back on the phone with source fingerprint `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6`; the record lives under `Evidence/Device/2026-08-19-phone-install/`. Fresh frames live under `Evidence/Simulator/2026-08-18-transport-finish/`, and the audio prototype record lives under `Evidence/Audio/2026-08-18-auto-feedback-prototypes/`.
- Felt-synchronization research: complete enough to set direction; Weav used adaptive arrangements, djay separates BPM from beat sync, and published running work supports compatible-track selection plus phase-aware control
- Device harness: exact-profile catalog search, strict identity resolution, temporary preview download, local PCM decoding, playback, rate controls, route observation, and trace export remain available on the physical iPhone 17 Pro
- Perceptibility result: 0.90 versus 1.10 was clearly audible on `LITE SPOTS` through Beoplay Eleven; the 0.85 through 1.15 candidate is covered in software but still needs physical read-back and full-song listening

The source decision and deferred reliability requirements live in [MUSIC-SOURCE-RESOLUTION-SPEC.md](MUSIC-SOURCE-RESOLUTION-SPEC.md). A later reliability failure must be fixed before Milestone 2 completion. It does not reopen Spotify or a second-provider project.

## Milestone boundary

Included:

- One imported collection
- One selected production playback system
- Core Motion cadence from one declared phone placement
- Local tempo analysis
- Compatible-track selection plus fine correction inside a declared envelope that passes physical listening
- One calm in-run BPM control for automatic matching, manual targeting, and small corrections
- Background continuity with screen lock
- Existing pause, resume, skip, route recovery, finish, and summary behavior
- Physical calibration, listening evidence, and one 20-minute outdoor run

Excluded:

- Playlist generation and recommendations
- Spotify or a second production music provider
- A beat-lock claim before phase and latency are measured
- Run history, GPS, coaching, social features, backend, subscriptions, and broad hardware support

## Stop rule

Do not redesign the app or build playlist generation before imported music and the physical body-to-music loop work. The BPM control is part of that loop, not a settings feature. If public MusicKit cannot make a clean change that Samay can reliably feel, reopen the source decision. The complete mechanics and evidence thresholds live in [ADAPTIVE-AUDIO-PLAYBOOK.md](ADAPTIVE-AUDIO-PLAYBOOK.md).
