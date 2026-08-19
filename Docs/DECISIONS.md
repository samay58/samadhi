# Decisions

## iOS 26 target

Use iOS 26 for personal prototype. One platform language is worth narrower compatibility. Revisit only if public distribution becomes active goal.

## Reproducible project

Use XcodeGen. Generated project stays versioned and reviewable. XcodeGen remains development-only dependency.

## Simulation boundary

Milestone 1 uses deterministic cadence and beat timing. It does not link Core Motion or production audio frameworks. Simulator proves interaction, not physical quality.

Normal Debug Simulator launches use isolated local placeholder playlists, simulated cadence, and silent simulated playback. This provides the complete product flow when MusicKit is unavailable without changing physical iPhone or Release behavior. The stable regression fixture remains separate from the richer demo collection so visual exploration cannot silently reorder golden tests. Remove the temporary demo entry point before public distribution if it no longer serves development.

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

Preview audio and future imported files both become a local audio-file URL before analysis. `LocalTempoAnalyzer` hides off-main PCM decoding and returns a versioned source-neutral result. `TempoEstimator` version 4 uses Accelerate spectral flux and fractional-lag autocorrelation from 60 through 210 BPM. It stores the measured musical pulse separately from an independently supported alternate pulse that can relate slower music to running cadence.

Version 1 passed 11 of 12 tempo-declared Apple workout previews but confidently labelled one 180 BPM mix as 60 BPM. Version 2 passed 12 of 12 only because it silently accepted half-time equivalence, including a declared 180 BPM track analyzed at 89.5 BPM. Version 3 restored exact pulse truth but rejected lower musical pulses by searching only 120 through 210 BPM. Version 4 keeps the musical pulse truthful, exposes any supported stride relationship explicitly, and passes all 12 public previews. In a private replay of the current 18-track selection, the saved version-2 analysis had 11 ready, version 3 had 10, and version 4 projects 14. Persisted results with older semantics reimport once. The validator and private replay download previews temporarily and commit only privacy-safe aggregates.

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

Automatic signing may still choose the wildcard team profile even when the exact profile is installed. Every MusicKit gate build must verify the embedded profile and application identifier before installation. A successful compile is not signing proof.

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

Debug builds overwrite one local `latest-run-diagnostics.json` file during a run and at completion. The bounded rolling trace records raw and filtered cadence, sample freshness, requested and applied rates, track identity, transition authority, recovery events, and the final summary when one exists. An abandoned or interrupted check therefore leaves useful evidence without adding analytics, a dashboard, or a run-history product. Release behavior and the visible run interface remain unchanged.

Each built app writes its own Git commit, branch, tracked-file state, build date, app version, and build number into the built Info.plist before signing. Debug diagnostics add the analyzer version, diagnostic-file version, device and system, real or simulated services, and sanitized launch arguments. A hidden Debug screen reads the same run state and diagnostic values. It is not a second state system and it is absent from the normal Release interface.

A player-confirmed song change clears the prior song's rate read-back, delay, and result before requesting a fresh Apple Music reply. A late reply for the old song remains invalid because request and track identity must both match.

## Manual rhythm control belongs in the core loop

Automatic cadence matching remains the default, but it is not the only control. The runner has one in-run BPM control to correct the feel and to prove that requested musical changes reach the real player. It supports a small Auto correction, a direct Manual target, and one-step reset to Auto. It remains bounded by the existing rate, ramp, confidence, and track-compatibility rules.

This is not a settings system and it does not bypass the reducer. SwiftUI sends intent. The reducer derives safe target rates, identified player effects carry the change, and MusicKit read-back remains the applied truth. The existing aperture becomes the direct manipulation surface, while requested and applied BPM remain visibly distinct. Physical proof must still confirm that this interaction changes real Apple Music playback cleanly.

## Compatible music before aggressive stretching

Weav achieved broad adaptation through licensed multi-arrangement material, not one extreme rate control applied to ordinary masters. djay treats song compatibility, BPM correction, beat alignment, key lock, and transitions as separate responsibilities. Samadhi will use the same separation without importing a DJ interface.

The production mechanic is coarse track fit followed by fine rate correction. `TrackMatchPlanner` evaluates explicit one-step-per-beat and supported two-steps-per-beat relationships while preserving the measured musical BPM. It does not silently multiply a slow beat or relabel the music. Startup preserves the first ready track in playlist order. During playback, current-track retention and source order beat a marginal compatibility improvement.

The prior production envelope was 0.90 through 1.10. Samay heard those endpoints clearly on Bluetooth, reported no unpleasant artifacts in earlier rate listening, and later reported approximately 95 percent confidence that the mechanism worked. Full-song listening and the final outdoor run remained open.

On 2026-07-21, one Beoplay Eleven check made the 0.90 versus 1.10 difference unmistakable on `LITE SPOTS`, with matching MusicKit read-back. Samay reported approximately 95 percent confidence that the mechanism worked and asked implementation to continue. Apple Music remains authoritative. This does not expand the production quality envelope because the wider endpoints have not passed full-song artifact listening.

On 2026-08-17, Samay chose a wider 0.85 through 1.15 software candidate. The same shared limit now controls Auto, Manual, track fit, diagnostics, and the final Apple Music command. Automatic playback still changes by no more than 0.02 rate units per second, so normal speed reaches either endpoint in at most eight seconds. Deterministic tests prove the limit, ramp, song boundaries, and read-back identity. They do not prove that 0.85 and 1.15 sound clean. The candidate must compare those endpoints with the known 0.90 and 1.10 pair on real Apple Music before release.

The tempo aperture is the BPM control. Turning its perimeter clockwise raises BPM and turning counterclockwise lowers it in one-BPM detents. The center remains protected for reading, a small perimeter marker appears only during manipulation, and VoiceOver exposes the same adjustment. Separate plus and minus furniture was removed because it made the control feel like a generic settings panel rather than one musical instrument.

Manual wheel travel is limited to the integer BPM values the current song can produce through its selected cadence relationship inside the current 0.85 through 1.15 candidate. One revolution equals 30 BPM, minor haptics are low-sharpness and rounded, every fifth detent is fuller, and returning to neutral has one soft landing. At either song boundary, the number, marker, detents, and haptics stop together. One terminal haptic marks the limit, outward motion stores no hidden overshoot, and ordinary reverse motion releases the control immediately. Broader playlist coverage comes from an explicit Skip or natural boundary, not unreachable wheel travel.

The closed aperture teaches its interaction without tutorial copy. Three grip notches appear in the same rim used by the full wheel and make one restrained clockwise-and-back movement after cadence locks. `Turn` is etched into the lower aperture as the only visible word because it names the physical gesture directly. Opening the control removes that label, expands the marks into 30 detents, and permanently retires the teaching movement. Reduce Motion keeps the static cues and skips the movement.

Adaptive run start preserves the first ready track in imported playlist order. It does not invent a cadence before Core Motion supplies a fresh one. During a run, five seconds of stable incompatibility may prepare a better-fitting next song. The current song continues unless the runner uses Previous or Skip, or the player confirms a natural boundary. Every prepared choice carries selection identity so a stale callback cannot replace newer intent, and every observed transition records its authority.

## Requested BPM is intent; player read-back is truth

The wheel previews one-BPM detents and haptics locally, stays pinned for the full gesture, then sends one absolute target when the finger lifts. Turning the wheel takes Manual ownership. That final target is durable when cadence changes and jumps directly to its compatible playback rate. Auto first commits a separate settled target under the policy recorded below. Once that target changes, the existing playback policy keeps its 2 SPM rate deadband, one-second update interval, and 0.02 rate-units-per-second ramp. Moving from normal speed to either candidate endpoint takes at most eight seconds. The interface may call a value applied only after `ApplicationMusicPlayer` reports the commanded rate for the current session, operation, request, and track.

The first Core Motion sample must be no more than two seconds old because no earlier timestamp can prove that it is new. A delayed later sample may be accepted only when its callback and Core Motion end time advance coherently within the bounded delivery interval. Repeated, backward, out-of-order, unexplained-gap, missing, and outside-supported-range samples still fail. Three agreeing accepted samples acquire or reacquire cadence. During tracking, one large change waits for a corroborating sample, then a time-based response follows the sustained change. Three consecutive invalid samples return Auto to reacquisition.

The August 15 phone trace established this rule. Fourteen of 16 numeric readings arrived about 2.57 seconds after their Core Motion end time, so the old fixed two-second rule never locked. The saved trace failed before the change and passes after it. The August 17 workout then physically confirmed the repair: four supported readings arrived at the same delayed cadence, Auto settled at 133 SPM, and Apple Music reported the exact 1.0390625 command after 0.066 seconds.

## Manual belongs to the confirmed song

Manual remains active while the player is on the same confirmed song, including pause, resume, route loss, and explicit recovery. Previous or Skip requests do not reset it because the player may reject or delay the change. Manual returns to Auto only when the player confirms a different song, or when the runner explicitly chooses Auto.

A confirmed different song starts with fresh adaptation state. It cannot inherit the prior song's requested result, delay, Apple Music reply, or verification. A late reply identified for the prior song is rejected.

## The tempo wheel closes without changing the run

The open tempo wheel has one native close action. Closing restores playback controls immediately. It does not pause, skip, change the requested rhythm, reset Manual, or alter the current song. The action has a 44-point hit target, a clear accessibility label, and the same immediate Reduce Motion behavior as the existing control surface.

The visible close mark is smaller than its touch target and sits clear of the rotary ring. It uses a flat, low-contrast surface at normal settings and a stronger surface only for Increased Contrast. The earlier 44-point glass circle was removed because it covered detents and competed with the instrument.

## Dirty builds carry a stable source fingerprint

The build captures the fingerprint before compilation. It hashes relative paths and file contents for `App`, `Resources`, package source, `Config`, `project.yml`, the generated Xcode project, the package manifest and lock file when present, and the scripts that capture and embed build identity. Modified and untracked files in those locations are included.

Tests, documentation, evidence, build products, local diagnostics, app data, credentials, certificates, provisioning profiles, and signing material are excluded. The fingerprint contains only a hash. It exposes no source text, playlist data, account details, or secrets.

## Auto keeps sensing and music commitment separate

The cadence filter remains the responsive sensor estimate. A separate domain policy owns the settled Auto target. Raw cadence cannot reach the playback policy while that target is empty. Running can settle after the sensor filter locks. Cadence from 90 through 119 SPM needs five seconds of steady evidence because walking overlaps more with ordinary gym movement. Later target changes also need five seconds of agreement. The target ignores changes inside four steps per minute, requires a change of at least six steps per minute, and keeps commits at least eight seconds apart. Missing input holds the target for up to twelve seconds before reacquisition.

These constants are software defaults based on the saved 2.56-second phone delivery pattern and the existing product tests. They are not physically tuned. A real phone check must decide whether the music feels calm and responsive.

## Expand rhythmic walking, not lifting

The August 17 workout mixed brisk walking, light jogging, and substantial lifting. That prevents a precise comparison between wall time and counted rhythmic time. It does not weaken the case for a lower walking range.

The software candidate extends Auto into steady movement from 90 through 210 SPM. Values below 90 remain outside Auto. Walking needs five seconds of steady evidence, while three disagreeing values or missing readings cannot accumulate a target. A clean walking-only phone check must still tune the floor and delay.

Samadhi has no lifting mode. It accepts only the step cadence that Core Motion reports and does not classify the exercise type. Missing or irregular readings make Auto hold briefly, ease the song toward normal speed, then reacquire. A clean phone check must still show whether pocket movement during lifting can fool the step signal.

Manual cannot display or commit an unreachable target. Its preview and final command share the current song's derived integer BPM envelope, so the requested value always has a truthful rate inside 0.85 through 1.15. Auto may still encounter cadence outside that envelope. In that case the current song holds the nearest reachable rate, while requested cadence and achievable Music BPM remain separate truths. Stable Auto mismatch may prepare one latest candidate after five seconds, but preparation never changes transport. Only explicit Skip or a player-confirmed natural boundary may commit the prepared song.

Approximate alignment accepts up to five SPM of remaining error. The playback candidate now spans 0.85 through 1.15. This should reduce unnecessary song changes while keeping small residual differences acceptable. Six SPM still fails.

The saved 15-track ready collection report shows the effect of the prior 0.90 through 1.10 envelope without exposing private music data. It found four compatible tracks around 90 and 100 SPM, seven around 110, and six around 120. Those counts must not be relabeled as evidence for the wider candidate. The aggregate report lives under `Evidence/Device/2026-08-17-walking-auto/`.

## Tempo-matched summaries require verified coverage

Tempo-matched time is eligible only while playback is active, a valid Automatic cadence or Manual reference exists, and MusicKit has verified the current rate command. A run must reach 80 percent eligible coverage before showing a percentage. Lower coverage reports Not measured. Debug diagnostics also preserve coverage plus Automatic and Manual seconds so a high percentage cannot hide a long unmeasured segment.

## Playlist identity anchors music setup

Music setup uses one composition from selection through analysis, readiness, and recovery. Once selected, the playlist name remains the visual owner while exact progress and actions change around it. The empty state keeps only the public tagline and one music action. Playlist loading stays in that composition instead of replacing it with a generic spinner screen.

The ready surface shows only the honest ready count, Start, and a subordinate playlist-change action. A partial import uses one compact ready and skipped disclosure; every typed track result remains available in a native sheet. Import failures preserve playlist context and offer action-specific recovery. A valid retry targets the same playlist, while authorization and selection failures route to settings or another playlist as appropriate.

Import runs at most three ordered tracks at once. Progress begins with the complete pending source list, stays deterministic, and preserves playlist order. Debug timing records catalog, download, analysis, total track time, and total wall time without song metadata. Concurrency may change only from physical timing evidence.

The composition is divided into playlist identity, a truthful status rail, and an action dock. A derived `SetupVisualStage` enum controls only presentation transitions; import truth remains owned by the existing model state. At standard sizes, subordinate content hands off in one interruptible 210-millisecond sequence so outgoing and incoming labels never occupy the same space. Reduce Motion replaces the stage immediately. Selection feedback is tied to an accepted playlist choice, and readiness feedback fires only when a new import first becomes runnable. Restoration and redraw do not replay either event.

## Direction is part of the wheel haptic

Clockwise and counterclockwise detents remain distinct through the domain event and Core Haptics pattern. Ordinary detents are stronger than the first field build, every fifth BPM keeps a fuller landmark, and unsupported devices receive direction-specific system impact fallbacks. Physical comfort and direction recognition remain required before this decision is considered tuned.

## Auto changes use touch and sound, not screen copy

The August 17 workout made the gap concrete. Samay felt Auto working, but the changes felt jarring and unexplained. The runner is unlikely to be looking at the phone, so temporary text on the run screen is rejected.

The accepted later direction is one identified Auto transition with two sparse moments. The first matching Apple Music reply produces a short faster or slower haptic. A final matching reply produces one quiet authored sound with a soft terminal haptic. Direction comes from the pattern's timing and shape. No more than three coarse strength levels express reachable change size.

The software half of this now exists. A reducer-owned transaction decides when a cue is valid, and `AutoFeedbackService` owns the Core Haptics engine, its stopped and reset handlers, the registered audio resources, and the fallback to a local audio player. The exact AHAP patterns, sound family, Core Haptics audio path, fallback, and intensity bands stay unapproved. They need physical comparison with the phone in a pocket, the screen locked, and real music playing. The full contract lives in [AUTO-CHANGE-INTERACTION-SPEC.md](AUTO-CHANGE-INTERACTION-SPEC.md).

What remains is physical. Nothing in the prototype set has been felt or heard: tactile character through a pocket, blinded direction recognition, how the arrival sounds sit against real Apple Music, whether music ducks or gaps, locked-screen delivery, and survival through an interruption and an engine reset on a device.

## Transport and Finish are one instrument

Previous, Pause or Resume, and Next were first rebuilt as one glass capsule bar rather than three floating pills, with a faint raised disc behind the primary symbol. On the phone that bar read as a milky slab with a ghost circle in it, and Samay called it a regression. The capsule was the problem: a wide glass surface over a warm dark field turns gray, the symbols shrink inside it, and the whole thing looks like a placeholder. The bar is gone.

Transport is now three separate Liquid Glass circles inside one `GlassEffectContainer`, which is how the system itself draws controls over media in iOS 26. Each circle is its own lens over the field, so the material reads as glass instead of a slab. Previous and Next are 68 point clear glass circles with ivory symbols. Pause or Resume is an 88 point circle with a light ivory tint and an ink glyph, so it reads as the brighter, nearer object and the hierarchy holds at arm's length; it swaps the glyph for the paused state. A bare-symbol version with one solid disc was built in between and rendered cleanly, but it gave up the material entirely, and the ask was glass done well, not glass removed.

Every circle uses interactive glass, so a touch gets the system's own brightening and lensing. On top of that the control compresses to 0.88 on a quick spring and springs back on release, because the earlier bar answered a press with almost nothing and felt static. Reduce Motion swaps the spring for a plain dim with no animation. While Finish is armed the row dims to about a third instead of vanishing, so the armed state reads as focus on one control and not as a hole in the layout.

Finish sits below the row and stays quiet. It is a text button with a hairline ivory capsule stroke, no glass at rest, and a 38 point visible pill inside a 44 point touch height. Tapping it arms the hold in place. Finish and the hold are one control with one identity, not two views swapped in a slot, so there is never a second border or a second word on screen. The word and the width change in a single frame; only the material and tint animate.

The hold progress fill is drawn inside the label and clipped by the same capsule that draws the button, so it moves and clips with the pressed shape and cannot leave the border. `FinishHold.durationSeconds` is one constant shared by the reducer's hold window, the long-press minimum, and the fill animation, so the visible sweep and the accepted press can never disagree.

Pressing a transport control compresses it to 0.88 on a spring of about 220 milliseconds while the interactive glass brightens. Under Reduce Motion the control dims with no scale and no animation. The hold fill still sweeps under Reduce Motion, because a determinate progress indicator is the point of the control. That is a deliberate change from the earlier frozen fill.

Touch carries the difference between a request and an event. An accepted Previous or Next tap gets one selection tick, which says the request was sent and not that the song changed. Arming Finish gets one soft impact. Completing the hold keeps the existing heavy impact. Pause and resume keep their existing medium and light impacts, and the run start and lock are unchanged.

## Auto feedback is a reducer-owned transaction

One meaningful Auto change is one identified transaction. The reducer opens it only in Auto mode, on the confirmed song, when a settled target differs from the last remembered one and the reachable change in step rhythm is at least six steps per minute. The origin is the applied playback rate at commit. The target is the policy target rate, or the clamped boundary when the song is already at its limit.

The start fires on the first identified, verified Apple Music reply that moved the applied rate from the origin toward the target. The arrival fires on a verified reply within 0.005 of the target rate. One reply may produce both. Each transaction emits at most one start and at most one arrival. Nothing else qualifies: not raw or filtered cadence, not an unsettled candidate, not intermediate ramp replies, not a pending, mismatched, rejected, or stale reply, not a reaffirmed target, not a Previous or Next tap, not an old song after a change, and not a transaction that already arrived.

Stopping a cue has two shapes, and the difference matters. Manual takeover and a lost Auto target cancel the cue and forget the remembered target, because the runner or the policy changed intent; choosing Auto again may open a fresh transaction. Route loss, interruption, playback failure, and finish cancel the cue but keep the remembered target, so recovery resumes at the same speed without replaying a cue for a change the runner already felt. A new qualifying target silently replaces the transaction in flight. Pause preserves it. A rejected read-back preserves it.

A confirmed different song clears the transaction state but leaves the identity counter rising. Identifiers are never reused, so a late effect carrying an old identifier cannot be mistaken for the current transaction. The reducer emits the cue and the cancel as effects; the shell only plays what it is handed.

## Song changes carry a cause

MusicKit reports that the current entry changed, never why. Samadhi now decides a cause and records it. A Previous or Next command that Samadhi issued claims the next observed change inside a five second window; a failed command drops the claim, so a later natural boundary is not mislabeled. With no claim, the change counts as a natural end only when the previous song's last observed playback time was within 10 seconds of its duration. Everything else is an outside change, which usually means Control Center, the Music app, or a headphone button.

The rule is a pure function with its own tests, and the hidden Debug screen shows the result as `Last song change`. This exists so that a natural boundary can be told apart from an outside change before any feedback is attached to a boundary, and so a phone check can confirm the cause instead of guessing it.

A same-song callback is now recorded as its own diagnostic entry. The reducer still ignores it and Manual still survives it. The entry exists as evidence that the player repeated itself, not as a state change.

## Auto feedback prototypes are offline originals

Three families exist for the physical comparison: pulse, two transients; swell, one continuous event with rising or falling curves; and step, three transients with tightening or widening gaps. Each family carries both directions and three size bands, which scale peak intensity only and never reorder events, so the learned direction holds at every size. Six arrival sounds were synthesized offline by `Scripts/generate-auto-feedback-sounds.py` using only the Python standard library. There is no sample pack, no recording, no library asset, and no third-party license to preserve, because there is no third-party material in these files. Re-running the script with the same parameters reproduces the same bytes.

None of this is a product asset. The preferred final path is still a small paid commission using this brief and the physical prototype. These files exist so that the phone comparison has something concrete to compare.

`AutoFeedbackService` owns the engine, not the views and not the reducer. It starts one Core Haptics engine lazily with audio allowed, keeps stopped and reset handlers, drops cached players and re-registers audio resources on a reset, and stays silent on hardware without haptics while the sound still plays through a local player. The app configures no `AVAudioSession` category, mode, or active state anywhere, so Samadhi asks for no ducking; the only session use is reading route and interruption notifications.

The audition screen is Debug only. It reaches the app through the `--feedback-audition` launch argument and the `Samadhi Feedback Audition` scheme, and it plays patterns by hand so a person can compare them. Release contains none of its strings or symbols. The prototype files themselves are still packaged in Release, which is the honest state of a prototype set that has not been chosen from yet.

## Catalog ties are broken, not rejected

The strict catalog resolver used to give up when two catalog songs matched a library track on title, artist, album, and duration within half a second. On the phone that threw out five of seventeen songs in one playlist and most of a rap playlist, because Apple Music lists the explicit and clean edits of a song with identical metadata and identical length. A tie like that is the normal shape of the catalog, not an ambiguity that protects the runner from a wrong song.

The resolver now tries the library item's own catalog identifier first, read from the encoded play parameters, and falls back to the metadata search only when that is missing. When the search still ties, a pure selection rule picks the candidate whose content rating matches the library track, prefers the explicit edit when the library rating is unknown, and otherwise picks deterministically by duration and identifier. Tempo analysis is identical across the edits, so the preview is the same evidence either way; the rating rule exists so playback stays on the edit the runner put in the playlist. Nothing within three seconds still means no match.

This does not touch the other cause of an unready song. A preview whose thirty seconds carry no steady pulse is still reported as rhythm unclear, because the product promises not to adapt a song it cannot time.

## A tempo is judged with its family

Version 4 scored each candidate tempo alone and then trusted whichever peak stood highest in the running range. On real music that failed in one specific way. A swung or shuffled groove repeats its attacks strongly at one and a half beats, and a dotted-eighth pattern repeats at three quarters of a beat, so the analyzer saw a tall peak at two thirds or four thirds of the true tempo, counted it as a rival, and either rejected the song as rhythm unclear or, worse, reported the rival as the beat. On one playlist it rejected Nightrider, Strings of Light, and Feelin, and on the phone's cache it had reported Gesaffelstein at 144 instead of 109, Dego and Kaidi at 152 instead of 114, and Kokoroko at 175 instead of 130.

Version 5 changes three things and nothing else. Each candidate is scored together with its half or double, with support lags computed from 30 through 420 BPM so a 117 BPM beat can still be backed by 58.5. When the low and high candidates are not a half-double pair, the stronger family wins instead of the running-range peak winning by default. And lags at a simple ratio to the candidate, one half, two, two thirds, three halves, three quarters, four thirds, one third, and three, no longer count as rivals when measuring confidence, because they are the same groove seen through another subdivision. The deliberate rejection of a low pulse with a strong triple stays, the confidence bar stays at 0.72, and the 2 percent corpus gate stays.

The analyzer version moved to 5, which invalidates every cached result on purpose. A song that was confidently wrong under version 4 must be measured again, not trusted. Songs whose 30 seconds hold no steady pulse above the bar are still rejected; that is the product keeping its promise not to adapt a song it cannot time.

