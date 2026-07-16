# Device runbook

## Current capability

A local self-signed code-signing identity is installed, but no Apple development team is configured. No physical iPhone is connected. Unsigned generic iPhone compilation passes; signed compilation stops at the missing team.

## Apple Music feasibility run

1. Connect and trust an unlocked iPhone, then confirm Developer Mode is enabled.
2. Confirm the phone appears in `xcrun devicectl list devices` as a physical device.
3. Set the Apple development team in `project.yml`, regenerate the project, and confirm signed installation succeeds.
4. In the Apple developer portal, enable the MusicKit App Service for `com.samaydhawan.Samadhi`.
5. Select the `Samadhi MusicKit Gate` scheme and the connected iPhone.
6. Attach one Bluetooth A2DP headphone route and open one library playlist with at least ten tracks.
7. Run authorization, playlist loading, decoded preview coverage, playback, the 0.94, 1.00, and 1.06 rate writes, pause, resume, next track, interruption, route loss, and five screen-locked minutes.
8. Share the harness JSON trace and save listening notes under `Evidence/Device/` with device, OS, route, playlist, result, and date.
9. Make the source decision. Keep MusicKit only if every load-bearing item passes; otherwise remove the spike and select local file import with AVAudioEngine.

Physical cadence and audio quality remain unproven. Simulator evidence must never be described as a real-run result.
