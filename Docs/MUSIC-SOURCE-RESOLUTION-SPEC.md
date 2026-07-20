# Music source resolution specification

Status: Apple Music selected; long-form reliability checks deferred

## Problem Statement

Samadhi needs one production music source that can import a runner's collection, expose or support local tempo analysis, play in the background, and change playback rate from 0.94 through 1.06 without audible damage.

The physical MusicKit harness has proved authorization, library playlist loading, automatic token generation, strict catalog resolution, 10 of 10 local preview decodes, real playback, live rate writes, pause, and resume. It also reached a Beoplay Eleven Bluetooth A2DP route and applied 0.94, 1.00, and 1.06 during playback. The exact Samadhi development profile fixed the earlier `developerTokenRequestFailed` blocker. A separate opt-in validator now passes 12 of 12 tempo-declared Apple previews through analyzer version 2.

Spotify was considered as another streaming source. It is not a viable adaptive-audio player for this milestone. Spotify's iOS SDK remotely controls the Spotify app rather than giving Samadhi an app-owned audio signal. Its documented player APIs do not offer music playback-rate control, and Spotify's Developer Policy prohibits altering or analyzing Spotify content. A Spotify playlist could provide metadata, but it would not close the adaptive playback loop and would add OAuth, account, and provider complexity.

On 2026-07-16, Samay explicitly tabled further repetitive manual drills so implementation could continue. Apple Music became the one production source. Five locked minutes, track change, controlled interruption, route loss, and a dedicated Bluetooth listening note remain required before Milestone 2 completion. Samadhi will not build a token backend, embed a Media Services private key, maintain two production players, or reopen Spotify.

## Solution

The source was resolved after the token, tempo-source, real-playback, speaker-listening, Bluetooth-route, and live-rate results removed the load-bearing feasibility unknowns. Remaining manual work is now a reliability gate for the selected adapter.

### Token identity gate

Result: Passed on 2026-07-16. The exact `Samadhi Development` profile produced repeated real catalog responses.

1. Confirm the exact App ID `com.samaydhawan.Samadhi` exists under team `ZL5U59XBJ6` and its MusicKit App Service is enabled.
2. Replace the current wildcard development provisioning profile with a fresh development profile bound to the exact App ID.
3. Regenerate, clean, sign, install, and launch the MusicKit harness on the physical iPhone.
4. Inspect the built app and embedded profile. Record the application identifier, team identifier, bundle identifier, profile name, profile App ID, device, OS, and build timestamp.
5. Run one minimal catalog request before playlist sampling. Save the complete result and underlying error in the trace.

Pass means the installed app receives Apple's automatic developer token and obtains a real catalog response. Fail means the same signed physical build returns `developerTokenRequestFailed` after the exact profile is installed. One transient retry after a clean reinstall is allowed. Repeated retries, hidden token workarounds, and speculative entitlement changes are not.

If the gate fails, record Apple Music as rejected for Milestone 2 and begin local-file playback. Apple Developer Support can be contacted later, but support latency does not block the useful product path.

### Tempo-source gate

Result: Passed on 2026-07-16 for City Pocket. Strict title, artist, album, and duration agreement resolved all ten tracks to numeric catalog IDs. All ten remote previews downloaded into temporary app storage and yielded decoded PCM.

After the token gate passes, select one real library playlist and resolve ten chosen tracks to catalog songs. Attempt decoded local analysis using the documented preview or another documented local tempo source.

Pass requires analyzable audio or documented tempo for at least eight of ten tracks. A strict title, artist, album, and duration match may resolve an opaque library identity to a provider-stable catalog identifier. Ambiguous results fail closed, and the returned numeric catalog identifier becomes the persisted identity. Fuzzy title matching and external BPM databases are not accepted.

Fail means fewer than eight of ten tracks can be analyzed reliably. The Apple Music path ends because Samadhi cannot make an honest adaptation decision without track tempo.

### Playback quality gate

Use one known-tempo track and `ApplicationMusicPlayer` on the same physical iPhone and headphone route. Exercise 0.94, 1.00, and 1.06 while listening through transitions and steady playback.

Current result: Built-in-speaker listening passed provisionally. The rate changes sounded like genuine speedup and slowdown without major pitch change or unpleasant artifacts. Bluetooth routing and rate writes pass on Beoplay Eleven. A separate Bluetooth listening note remains open.

Pass requires pitch-stable listening without clicks, gaps, obvious warble, or unstable rate writes. Mechanical assignment alone is not proof. Record the route, source track, starting tempo, requested rates, observed behavior, and listening notes.

Fail means any required rate is audibly unacceptable or cannot remain applied. Audio quality outranks provider convenience, so the Apple Music path ends.

### Background and recovery gate

Before Milestone 2 completion, prove five screen-locked minutes, pause, resume, next track, one controlled interruption, and one route loss. Every callback must carry identity into `RunEvent`; stale callbacks must be ignored by the reducer.

Pass requires continuous background audio, correct observable state, no unauthorized auto-resume after route loss, and a clean return to the run experience. Apple Music is already the selected production player, but Milestone 2 cannot complete until this gate passes.

### Closed local-file contingency

Before source selection, a load-bearing Apple Music failure would have selected SwiftUI multi-file import and an app-owned audio engine. That contingency is now closed for Milestone 2. A future platform-level failure requires a new explicit source decision; it does not justify maintaining two players.

The source-neutral collection, track, tempo, cadence, progress, adaptation, event, and effect models remain deliberately independent of MusicKit. This keeps the architecture honest without carrying a dormant second adapter.

## User Stories

1. As a runner, I want to choose an Apple Music collection I already know, so that Samadhi becomes useful before it tries to recommend music.
2. As a runner, I want music to continue with the screen locked, so that a run does not depend on an open app.
3. As a runner, I want tempo changes to preserve pitch and sound natural, so that adaptation does not damage the music.
4. As a runner, I want incompatible tracks to play normally or be skipped honestly, so that the app never forces a bad match.
5. As a runner, I want route loss to pause safely and require an explicit resume, so that music does not restart unexpectedly.
6. As an Apple Music user, I want permission requested in context and configuration failures explained plainly.
7. As an Apple Music user, I want my real playlists to load in their original order.
8. As a runner, I want analysis progress before a run begins, so that Samadhi does not pretend an unknown track can be matched.
9. As a runner, I want real song progress and transitions, so that the ring and controls reflect the audio I hear.
10. As a runner, I want lock and summary language to report measured tempo matching without implying foot-strike phase.
11. As a developer, I want provider callbacks converted to identified source-neutral events, so that the reducer remains the owner of run phase.
12. As a developer, I want deterministic simulation and auditable physical evidence, so that normal tests do not require a personal library or network.

## Implementation Decisions

### One production player

Apple Music is the selected production player. There is no provider selector, dual adapter graph, or dormant local-file implementation. Deferred reliability checks can block Milestone 2 completion, but they do not silently reopen the source decision.

### Existing seams remain authoritative

The device harness is the highest seam for provider feasibility. It observes authorization, catalog access, playback state, rate writes, interruptions, route changes, and trace export without leaking spike behavior into the normal run interface.

The production behavior seam remains:

`SwiftUI intent -> RunPresentationModel -> RunEvent -> RunReducer -> RunEffect -> provider adapter`

Audio and motion callbacks return through identified `RunEvent` values. SwiftUI does not call MusicKit, AVFAudio, or Core Motion directly. The reducer does not import platform frameworks.

### Calibration controls are not the product interaction

The 0.94, 1.00, and 1.06 buttons exist only in the device harness. The production app continuously derives a target rate from stable cadence, applies bounded ramps, ignores changes inside the deadband, returns calmly toward 1.00 when confidence falls, and skips or leaves incompatible tracks unchanged. The initial safe range is evidence-based, not a claim that adaptation must remain visually or behaviorally static. Prefer selecting a more compatible next track over stretching one song far beyond the proven range.

### Automatic Apple token generation only

MusicKit's automatic token generation is the only accepted Apple catalog authentication path for this milestone. The exact App ID and `Samadhi Development` profile passed that configuration test.

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

Spotify playlist metadata import is also deferred. It would create a second account and identity system while leaving playback unsolved.

### Tempo identity

The production collection persists provider-stable identifiers, not search strings. Strict metadata agreement may resolve an opaque library track once, but the returned numeric catalog identifier is stored after resolution. Derived tempo metadata records algorithm version, confidence, analysis source, and date. Reanalysis invalidates stale results explicitly.

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

The chosen provider receives contract tests at the app boundary using fakes. Local analysis has generated offline fixtures plus an opt-in 12-preview Apple corpus with expected tempo ranges and explicit octave-error tolerance. Provider-hosted audio remains temporary.

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

1. Relaunch the physical app and prove the persisted 13-ready-track collection restores.
2. Run through a real track transition and confirm progress, cadence, applied-rate behavior, and the saved diagnostic file.
3. Complete Bluetooth listening, five locked minutes, controlled interruption, and route loss before Milestone 2 completion.

### Verified platform sources

- [Apple MusicKit service configuration](https://developer.apple.com/help/account/services/musickit)
- [Apple automatic developer-token generation](https://developer.apple.com/documentation/musickit/using-automatic-token-generation-for-apple-music-api)
- [Apple developer-token request failure](https://developer.apple.com/documentation/musickit/musictokenrequesterror/developertokenrequestfailed)
- [Apple app capability and profile updates](https://developer.apple.com/help/account/identifiers/enable-app-capabilities/)
- [Spotify iOS SDK getting started](https://developer.spotify.com/documentation/ios/getting-started)
- [Spotify Developer Policy](https://developer.spotify.com/policy)
- [Spotify February 2026 development-mode changes](https://developer.spotify.com/documentation/web-api/tutorials/february-2026-migration-guide)
