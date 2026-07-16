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

## Focused body-to-music composition

Keep the normal app deterministic until playlist import is ready. The `Samadhi Apple Music Core Loop` scheme alone composes the verified 170 BPM fixture, `CoreMotionCadenceProvider`, and `AppleMusicPlaybackController`.

The reducer owns adaptation state and rate decisions. Each rate effect carries session, operation, request, and track identity. The player reports the applied rate through the same identities, and stale feedback is ignored. Cadence sensing continues after lock so the existing confidence hold, gradual return to 1.00, and reacquisition rules can run instead of freezing the first estimate.
