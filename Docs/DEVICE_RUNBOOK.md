# Device runbook

## Current capability

Apple team `ZL5U59XBJ6` is saved in `project.yml`. Signed compilation and installation pass with an Apple Development certificate. Samay's iPhone 17 Pro runs iOS 27.0 with Developer Mode enabled. The explicit App ID exists and the MusicKit App Service is user-confirmed as enabled. On 2026-07-21 the exact-profile harness ran over Beoplay Eleven and made 0.90 versus 1.10 clearly audible on one track. The normal app now contains compatible-song start selection, prepared next-song fit, and the aperture click wheel.

Automatic signing can select a wildcard profile even when an exact profile exists. For MusicKit work, inspect the embedded profile before installation and require an unexpired profile with application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`. The prior `Samadhi Development` profile expired on 2026-07-23 UTC and must be renewed before the next install.

## Denver test build

1. Open Samadhi and tap `Choose music`. The 2026-07-22 device restore cleared the prior local selection.
2. Select one Apple Music playlist. The earlier `Strut Frequency -- July 2026` proof produced 13 ready tracks from 25 before the restore.
3. Read the result honestly. Ready tracks can run; unreadable or unavailable tracks remain visible but do not enter playback.
4. Confirm the restored collection still reports ready tracks, tap `Start`, and allow motion access if asked.
5. Close and reopen Samadhi. Confirm the same playlist returns without another choice.
6. During a short run, turn the aperture perimeter to adjust BPM. Check that playback starts on a suitable ready song, cadence changes, and one song crosses naturally into a prepared better fit.

The build is suitable for product testing, not public distribution. The prior offline profile expired on 2026-07-23 UTC. Physical selection, analysis, reinstall and relaunch restoration, basic player progress, Bluetooth routing, and one-track perceptibility passed before the device restore. Commit `c8e195e` was installed and launched wirelessly on the restored iPhone on 2026-07-22. The normal setup screen rendered cleanly, but playlist reimport, physical click-wheel feel, and a natural prepared transition remain open.

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

Automatic token generation and 10 of 10 preview decodes pass with exact App ID signing. The prior `Samadhi Development` profile is expired. Complete the renewal steps below before another physical installation.

1. In Certificates, Identifiers & Profiles, confirm MusicKit remains enabled for the explicit App ID `com.samaydhawan.Samadhi`.
2. Create a new iOS App Development provisioning profile for that exact App ID, the current Apple Development certificate, and Samay's registered iPhone.
3. Download and open the profile so Xcode installs it.
4. In the Samadhi target's Signing & Capabilities screen, keep team `ZL5U59XBJ6` and bundle identifier `com.samaydhawan.Samadhi`. Select the exact profile manually for the gate build if automatic signing continues to choose a wildcard profile.
5. Clean the build folder, delete the gate app from the phone, build, and install again.
6. Inspect the built app's embedded profile. Confirm its application identifier ends in `com.samaydhawan.Samadhi` and record the profile name and UUID.
7. Run one minimal catalog request in the `Samadhi MusicKit Gate` harness and export the JSON trace.
8. Confirm the request returns a real catalog response before continuing the physical source gate.

Do not create a Media Services key, embed a developer token, or add a token backend for this gate.

## Deferred Apple Music reliability run

1. Connect and trust an unlocked iPhone, then confirm Developer Mode is enabled.
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

1. Unlock the phone and leave it awake.
2. Launch `Samadhi Apple Music Core Loop` from Xcode, or launch the installed app through `devicectl` with `--apple-music-core-loop`.
3. Press Start, secure the phone in the declared right-front pocket placement, then walk or jog briefly.
4. In the temporary `Core loop` panel, confirm target rate appears and applied rate follows it. `feedback pending` should settle after MusicKit is read back.
5. Listen for a natural speed response without clicks, gaps, pitch jump, or rapid hunting.
6. Capture the device screen programmatically before finishing, or persist the focused trace. Record target rate, applied rate, route, whether music speed responded, and any audible problem.

Live cadence passed during a 29-second walk with a 142 SPM average. Automatic rate response then passed during a corrected 59-second run with a 155 SPM average and 98 percent tempo matched from MusicKit read-back. The focused check does not replace later calibration or the Milestone 2 completion run.

## Automated tempo corpus

The real-preview accuracy check does not need device interaction. Run the opt-in `TempoCorpusValidator` from the package and provide an output path under `Evidence/Device/`. It verifies fixed Apple catalog metadata, downloads each preview into temporary storage, analyzes it, deletes it, and fails below 10 of 12 exact musical-pulse results. Supported stride relationships are reported separately. Normal automated tests do not use the network.

~~~sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  swift run --package-path Packages/SamadhiKit TempoCorpusValidator \
  --output Evidence/Device/YYYY-MM-DD-tempo-corpus-validation.json
~~~
