# Imported collection test build

Date: 2026-07-16

Device: Samay's iPhone 17 Pro

OS: iOS 27.0

Bundle: `com.samaydhawan.Samadhi`

Version: 1.0 (1)

Minimum OS: iOS 26.0

Signing profile: `Samadhi Development`

Profile UUID: `f7dc2163-4562-4849-90ba-1f49d14ce03a`

Application identifier: `ZL5U59XBJ6.com.samaydhawan.Samadhi`

Profile expiry: 2026-07-23 03:54:43 UTC

Embedded profile SHA-256: `e110511fcc1633fd3a5ea4c76597ee392839da86f3426591d2f36f016692b99c`

## Result

The exact-profile physical build succeeded. The normal app installed and launched through `devicectl`.

This proves build, signing, installation, and launch. It does not prove a real playlist import. The remaining device gate is one moderate playlist with at least three ready tracks, relaunch restoration, and playback through a real track transition.

## Reviewed Simulator states

- Empty import state: `Evidence/Simulator/2026-07-16-import-empty.png`
- Partial import state: `Evidence/Simulator/2026-07-16-import-partial.png`
- Empty SHA-256: `b76f602210dadd503934249644b42b8207a686558f3e0ce361e2cf599ab7c7d2`
- Partial SHA-256: `b62045c3cbbe7a37faa1382754b7c41d3b353869f67498be8f30511329dd3e92`
