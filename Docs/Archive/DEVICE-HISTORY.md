# Device history

Records moved out of the live docs on 2026-11-02, word for word. They describe builds and machines at the time. Current truth is in [STATUS.md](../STATUS.md).

## Device checks through 2026-08-19

- Unsigned generic iPhone build: passed
- Signed generic and physical iPhone builds: passed
- Current BPM-control exact-profile signed build, installation, launch, and running process check: passed
- Physical iPhone installation and gate launch: passed
- Normal Simulator app: launched and visually checked
- Normal Debug Simulator local-demo flow: two playlists, start, cadence lock, rotary BPM, transport, transition, finish, and summary passed without Apple Music
- MusicKit harness Simulator app: launched and visually checked
- Background audio entry in built Info.plist: verified as an array containing `audio`
- Physical device signing, build, installation, and launch: passed
- Import-capable normal app exact-profile build, installation, and launch: passed
- Latest-run diagnostics exact-profile build and installation: passed; existing selected playlist survived byte-for-byte
- Latest-run diagnostics foreground launch: blocked because the physical iPhone is locked
- Focused body-to-music exact-profile build, installation, and launch argument: passed
- Physical cadence seam: passed for a 29-second walk with changing cadence and a 142 SPM average
- Automatic cadence-driven rate response: passed; the corrected 59-second physical run averaged 155 SPM and measured 98 percent tempo matched from MusicKit read-back
- Focused rate diagnostics: target, pending feedback, and MusicKit read-back are shown separately; commanded values are no longer echoed as applied
- Contextual Music authorization and 40-playlist loading: passed
- Real playback plus 0.94, 1.00, and 1.06 rate writes: passed mechanically
- Pause and resume observation: passed
- Direct library preview coverage: failed at 0 of 10 in every sample
- ISRC catalog retry: blocked because all 40 sampled tracks omitted ISRC
- Exact-App-ID signing: passed with `Samadhi Development` and application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`
- Automatic developer token: passed with repeated direct catalog responses
- Strict catalog resolution: passed for 10 of 10 City Pocket tracks with 0.0-second duration deltas
- Temporary preview download and PCM decode: passed for 10 of 10 City Pocket tracks
- Built-in-speaker listening: passed provisionally; no major pitch change or unpleasant artifacts were reported at 0.94 and 1.06
- Bluetooth A2DP route: passed on Beoplay Eleven
- Bluetooth rate writes during playback: passed at 0.94, 1.00, and 1.06
- Bluetooth listening note: not recorded
- Spotify adaptive playback: rejected by documented platform capability and policy review; no code spike warranted
- Screen-lock background, next track, controlled interruption, and route-loss checks: deferred to the reliability gate
- Real playlist selection and analysis: the July import passed at 13 ready, 8 unreadable, and 4 unavailable tracks from a 25-track physical selection; the latest pulled collection has 15 saved ready analyses
- Reinstall and relaunch restoration: passed with the selected collection checksum unchanged and the physical ready screen showing 13 of 25 ready
- Production-player progress: passed from a pulled schema-version-2 trace advancing from 0 through 6 seconds on one stable catalog identity
- Imported natural track transition: not yet physically run
- BPM control: deterministic command truth, rapid-detent coalescing, compatible-track response, rotary UI interaction, and Simulator design pass; physical audible response and directional click-wheel feel remain open
- Blinded perceptibility harness: 0.92 versus 1.08 sequence, direction answer, MusicKit read-back trace, the known 0.90 and 1.10 controls, and the candidate 0.85 and 1.15 controls compile in the debug gate scheme
- Paired iPhone state on 2026-07-21: connected over the local network; the exact-profile MusicKit harness built, installed, launched, and showed Beoplay Eleven as its Bluetooth A2DP route
- Exact profile state on 2026-07-21: embedded `Samadhi Development` profile verified with application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`; it expires on 2026-07-23 UTC
- One-track perceptibility result: 0.90 versus 1.10 was clearly audible on `LITE SPOTS` through Beoplay Eleven, with repeated requested and reported rate agreement
- Full perceptibility protocol: open; 0.90 versus 1.10 is the only physically heard pair. The 0.85 through 1.15 candidate needs full-song endpoint quality and matching Apple Music read-back before release.
- Production track-fit and rotary-control build: exact-profile signing, embedded application identifier, wireless installation, foreground launch, and normal setup rendering passed on the restored iPhone on 2026-07-22
- First normal field run: historical red evidence; 497 wheel adjustments and a 59-BPM requested span produced only a 0.056 MusicKit read-back span, while the summary reported 99 percent from automatic-only eligible samples
- Field-run remediation: privacy-safe replay, truthful command states, prompt read-back, nearest-boundary behavior, noncommitting candidate preparation, target reapplication, and honest coverage pass deterministically
- Import remediation: full six-track disclosure fixture, typed failure sections, retry after relaunch, ordered three-track batching, and timing persistence pass in Simulator and model tests
- Exact BPM and fresh Auto repair: formatter lint, 97 package tests, 15 app-model tests, 10 UI tests, exact `Samadhi Development` signing, application identifier verification, physical build, and installation passed on 2026-07-22; foreground launch waited on the locked phone and was not claimed
- Physical remediation check: open for audible direction, command latency, compatible track change, clockwise versus counterclockwise haptics, and real import wall time
- Historical July release profile: `Samadhi Development` UUID `982e709d-7aa8-4d79-aca3-7759c8f70fc5` expired on 2026-07-30 UTC and embedded `ZL5U59XBJ6.com.samaydhawan.Samadhi`. A later device build must inspect its own embedded profile.
- Current response-latency build: clean commit `66e0616`, exact-profile build, signature inspection, physical installation, and selected-collection checksum preservation passed; foreground launch was blocked by the locked phone
- Current setup-craft build: clean commit `0a59b64`, exact-profile build, embedded identity and signature inspection, in-place physical installation, and selected-collection checksum preservation passed; foreground launch was blocked by the locked phone
- 2026-08-15 exact phone build: profile `Samadhi Development 2026-08-15`, embedded identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`, app signature match, in-place install, and selected-collection checksum preservation passed
- 2026-08-15 phone baseline: 16 numeric Core Motion readings ranged from 151.56 to 158.10 SPM; 14 were about 2.57 seconds old and failed the 2.0-second freshness check, leaving only two accepted readings when three are required to lock
- 2026-08-15 Apple Music baseline: Manual and Auto rate writes were reported in about 0.04 to 0.07 seconds; one Auto read-back differed from the requested rate by about 1.19 SPM
- 2026-08-17 fingerprinted workout: the pulled file matched source fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498`; four supported delayed readings acquired 133 SPM, and Apple Music reported the exact 1.0390625 command after 0.066 seconds
- 2026-08-17 activity mix: 57 of 61 retained numeric cadence readings were below the current 120 SPM contract; substantial lifting occurred during the same period, so the low readings and elapsed time cannot all be attributed to walking
- Walking-range tuning: use a clean walking-only check before calling the 90 SPM floor and five-second delay physically tuned
- Transport, song-change cause, and Auto feedback candidate: clean commit `67adf80`, exact-profile build, embedded identity and strict signature inspection, in-place install, selected-collection checksum preservation, and an on-device Debug screen read-back of source fingerprint `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6` passed on 2026-08-19; the audition scheme builds for the phone; every physical judgment in `Docs/PHONE-CHECK-2026-08-19.md` stays open. Later the same day commit `13e88bf` (glass transport circles, catalog tie fix) was built with the same profile and installed in place with the selected collection unchanged; its in-app source fingerprint read `085e5fe7b0e080a19efe281bd69fa5ebaeab00e0d082bc64701cd03d98de4f82` on the device, equal to the built Info.plist

## Gate state through 2026-08-19

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

## Runbook: Denver test build

1. Open Samadhi and tap `Choose music`. The 2026-07-22 device restore cleared the prior local selection.
2. Select one Apple Music playlist. The earlier `Strut Frequency -- July 2026` proof produced 13 ready tracks from 25 before the restore.
3. Read the result honestly. Ready tracks can run; unreadable or unavailable tracks remain visible but do not enter playback.
4. Confirm the restored collection still reports ready tracks, tap `Start`, and allow motion access if asked.
5. Close and reopen Samadhi. Confirm the same playlist returns without another choice.
6. During a short run, turn the aperture perimeter to adjust BPM. Check that playback starts on a suitable ready song, cadence changes, and one song crosses naturally into a prepared better fit.

The build is suitable for product testing, not public distribution. Historical commit `cd07fd4` was built from clean `main`, signed with the then-renewed exact profile, and installed on 2026-07-27 without uninstalling the prior app. The selected collection survived byte-for-byte, foreground launch passed, and the physical process was confirmed. The later setup-craft commit `0a59b64` was also installed with the collection preserved, but its foreground launch remained open because the phone was locked. Physical click-wheel feel, audible Auto response, and a natural prepared transition remain open.

After a debug run finishes, pull `Library/Application Support/Samadhi/latest-run-diagnostics.json` directly from the app container. The file overwrites the prior run and contains progress, cadence, target and applied rates, track changes, recovery events, and the honest summary. Since schema 11 the buffer holds 2,048 entries and drops per-second ticks first, so every song change, rate write, mode change, cue, and notice from a run of any realistic length is still there; only the oldest ticks of a long run are gone.

~~~sh
xcrun devicectl device copy from \
  --device 74BE85BB-5455-56FE-BFA3-0150F3A28C43 \
  --domain-type appDataContainer \
  --domain-identifier com.samaydhawan.Samadhi \
  --source Library \
  --destination /tmp/samadhi-device-library
~~~

## Runbook: Completed Apple token repair

Automatic token generation and 10 of 10 preview decodes passed with exact App ID signing. Inspect the current exact profile before every later physical installation.

1. In Certificates, Identifiers & Profiles, confirm MusicKit remains enabled for the explicit App ID `com.samaydhawan.Samadhi`.
2. Create a new iOS App Development provisioning profile for that exact App ID, the current Apple Development certificate, and Samay's registered iPhone.
3. Download and open the profile so Xcode installs it.
4. In the Samadhi target's Signing & Capabilities screen, keep team `ZL5U59XBJ6` and bundle identifier `com.samaydhawan.Samadhi`. Select the exact profile manually for the gate build if automatic signing continues to choose a wildcard profile.
5. Build and inspect the gate app, then install it in place without deleting the existing app or its data.
6. Inspect the built app's embedded profile. Confirm its application identifier ends in `com.samaydhawan.Samadhi` and record the profile name and UUID.
7. Run one minimal catalog request in the `Samadhi MusicKit Gate` harness and export the JSON trace.
8. Confirm the request returns a real catalog response before continuing the physical source gate.

Do not create a Media Services key, embed a developer token, or add a token backend for this gate.

## Runbook: Deferred Apple Music reliability run

1. Connect and trust an authenticated iPhone, then confirm Developer Mode is enabled.
2. Confirm the phone appears in `xcrun devicectl list devices` as a physical device.
3. Set the Apple development team in `project.yml`, regenerate the project, and confirm signed installation succeeds.
4. In the Apple developer portal, enable the MusicKit App Service for `com.samaydhawan.Samadhi`.
5. Select the `Samadhi MusicKit Gate` scheme and the connected iPhone.
6. Attach one Bluetooth A2DP headphone route and open one library playlist with at least ten tracks.
7. Run authorization, playlist loading, preview tempo analysis, playback, the 0.90, 1.00, and 1.10 rate writes, pause, resume, next track, interruption, route loss, and five screen-locked minutes.
8. Share the harness JSON trace and save listening notes under `Evidence/Device/` with device, OS, route, playlist, result, and date.
9. Save the result as the selected Apple Music adapter's reliability evidence. The source decision is already closed.

A brief physical walk proved live cadence reaches the app. Full placement calibration remains open. Bluetooth routing and rate writes pass, but a dedicated Bluetooth listening note and the long-form recovery checks remain open. Simulator evidence must never be described as a real-run result.

## Runbook: Focused body-to-music check

The app build used by `Samadhi Apple Music Core Loop` is installed on Samay's iPhone. The focused scheme uses catalog fixture `1558215042`, estimated at 149.75 BPM, Core Motion cadence, and bounded automatic rate changes. Tapping the icon directly starts normal simulation because the focused configuration is selected by a launch argument.

1. Wake the phone, authenticate, and leave the screen on.
2. Launch `Samadhi Apple Music Core Loop` from Xcode, or launch the installed app through `devicectl` with `--apple-music-core-loop`.
3. Press Start, secure the phone in the declared right-front pocket placement, then walk or jog briefly.
4. Open `What Samadhi saw`. Confirm the raw step reading, accepted step reading, requested rate, and Apple Music reply are shown separately.
5. Listen for a natural speed response without clicks, gaps, pitch jump, or rapid hunting.
6. Capture the device screen programmatically before finishing, or persist the focused trace. Record target rate, applied rate, route, whether music speed responded, and any audible problem.

Live cadence passed during a 29-second walk with a 142 SPM average. Automatic rate response then passed during a corrected 59-second run with a 155 SPM average and 98 percent tempo matched from MusicKit read-back. A later August 15 trace exposed a regression: 14 of 16 numeric readings were about 2.57 seconds old and failed the fixed 2.0-second freshness check. The August 17 fingerprinted workout confirmed the repair on the phone. Four supported delayed readings acquired 133 SPM, and Apple Music reported the exact 1.0390625 command after 0.066 seconds. Old, repeated, backward, out-of-order, and unexplained-gap samples still fail in deterministic tests. This does not replace later calibration or the Milestone 2 completion run.

The August 17 fingerprinted Auto candidate was signed with exact profile `Samadhi Development 2026-08-15` and installed in place. The selected collection stayed byte-for-byte unchanged. Its later workout file matched source fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498` and proved repaired acquisition plus one Apple Music response. Haptics, locked-screen cue delivery, broader listening, and sustained running remain open.

## Runbook: Current apartment gate

This is the shortest useful physical check. It does not replace the later outdoor run.

The expanded-rate build is already installed with exact signing. Its expected source fingerprint is `fd8120ad2ac14e1090a687438e6564beb65bde0a61d58fab04d4ec7295535684`. The selected collection checksum was unchanged after installation.

1. Wake and authenticate the phone. Launch the installed candidate with `--apple-music-core-loop`, open `What Samadhi saw`, and confirm its source fingerprint matches the inspected signed build before starting.
2. Use headphones at a safe volume. Put the phone in the right-front pocket, press Start, and walk briskly and steadily for 30 seconds. The current candidate supports 90 through 210 steps per minute, but walking needs five seconds of steady evidence before Auto can settle.
3. Jog clearly faster for 20 seconds, then return to the original rhythm for 20 seconds. The filter needs three agreeing readings. Auto ignores movement inside four steps per minute and requires at least six steps per minute of sustained change for five seconds, with at least eight seconds between committed targets.
4. Stop moving. Open the wheel, choose Manual, and turn six to ten BPM. Pause and resume; Manual should remain. Tap Skip; Manual should remain until the player confirms a different song, then return to Auto.
5. Open the wheel and use its close action. Playback controls should return without changing playback or rhythm ownership. Finish the run so the diagnostic file is complete.
6. In the Debug MusicKit gate, compare 0.90 with 0.85, then 1.10 with 1.15 on the same song. Hold each rate long enough to hear a verse or chorus. Record Apple Music read-back plus any clicks, gaps, rough transients, unstable pitch, smeared drums, hollow vocals, or obvious loss of energy.
7. Record whether `Tempo matched` appeared, whether the music moved in the expected direction, whether Auto felt stable or hunted, whether Manual reset after the confirmed song change, and whether playback produced weak physical feedback.
8. Pull `latest-run-diagnostics.json` immediately. Confirm accepted cadence, settled Auto target, requested rate, Apple Music read-back, reply time, remaining difference, result state, song identity, and source fingerprint before making a product claim.
