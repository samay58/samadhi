# Exact BPM and fresh Auto repair installation

## Environment

- Date: 2026-07-22 America/New_York
- Device: Samay's iPhone 17 Pro
- OS: iOS 27.0
- Device identifier: `74BE85BB-5455-56FE-BFA3-0150F3A28C43`
- Bundle identifier: `com.samaydhawan.Samadhi`
- Profile: `Samadhi Development`
- Profile UUID: `f7dc2163-4562-4849-90ba-1f49d14ce03a`
- Application identifier: `ZL5U59XBJ6.com.samaydhawan.Samadhi`
- Profile expiration: 2026-07-23 03:54:43 UTC

## Artifact

| File | SHA-256 |
| --- | --- |
| `Samadhi.app/Samadhi.debug.dylib` | `0d53770a939e60ab98fc0bff590af24bf5c00a794e9f4c15cd4c46418f6adcf5` |
| `Samadhi.app/embedded.mobileprovision` | `e110511fcc1633fd3a5ea4c76597ee392839da86f3426591d2f36f016692b99c` |

## Result

The final signed physical build succeeded after formatter lint, 97 package tests, 15 app-model tests, and 10 UI tests passed. The embedded profile and application identifier matched the exact Samadhi App ID. `devicectl` installed bundle `com.samaydhawan.Samadhi` over the existing app while preserving its container. Foreground launch was denied because the phone was locked, so launch is not claimed.

This build contains the exact BPM contract repair: a finished wheel gesture commits one absolute Manual BPM, Manual applies the compatible rate immediately, Auto rejects stale cadence and reacquires after invalid samples, and version-3 tempo analysis no longer treats half-time or double-time as the displayed running pulse. The wheel also stays visible while a finger is turning it instead of allowing the control timeout to interrupt the gesture.

## Boundary

This proves build, signing, and installation. It does not prove audible Manual response, fresh Auto cadence, physical haptic feel, or playback continuity. One short physical run remains: allow the saved playlist to reanalyze once, commit a clearly different wheel BPM, confirm the displayed target and `Music` read-back agree, return to Auto, and confirm current cadence causes an audible response within about five seconds.
