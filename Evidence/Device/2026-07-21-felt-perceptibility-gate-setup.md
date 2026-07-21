# Felt perceptibility gate setup

Date: 2026-07-21

Result: One-track obvious-change check passed. The full blinded and full-song quality protocol remains incomplete.

## Verified setup

- Repository commit: `2d50f86be1f71d0bf41024590efc7640840d3279`
- Device: Samay's iPhone 17 Pro (`iPhone18,1`)
- Device identifier: `74BE85BB-5455-56FE-BFA3-0150F3A28C43`
- iOS: 27.0 (`24A5380h`)
- Connection: paired and connected over the local network
- Developer Mode: enabled
- Xcode: 27.0 (`27A5218g`)
- iOS SDK: 27.0
- Bundle identifier: `com.samaydhawan.Samadhi`
- Team: `ZL5U59XBJ6`
- Embedded profile: `Samadhi Development`
- Application identifier: `ZL5U59XBJ6.com.samaydhawan.Samadhi`
- Profile expiration: 2026-07-22 23:54:43 EST
- Scheme: `Samadhi MusicKit Gate`
- Launch argument: `--music-feasibility`
- Output route shown by the live harness: `BluetoothA2DPOutput:Beoplay Eleven`
- Built executable SHA-256: `bacdae1b8d23e081215f6e4353f77a96452ae6c578016d2fe6bacfd57f2b7f04`
- Setup screenshot SHA-256: `3bec3b72c3ecd9dbbb8f0e9680901864b11308091966c582e9352eb92cbeac49`

The first automatic-signing build selected the wildcard team profile. It was not installed. The installed build was rebuilt with manual signing and the exact `Samadhi Development` profile, then verified from its embedded profile before installation.

## Listening result

- Track: `LITE SPOTS`
- Route: Beoplay Eleven over Bluetooth A2DP
- Requested and reported endpoints: 0.90 and 1.10
- Trace behavior: repeated rate writes were followed by matching MusicKit player-state read-back while playback continued
- Samay's listening note: the 0.90 and 1.10 difference was clearly audible, and he was approximately 95 percent confident the mechanic was working
- Canonical exported trace: `2026-07-21-apple-music-perceptibility-trace.json`
- Exported trace SHA-256: `984de093313fc895598fbd9c2774e1b625d8de46bf046d28e6275803ee26a7b9`

This passes the product's one-track obvious-change question and is enough to continue with Apple Music as the authoritative player. It does not satisfy the planned four-of-five blinded result or full-song endpoint-quality check. The normal-run quality envelope therefore remains 0.94 through 1.06 until broader listening proves otherwise.
