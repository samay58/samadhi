# Device runbook

## Current capability

Apple team `ZL5U59XBJ6` is saved in `project.yml`. Signed compilation, installation, and launch pass with an Apple Development certificate. Samay's iPhone 17 Pro is connected on iOS 27.0 with Developer Mode enabled. The explicit App ID exists and the MusicKit App Service is user-confirmed as enabled.

## Completed Apple token repair

The exact `Samadhi Development` profile is installed. Automatic token generation and 10 of 10 preview decodes pass. The steps below are retained for profile renewal because the current offline profile expires on 2026-07-23 UTC.

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
7. Run authorization, playlist loading, decoded preview coverage, playback, the 0.94, 1.00, and 1.06 rate writes, pause, resume, next track, interruption, route loss, and five screen-locked minutes.
8. Share the harness JSON trace and save listening notes under `Evidence/Device/` with device, OS, route, playlist, result, and date.
9. Save the result as the selected Apple Music adapter's reliability evidence. The source decision is already closed.

Physical cadence remains unproven. Bluetooth routing and rate writes pass, but a dedicated Bluetooth listening note and the long-form recovery checks remain open. Simulator evidence must never be described as a real-run result.
