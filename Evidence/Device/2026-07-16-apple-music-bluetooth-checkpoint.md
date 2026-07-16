# Apple Music Bluetooth checkpoint

Date: 2026-07-16

## Environment

- Device: iPhone 17 Pro
- OS: iOS 27.0
- Route: `BluetoothA2DPOutput:Beoplay Eleven`
- Bundle identifier: `com.samaydhawan.Samadhi`
- Profile: `Samadhi Development`
- Profile UUID: `f7dc2163-4562-4849-90ba-1f49d14ce03a`
- Source trace: user export `samadhi-apple-music-feasibility 2.json`
- Source trace SHA-256: `bfcafc8e007697a039b67deac56ec19b07b39b925df2c0eab7155b031460275c`

## What the trace proves

- The route changed from the built-in speaker to Beoplay Eleven over Bluetooth A2DP.
- `ApplicationMusicPlayer` played `Black Classical Music` and `LITE SPOTS`.
- Live writes reported 0.94, 1.00, and 1.06 while the Bluetooth route was active.
- The City Pocket and Apartment collections each produced 10 of 10 decoded previews in this run.

## What it does not prove

- No dedicated Bluetooth listening note was recorded.
- Playback did not remain locked in the background for five minutes.
- Next track, controlled interruption, headphone loss, reconnection, and explicit resume were not completed.
- Interruption notifications at playback startup came from the harness activating its own audio session. They are not counted as controlled interruption evidence.

## Decision

Samay explicitly deferred further repetitive manual drills so implementation could continue. Apple Music is selected as the one production source because the token, catalog identity, tempo-source coverage, real playback, speaker listening, Bluetooth routing, and live rate feasibility risks are resolved. The unproven items remain mandatory reliability checks before Milestone 2 completion.
