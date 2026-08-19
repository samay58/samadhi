# Device runbook

## Historical device capability

Apple team `ZL5U59XBJ6` is saved in `project.yml`. Historical Mac Mini evidence shows that signed compilation and installation passed with an Apple Development certificate. Samay's iPhone 17 Pro runs iOS 27.0 with Developer Mode enabled. The explicit App ID exists and the MusicKit App Service is user-confirmed as enabled. On 2026-07-21 the exact-profile harness ran over Beoplay Eleven and made 0.90 versus 1.10 clearly audible on one track. The normal app now contains compatible-song start selection, prepared next-song fit, and the aperture click wheel.

Automatic signing can select a wildcard profile even when an exact profile exists. For MusicKit work, inspect the embedded profile before installation and require an unexpired profile with application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`. The current profile is `Samadhi Development 2026-08-15`, UUID `1b613344-c5cd-4802-a31f-9ff5088c1802`, expiring 2027-08-15. The July profile is historical only. See [MACBOOK-SETUP.md](MACBOOK-SETUP.md) before attempting this flow on the MacBook.

## Denver test build

1. Open Samadhi and tap `Choose music`. The 2026-07-22 device restore cleared the prior local selection.
2. Select one Apple Music playlist. The earlier `Strut Frequency -- July 2026` proof produced 13 ready tracks from 25 before the restore.
3. Read the result honestly. Ready tracks can run; unreadable or unavailable tracks remain visible but do not enter playback.
4. Confirm the restored collection still reports ready tracks, tap `Start`, and allow motion access if asked.
5. Close and reopen Samadhi. Confirm the same playlist returns without another choice.
6. During a short run, turn the aperture perimeter to adjust BPM. Check that playback starts on a suitable ready song, cadence changes, and one song crosses naturally into a prepared better fit.

The build is suitable for product testing, not public distribution. Historical commit `cd07fd4` was built from clean `main`, signed with the then-renewed exact profile, and installed on 2026-07-27 without uninstalling the prior app. The selected collection survived byte-for-byte, foreground launch passed, and the physical process was confirmed. The later setup-craft commit `0a59b64` was also installed with the collection preserved, but its foreground launch remained open because the phone was locked. Physical click-wheel feel, audible Auto response, and a natural prepared transition remain open.

After a debug run finishes, pull `Library/Application Support/Samadhi/latest-run-diagnostics.json` directly from the app container. The file overwrites the prior run and contains progress, cadence, target and applied rates, track changes, recovery events, and the honest summary.

~~~sh
xcrun devicectl device copy from \
  --device 74BE85BB-5455-56FE-BFA3-0150F3A28C43 \
  --domain-type appDataContainer \
  --domain-identifier com.samaydhawan.Samadhi \
  --source Library \
  --destination /tmp/samadhi-device-library
~~~

## Completed Apple token repair

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

## Deferred Apple Music reliability run

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

## Focused body-to-music check

The app build used by `Samadhi Apple Music Core Loop` is installed on Samay's iPhone. The focused scheme uses catalog fixture `1558215042`, estimated at 149.75 BPM, Core Motion cadence, and bounded automatic rate changes. Tapping the icon directly starts normal simulation because the focused configuration is selected by a launch argument.

1. Wake the phone, authenticate, and leave the screen on.
2. Launch `Samadhi Apple Music Core Loop` from Xcode, or launch the installed app through `devicectl` with `--apple-music-core-loop`.
3. Press Start, secure the phone in the declared right-front pocket placement, then walk or jog briefly.
4. Open `What Samadhi saw`. Confirm the raw step reading, accepted step reading, requested rate, and Apple Music reply are shown separately.
5. Listen for a natural speed response without clicks, gaps, pitch jump, or rapid hunting.
6. Capture the device screen programmatically before finishing, or persist the focused trace. Record target rate, applied rate, route, whether music speed responded, and any audible problem.

Live cadence passed during a 29-second walk with a 142 SPM average. Automatic rate response then passed during a corrected 59-second run with a 155 SPM average and 98 percent tempo matched from MusicKit read-back. A later August 15 trace exposed a regression: 14 of 16 numeric readings were about 2.57 seconds old and failed the fixed 2.0-second freshness check. The August 17 fingerprinted workout confirmed the repair on the phone. Four supported delayed readings acquired 133 SPM, and Apple Music reported the exact 1.0390625 command after 0.066 seconds. Old, repeated, backward, out-of-order, and unexplained-gap samples still fail in deterministic tests. This does not replace later calibration or the Milestone 2 completion run.

The August 17 fingerprinted Auto candidate was signed with exact profile `Samadhi Development 2026-08-15` and installed in place. The selected collection stayed byte-for-byte unchanged. Its later workout file matched source fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498` and proved repaired acquisition plus one Apple Music response. Haptics, locked-screen cue delivery, broader listening, and sustained running remain open.

## Current apartment gate

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

## Feedback audition

The Auto feedback prototypes are played by hand from a Debug-only screen. It ships in Debug builds and is absent from Release.

1. Select the `Samadhi Feedback Audition` scheme in Xcode and run it on the paired iPhone. The scheme passes `--feedback-audition`, so the app opens straight into the audition screen.
2. Start a real song in the Music app first and leave it playing in the background. Ducking, gaps, and route changes only show up against real Apple Music.
3. Use headphones at a safe volume, and put the phone in the normal pocket position for anything about tactile recognition.
4. Pick a family, a direction, a size, and a sound path, then play the start, the arrival, or both. The sound and haptic toggles work independently so either half can be judged alone.
5. For a blinded run, write down the seed shown on screen and start the 10 trials. The screen picks the direction, plays the cue, takes the answer, and reports the score out of 10. Copy the summary line, which carries family, sound path, seed, and score.
6. Repeat the set for the other sound path before comparing families. Record the score, the seed, and any ducking, pause, gap, or route change in `Evidence/Device/`.

Nothing in the prototype set becomes a product asset before this comparison. The acceptance bar lives in [AUTO-CHANGE-INTERACTION-SPEC.md](AUTO-CHANGE-INTERACTION-SPEC.md).

## Automated tempo corpus

The real-preview accuracy check does not need device interaction. Run the opt-in `TempoCorpusValidator` from the package and provide an output path under `Evidence/Device/`. It verifies fixed Apple catalog metadata, downloads each preview into temporary storage, analyzes it, deletes it, and fails below 10 of 12 exact musical-pulse results. Supported stride relationships are reported separately. Normal automated tests do not use the network.

~~~sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  swift run --package-path Packages/SamadhiKit TempoCorpusValidator \
  --output Evidence/Device/YYYY-MM-DD-tempo-corpus-validation.json
~~~
