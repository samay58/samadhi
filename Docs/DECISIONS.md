# Decisions

## iOS 26 target

Use iOS 26 for personal prototype. One platform language is worth narrower compatibility. Revisit only if public distribution becomes active goal.

## Reproducible project

Use XcodeGen. Generated project stays versioned and reviewable. XcodeGen remains development-only dependency.

## Simulation boundary

Milestone 1 uses deterministic cadence and beat timing. It does not link Core Motion or production audio frameworks. Simulator proves interaction, not physical quality.

## State architecture

Use pure reducer plus one main-actor presentation model. Avoid screen view models and boolean phase clusters.

## Native ambient surface

Use local MeshGradient, restrained contours, and tempo aperture. No generated video, hosted animation, or free-running visual loop. Native rendering stays sharp, state-aware, and interruptible.

## Depth through hierarchy

Use one visual owner. Reserve glass for controls. Use open typography and tonal washes for passive information. Persistent rings must communicate progress or cadence.

## Brand

Product name is Samadhi. “In step” remains lowercase cadence metric. Public tagline is “music in stride.”

Use compact interlocking ribbon icon on opaque parchment. In-app mark uses native ribbon drawing instead of square icon.

## Evidence

Simulator screenshots, preview states, test logs, and result summary prove current build. They do not prove physical cadence or listening quality.

## Documentation

Active truth lives in PRODUCT.md, STATUS.md, and PLAN.md. Architecture, decisions, testing, progress, and brand support those files. Superseded build handoff and completed prompt artifacts were removed; Git history preserves them.

## Import before generation

Playlist import is required before playlist generation, recommendations, or catalog expansion. A runner's existing music is the shortest path to proving the product loop.

## One production player

Run a physical Apple Music feasibility gate first because MusicKit exposes library playlists and writable playback rate. Continue with Apple Music only if tempo sourcing, listening quality, background playback, and recovery pass. Otherwise use imported DRM-free files and `AVAudioEngine`. Do not maintain both production players in Milestone 2.

On 2026-07-16, Apple Music became the selected production player. Authorization, import, token generation, strict catalog identity, preview decoding, real playback, speaker listening, Bluetooth routing, and live rate writes had passed. Samay explicitly deferred the repetitive five-minute and recovery drills so implementation could continue. Those drills remain milestone completion requirements, not source-selection blockers.

The adapter stays behind a source-neutral main-actor contract. MusicKit's async player methods do not yet carry complete sendability in the installed SDK, so the app uses a narrow `@preconcurrency` import. Every player access remains main-actor owned. Remove that compatibility import when the SDK annotations make it unnecessary.

## One local tempo-analysis interface

Preview audio and future imported files both become a local audio-file URL before analysis. `LocalTempoAnalyzer` hides off-main PCM decoding and returns a versioned source-neutral result. `TempoEstimator` version 2 contains Accelerate spectral flux, fractional-lag autocorrelation, and conservative triple-meter rejection.

Version 1 passed 11 of 12 tempo-declared Apple workout previews but confidently labelled one 180 BPM mix as 60 BPM. Version 2 passes 12 of 12. The opt-in validator downloads provider-hosted previews temporarily and commits only metadata and results. This is an engineering accuracy result, not public-distribution permission for preview analysis.

## Honest tempo matching

Milestone 2 matches music tempo to stable cadence. It does not claim beat-perfect footfall phase. Rename the measured summary to tempo matched and defer a true in-step percentage until individual foot-strike timing exists.

Tempo match is necessary but not sufficient for felt synchronization. The product must also prove that a deliberate change is audible and that a runner can settle onto a prominent beat. Beat lock is a separate future claim that requires measured phase and latency.

## Apple Music gate history

The first physical harness used an Xcode-managed wildcard profile. It could authorize Music, load 40 playlists, play music, accept rate writes, pause, and resume, but catalog requests failed with `.developerTokenRequestFailed` before Apple returned a response.

The exact `Samadhi Development` profile fixed automatic developer-token generation. No backend, embedded private key, or committed token is needed.

Library tracks still expose opaque nonnumeric identifiers, no ISRC, and no direct preview. Strict title, artist, album, and duration agreement resolved all ten City Pocket tracks to numeric catalog identifiers. Ambiguous results fail closed. The harness downloads each catalog preview into temporary app storage, decodes it locally, and deletes it immediately. Ten of ten previews yielded PCM, so the tempo-source feasibility threshold passed.

The remaining Bluetooth listening note, locked background playback, track change, interruption, and route recovery checks now sit in the Milestone 2 reliability gate. They no longer block source selection, but Milestone 2 cannot close without them.

## Spotify is not an adaptive-audio fallback

Do not build a Spotify spike. Spotify's iOS SDK remotely controls the Spotify app and does not expose an app-owned audio signal or documented music playback-rate control. Its Developer Policy prohibits analyzing Spotify content and requires audio content to remain in its original form. Playlist metadata alone does not close Samadhi's adaptive playback loop. Spotify import and playback are outside Milestone 2.

The complete source decision and pass thresholds live in [MUSIC-SOURCE-RESOLUTION-SPEC.md](MUSIC-SOURCE-RESOLUTION-SPEC.md).

## MusicKit service configuration

MusicKit uses an App Service enabled for the bundle identifier in the Apple developer portal. Do not add a fabricated `com.apple.developer.musickit` entitlement. The app does require `NSAppleMusicUsageDescription` and background audio mode.

## Policy before adapters

Tempo normalization, compatibility, rate bounds, ramping, deadband, confidence loss, and honest measurement live in SamadhiDomain. Core Motion emits source-neutral cadence events. Production callbacks still enter the reducer through the app shell.

## Imported collection boundary

The normal app has one persisted selected collection. Import preserves source order and records every track as pending, ready, unreadable, or unavailable. Setup stays honest about failures, while the production player receives only adaptive-ready tracks.

Tempo results are cached by numeric catalog track identity, normalized source metadata fingerprint, and analyzer version. A metadata or analyzer change cannot silently reuse stale analysis. Replacing a playlist is atomic: the prior selection remains durable until the new import completes, and stale async callbacks cannot replace newer work.

The shared strict catalog resolver prefers ISRC or documented equivalent identity and falls back to exact title, artist, album, and duration agreement. Ambiguity fails closed. Provider previews are temporary inputs to the existing local file analyzer and are deleted after analysis.

## Production body-to-music composition

Imported ready tracks compose `CoreMotionCadenceProvider` and `AppleMusicPlaybackController` in the normal app. Deterministic music and cadence remain available only for repeatable fixtures, previews, and tests. The `Samadhi Apple Music Core Loop` scheme remains a focused diagnostic path around a validated tempo fixture.

The first physical walk averaged 142 SPM. The original 170.25 BPM fixture could not reach that cadence inside the safe 0.94 through 1.06 rate range, so the honest summary reported 0 percent tempo matched. A second check with the 139.5 BPM fixture produced no perceptible speed change; its expected rate near 1.02 was too subtle to distinguish from no response.

The focused fixture now uses catalog track `1558215042`, estimated at 149.75 BPM. At 142 SPM it should ramp from 1.00 through 0.98 and 0.96 toward about 0.948, remaining inside the same safety limits. The focused build shows target rate and MusicKit read-back without changing the normal app.

`AppleMusicPlaybackController` must not call a commanded rate applied. It stores the request identity, writes MusicKit, then reports the value read from `ApplicationMusicPlayer.state.playbackRate`. The reducer accepts that read-back only when session, operation, request, and track identities still match.

The corrected physical run averaged 155 SPM and measured 98 percent tempo matched across 59 seconds. A fixed 1.00 rate could not satisfy the three-SPM tolerance for the 149.75 BPM fixture, so this closes the automatic rate-response gate. Exact live diagnostics should be captured during the run because completed sessions intentionally release their transient target and applied values.

The reducer owns adaptation state and rate decisions. Each rate effect carries session, operation, request, and track identity. The player reports the applied rate through the same identities, and stale feedback is ignored. Cadence sensing continues after lock so the existing confidence hold, gradual return to 1.00, and reacquisition rules can run instead of freezing the first estimate.

## Latest-run diagnostics, not run history

Debug builds overwrite one local `latest-run-diagnostics.json` file when a run finishes. It records real player progress, cadence, target and applied rates, track changes, recovery events, and the final summary. This lets device evidence be pulled directly after a run without adding analytics, a dashboard, or a persistent run-history product. Release behavior and the visible run interface remain unchanged.

## Manual rhythm control belongs in the core loop

Automatic cadence matching remains the default, but it is not the only control. The runner has one in-run BPM control to correct the feel and to prove that requested musical changes reach the real player. It supports a small Auto correction, a direct Manual target, and one-step reset to Auto. It remains bounded by the existing rate, ramp, confidence, and track-compatibility rules.

This is not a settings system and it does not bypass the reducer. SwiftUI sends intent. The reducer derives safe target rates, identified player effects carry the change, and MusicKit read-back remains the applied truth. The existing aperture becomes the direct manipulation surface, while requested and applied BPM remain visibly distinct. Physical proof must still confirm that this interaction changes real Apple Music playback cleanly.

## Compatible music before aggressive stretching

Weav achieved broad adaptation through licensed multi-arrangement material, not one extreme rate control applied to ordinary masters. djay treats song compatibility, BPM correction, beat alignment, key lock, and transitions as separate responsibilities. Samadhi will use the same separation without importing a DJ interface.

The production mechanic is coarse track fit followed by fine rate correction. `TrackMatchPlanner` ranks adaptive-ready tracks by the smallest pitch-stable correction across half-time, full-time, and double-time pulse interpretations. It keeps the current song when another candidate is only marginally better and preserves source order as the tie-breaker.

The 0.94 through 1.06 envelope remains authoritative until a physical MusicKit comparison proves a wider clean range. If 0.92 versus 1.08 is not both clean and unmistakable, Apple Music returns to a source decision instead of becoming a permanent compromised path. The evidence and pivot order live in [ADAPTIVE-AUDIO-PLAYBOOK.md](ADAPTIVE-AUDIO-PLAYBOOK.md).
