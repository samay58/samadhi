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

## Honest tempo matching

Milestone 2 matches music tempo to stable cadence. It does not claim beat-perfect footfall phase. Rename the measured summary to tempo matched and defer a true in-step percentage until individual foot-strike timing exists.

## Initial gate blocker

No physical iPhone, Apple development team, Apple Music account, playlist, or headphone route was available during the first Milestone 2 pass. A compiling Simulator harness was preparation, not feasibility proof.

The blocker was partially cleared on 2026-07-15. Team `ZL5U59XBJ6` is saved in the project, the explicit App ID is registered, the MusicKit App Service is user-confirmed as enabled, and the signed harness builds, installs, and launches on an iPhone 17 Pro. Authorization, library loading, playback, mechanical rate writes, pause, and resume pass. Direct previews fail, and sampled library tracks omit ISRC. Equivalent-ID catalog requests are blocked by automatic developer-token failure, so the source decision remains open.

Do not interpret `.developerTokenRequestFailed` as evidence that catalog previews are unavailable. Retry after service recognition or explicit-App-ID signing is corrected. Manual Media Services keys and custom token infrastructure are outside this gate unless automatic generation is deliberately abandoned.

## Final automatic-token repair

The current signed development build used an Xcode-managed wildcard provisioning profile. Run one final Apple token test with a newly created development profile bound to the exact `com.samaydhawan.Samadhi` App ID. Inspect the embedded profile and signed identity before the request. If a clean physical build still returns `developerTokenRequestFailed`, reject Apple Music for Milestone 2 and select local files. Do not add a token backend, embed a private key, or commit a developer token.

## Spotify is not an adaptive-audio fallback

Do not build a Spotify spike. Spotify's iOS SDK remotely controls the Spotify app and does not expose an app-owned audio signal or documented music playback-rate control. Its Developer Policy prohibits analyzing Spotify content and requires audio content to remain in its original form. Playlist metadata alone does not close Samadhi's adaptive playback loop. Spotify import and playback are outside Milestone 2.

The complete source decision and pass thresholds live in [MUSIC-SOURCE-RESOLUTION-SPEC.md](MUSIC-SOURCE-RESOLUTION-SPEC.md).

## MusicKit service configuration

MusicKit uses an App Service enabled for the bundle identifier in the Apple developer portal. Do not add a fabricated `com.apple.developer.musickit` entitlement. The app does require `NSAppleMusicUsageDescription` and background audio mode.

## Policy before adapters

Tempo normalization, compatibility, rate bounds, ramping, deadband, confidence loss, and honest measurement live in SamadhiDomain. Core Motion emits source-neutral cadence events. Production callbacks still enter the reducer through the app shell.
