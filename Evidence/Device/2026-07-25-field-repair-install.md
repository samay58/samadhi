# Field repair installation

Date: 2026-07-25

Device:

- Samay's iPhone
- iPhone 17 Pro
- iOS 27.0, build `24A5390f`
- Device identifier `74BE85BB-5455-56FE-BFA3-0150F3A28C43`
- Paired over the local network with Developer Mode enabled

Source:

- Branch `main`
- Commit `42f4dd566965fa1204990d8ec248fa56335da518`
- Clean detached worktree

Verification:

- Swift formatter lint passed
- 116 Swift package tests passed
- Resource-inclusive Simulator build passed
- 16 app-model tests passed
- 10 serial UI tests passed
- Focused wheel test reached the current song's actual boundary, rejected more outward travel, reversed immediately, retained the current track, and never presented `Changing song`

Signing:

- Profile `Samadhi Development`
- Profile UUID `982e709d-7aa8-4d79-aca3-7759c8f70fc5`
- Expiration `2026-07-30T15:42:26Z`
- Application identifier `ZL5U59XBJ6.com.samaydhawan.Samadhi`
- Bundle identifier `com.samaydhawan.Samadhi`
- Signature verification passed
- Debug dylib checksum `0716c44d6016d7d0f3943482cb55afca8445c809bfbac2b5ff4ea5bf0ba6e1a9`

Install:

- Installation succeeded without uninstalling the existing app.
- Selected-collection checksum before install: `95689c549088e4d073d7dfa1ddf356c9018725013c725033dc364d40493e5af3`
- Selected-collection checksum after install: `95689c549088e4d073d7dfa1ddf356c9018725013c725033dc364d40493e5af3`
- Foreground launch was attempted but not claimed because the phone was locked.

The shortest remaining check is one song on the unlocked phone. Confirm source-order startup, reach and leave both Manual boundaries, return to Auto while changing cadence, and judge audible response and wheel feel. Pull the rolling diagnostics immediately afterward, even if the run is not finished.
