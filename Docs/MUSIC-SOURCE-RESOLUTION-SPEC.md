# Music source resolution specification

Status: Ready for the final Apple Music token gate

## Problem Statement

Samadhi needs one production music source that can import a runner's collection, expose or support local tempo analysis, play in the background, and change playback rate from 0.94 through 1.06 without audible damage.

The physical MusicKit harness has already proved authorization, library playlist loading, real playback, live rate writes, pause, and resume. Direct library songs exposed no usable previews, sampled tracks exposed no ISRC, and catalog equivalent-ID requests stopped before a response with `developerTokenRequestFailed`. Apple Music is therefore blocked at automatic developer-token generation. It has not yet failed the catalog-preview requirement.

Spotify was considered as another streaming source. It is not a viable adaptive-audio player for this milestone. Spotify's iOS SDK remotely controls the Spotify app rather than giving Samadhi an app-owned audio signal. Its documented player APIs do not offer music playback-rate control, and Spotify's Developer Policy prohibits altering or analyzing Spotify content. A Spotify playlist could provide metadata, but it would not close the adaptive playback loop and would add OAuth, account, and provider complexity.

The decision must remain bounded. Samadhi will perform one clean Apple identity and signing repair. If automatic token generation still fails, or if any later load-bearing MusicKit gate fails, the production source becomes DRM-free multi-file import with `AVAudioEngine` and `AVAudioUnitTimePitch`. Samadhi will not build a token backend, embed a Media Services private key, or maintain two production players.

## Solution

Resolve the source in four gates. Each gate produces durable physical-device evidence. The first failure ends the Apple Music path.

### Token identity gate

1. Confirm the exact App ID `com.samaydhawan.Samadhi` exists under team `ZL5U59XBJ6` and its MusicKit App Service is enabled.
2. Replace the current wildcard development provisioning profile with a fresh development profile bound to the exact App ID.
3. Regenerate, clean, sign, install, and launch the MusicKit harness on the physical iPhone.
4. Inspect the built app and embedded profile. Record the application identifier, team identifier, bundle identifier, profile name, profile App ID, device, OS, and build timestamp.
5. Run one minimal catalog request before playlist sampling. Save the complete result and underlying error in the trace.

Pass means the installed app receives Apple's automatic developer token and obtains a real catalog response. Fail means the same signed physical build returns `developerTokenRequestFailed` after the exact profile is installed. One transient retry after a clean reinstall is allowed. Repeated retries, hidden token workarounds, and speculative entitlement changes are not.

If the gate fails, record Apple Music as rejected for Milestone 2 and begin local-file playback. Apple Developer Support can be contacted later, but support latency does not block the useful product path.

### Tempo-source gate

After the token gate passes, select one real library playlist and resolve ten chosen tracks to catalog songs. Attempt decoded local analysis using the documented preview or another documented local tempo source.

Pass requires analyzable audio or documented tempo for at least eight of ten tracks. Titles, artists, and durations may be used to report evidence, but fuzzy title matching is not an accepted production identity strategy. External BPM databases are not part of this milestone.

Fail means fewer than eight of ten tracks can be analyzed reliably. The Apple Music path ends because Samadhi cannot make an honest adaptation decision without track tempo.

### Playback quality gate

Use one known-tempo track and `ApplicationMusicPlayer` on the same physical iPhone and headphone route. Exercise 0.94, 1.00, and 1.06 while listening through transitions and steady playback.

Pass requires pitch-stable listening without clicks, gaps, obvious warble, or unstable rate writes. Mechanical assignment alone is not proof. Record the route, source track, starting tempo, requested rates, observed behavior, and listening notes.

Fail means any required rate is audibly unacceptable or cannot remain applied. Audio quality outranks provider convenience, so the Apple Music path ends.

### Background and recovery gate

Prove five screen-locked minutes, pause, resume, next track, one controlled interruption, and one route loss. Every callback must carry identity into `RunEvent`; stale callbacks must be ignored by the reducer.

Pass requires continuous background audio, correct observable state, no unauthorized auto-resume after route loss, and a clean return to the run experience. If all four gates pass, Apple Music becomes the one production player.

### Local-file fallback

If any Apple gate fails, use SwiftUI multi-file import for supported DRM-free audio. Copy selected files into Application Support, release security-scoped access immediately, analyze each local file, and play through `AVAudioEngine`, `AVAudioPlayerNode`, and `AVAudioUnitTimePitch`.

The local path preserves the same source-neutral collection, track, tempo, cadence, progress, adaptation, event, and effect models. Only the provider adapter changes. Apple Music spike code is removed after its evidence and decision are saved.

## User Stories

1. As a runner, I want to choose a collection I already know, so that Samadhi becomes useful before it tries to recommend music.
2. As a runner, I want the chosen source to keep playing with the screen locked, so that a run does not depend on an open app.
3. As a runner, I want tempo changes to preserve pitch and sound natural, so that adaptation does not damage the music.
4. As a runner, I want incompatible tracks to play normally or be skipped honestly, so that the app never forces a bad match.
5. As a runner, I want route loss to pause safely and require an explicit resume, so that music does not restart unexpectedly.
6. As an Apple Music user, I want permission requested in context, so that I understand why Samadhi needs library access.
7. As an Apple Music user, I want my real playlists to load, so that setup is short and familiar.
8. As an Apple Music user, I want Samadhi to explain when Apple account or source access is unavailable, so that a configuration failure is not presented as an empty library.
9. As a local-file user, I want to import several songs in one action, so that the fallback still supports a meaningful run.
10. As a local-file user, I want imported songs copied into app storage, so that playback does not depend on a temporary Files permission.
11. As a local-file user, I want unsupported or protected files identified individually, so that one bad file does not discard the whole collection.
12. As a runner, I want analysis progress before a run begins, so that the app does not pretend an unknown track can be matched.
13. As a runner, I want real song progress and transitions, so that the ring and controls reflect the audio I hear.
14. As a runner, I want the lock state to mean a measured tempo match, so that the interface makes no beat-phase claim it cannot prove.
15. As a runner, I want the summary to report tempo-matched time only when it was measured, so that fixed rhythm remains Not measured.
16. As a developer, I want one production player, so that recovery, background behavior, and testing stay coherent.
17. As a developer, I want provider callbacks converted to source-neutral events, so that the reducer remains the owner of run phase.
18. As a developer, I want simulation behind the same boundaries, so that repeatable tests never require a personal library or network.
19. As a developer, I want physical traces to include source, device, OS, route, track, and result, so that a pass can be audited later.
20. As a maintainer, I want rejected provider code removed after the decision, so that the repository reflects the product rather than its experiments.

## Implementation Decisions

### One production player

The source decision is exclusive. Apple Music wins only if every gate passes. Otherwise local files win. There is no provider selector, no dual adapter graph, and no dormant rejected implementation.

### Existing seams remain authoritative

The device harness is the highest seam for provider feasibility. It observes authorization, catalog access, playback state, rate writes, interruptions, route changes, and trace export without leaking spike behavior into the normal run interface.

The production behavior seam remains:

`SwiftUI intent -> RunPresentationModel -> RunEvent -> RunReducer -> RunEffect -> provider adapter`

Audio and motion callbacks return through identified `RunEvent` values. SwiftUI does not call MusicKit, AVFAudio, or Core Motion directly. The reducer does not import platform frameworks.

### Automatic Apple token generation only

MusicKit's automatic token generation is the only accepted Apple catalog authentication path for this milestone. The exact App ID and a fresh exact-ID development profile are the final configuration test.

Do not:

- Embed a Media Services private key in the app
- Check a developer token into source control or app resources
- Add a Samadhi backend solely to mint tokens
- Fabricate a MusicKit entitlement
- Treat repeated reinstall attempts as new evidence

If a future public product needs server-managed Apple tokens for a separate documented reason, that requires a new architecture and security decision.

### Spotify disposition

Spotify is rejected as a production source for adaptive playback in Milestone 2.

| Requirement | Spotify result | Decision impact |
| --- | --- | --- |
| Import familiar playlists | Metadata access is possible with authorization | Helpful but insufficient |
| App-owned audio signal | iOS SDK controls the Spotify app remotely | Fails local analysis and processing needs |
| Live music rate control | No documented music playback-speed endpoint | Fails adaptation |
| Analyze track audio | Developer Policy prohibits analysis of Spotify content | Fails tempo pipeline |
| Alter track playback | Developer Policy requires content to remain in original form | Conflicts with Samadhi's core behavior |
| One coherent player | Would require Spotify plus another audio path | Violates one-player rule |

Spotify playlist metadata import is also deferred. It would create a second account and identity system while leaving playback unsolved. Local multi-file import is the smaller honest fallback.

### Tempo identity

The production collection persists provider-stable identifiers, not fuzzy title matches. Derived tempo metadata records algorithm version, confidence, analysis source, and date. Reanalysis invalidates stale results explicitly.

### Failure is a product decision

The harness records the first load-bearing failure with enough detail to reproduce it. Once a provider fails, implementation moves forward on the selected path. Samadhi does not spend the milestone accumulating provider workarounds.

## Testing Decisions

### Automated tests

Normal automated tests use source-neutral fixtures and never call Apple Music, Spotify, a personal library, or the network.

Keep deterministic coverage for:

- Half and double tempo normalization
- 0.94 through 1.06 rate bounds
- Initial and ongoing rate ramps
- Deadband and update interval
- Confidence hold and calm return to 1.00
- Track incompatibility
- Stale playback, import, analysis, interruption, and route identities
- Real progress and track transitions
- Honest tempo-matched measurement
- Fixed rhythm as Not measured

The chosen provider receives contract tests at the app boundary using fakes. Local analysis receives a versioned validation corpus with expected tempo ranges and explicit octave-error tolerance.

### Physical evidence

Each Apple gate trace records:

- Date and build commit
- Device and OS
- Bundle identifier, team, profile name, and profile App ID
- Apple Music account availability
- Playlist and selected track identities
- Headphone route
- Requested and observed playback rates
- Authorization, catalog, playback, interruption, and route events
- Full underlying errors
- Listening notes where sound quality is load-bearing

The token trace must distinguish a network response, an authorization denial, an empty catalog result, and automatic developer-token failure. A screenshot of the portal is configuration evidence, not runtime proof.

After source selection, the full serial Xcode gate must pass before a milestone commit. Physical cadence calibration, the route matrix, and the 20-minute outdoor run remain required before Milestone 2 is complete.

## Out of Scope

- A Spotify player or Spotify playlist import
- Two production music providers
- A Samadhi token backend
- Embedded Apple private keys or long-lived developer tokens
- External BPM services or title-based metadata scraping
- Playlist generation, recommendations, or AI curation
- Beat-perfect footfall phase alignment
- Visual redesign, dashboard, tab bar, settings sprawl, GPS, coaching, social features, analytics, or subscriptions
- Public App Store legal approval for preview analysis

## Further Notes

### Immediate execution order

1. Create or refresh an iOS App Development profile for the exact Samadhi App ID.
2. Sign a clean physical build with that profile and inspect the embedded identity.
3. Run one minimal catalog request and save the trace.
4. If it succeeds, run the ten-track tempo-source gate and then the remaining listening and recovery checks.
5. If it fails, record Apple Music as rejected, remove the spike, and implement local multi-file import plus the local audio engine.

### Verified platform sources

- [Apple MusicKit service configuration](https://developer.apple.com/help/account/services/musickit)
- [Apple automatic developer-token generation](https://developer.apple.com/documentation/musickit/using-automatic-token-generation-for-apple-music-api)
- [Apple developer-token request failure](https://developer.apple.com/documentation/musickit/musictokenrequesterror/developertokenrequestfailed)
- [Apple app capability and profile updates](https://developer.apple.com/help/account/identifiers/enable-app-capabilities/)
- [Spotify iOS SDK getting started](https://developer.spotify.com/documentation/ios/getting-started)
- [Spotify Developer Policy](https://developer.spotify.com/policy)
- [Spotify February 2026 development-mode changes](https://developer.spotify.com/documentation/web-api/tutorials/february-2026-migration-guide)

