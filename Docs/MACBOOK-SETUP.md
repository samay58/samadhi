# MacBook continuation setup

This is the local continuation guide for Samadhi on Samay's MacBook. The repository is the source of code and durable evidence. The Mac Mini is no longer needed for ordinary development or Simulator validation. The remaining MacBook gap is physical iPhone availability and pairing.

## Current MacBook audit

Checked 2026-08-14.

| Surface | State | What it means |
| --- | --- | --- |
| Checkout | `/Users/samaydhawan/Projects/active/samadhi` on `main` at `4f5394f` | Canonical local working copy |
| Convenience path | `/Users/samaydhawan/samadhi` | Symlink to the canonical checkout |
| Machine | M4 MacBook Air, 24 GB memory | Enough for this app's compile, test, and one-Simulator workflow |
| Free storage | 36 GiB | Enough for the active project and one current runtime; avoid adding more platforms or runtimes |
| Xcode | Xcode 27.0, build `27A5209h`, at `/Applications/Xcode-beta.app` | Correct toolchain for the iOS 27 device evidence in this repository |
| XcodeGen | 2.45.4 | Installed |
| Active developer directory | Command Line Tools | Raw Xcode commands need the local `DEVELOPER_DIR` command below |
| iOS Simulator runtime | One iOS 27 runtime with one iPhone 17 Pro simulator | Full Simulator gate passed on this device |
| Physical iPhone | Known to CoreDevice but currently unavailable | Reconnect and pair from this MacBook before device work |
| Signing | Apple Development identity present | Physical signing is ready once an available paired iPhone returns |

The historical device records in `Evidence/Device/` prove prior behavior on the iPhone. They do not transfer signing authority, pairing, local app data, or current device availability to this MacBook. In particular, the profile named in the July records expired on 2026-07-30.

## What to install or connect

Use the Xcode beta already installed. Do not install a second Xcode copy, copy a certificate or private key from the Mac Mini, or migrate Simulator devices and caches.

1. The single iOS 27 runtime and iPhone 17 Pro Simulator are installed. Do not add older runtimes unless a compatibility decision changes the product target.
2. An Apple Development identity is present for the needed account. Before physical-device work, confirm it remains available with the command below.
3. Connect Samay's iPhone by cable once, accept trust prompts, enable Developer Mode if needed, then enable Connect via network in Xcode's Devices and Simulators window. Wireless pairing is per Mac and must be established again here.
4. In the Samadhi target, retain Automatic Signing with the exact bundle identifier `com.samaydhawan.Samadhi`. MusicKit requires the explicit application identifier. A wildcard profile is not sufficient. Verify the embedded application identifier before every physical install as required by `DEVICE_RUNBOOK.md`.
5. Confirm the phone has an active Apple Music account before an Apple Music or listening check. The normal Debug Simulator flow uses local placeholder music and does not require it.

For terminal work, keep the developer directory local to the command rather than changing the machine-wide selection:

~~~sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
cd /Users/samaydhawan/samadhi
./Scripts/bootstrap.sh
./Scripts/test.sh
~~~

`Scripts/test.sh` already prefers this beta when `DEVELOPER_DIR` is not set. The explicit export keeps direct `xcodebuild`, `xcrun`, and formatter calls on the same toolchain.

## Space and performance discipline

Samadhi does not need Mac Mini-class compute. Its production app has no third-party dependency, no backend, and no model runtime. The M4 Air and 24 GB memory are sufficient for one Xcode build, serial tests, and one Simulator. Physical audio, cadence, haptic, and MusicKit validation depend on the iPhone, not a more powerful Mac.

Keep the machine lean:

- Keep only the single current iOS 27 Simulator runtime needed for the iPhone 17 Pro test destination.
- Use the existing Xcode beta. It is 3.6 GB on this MacBook; the one current Simulator runtime and device data use about 5 GB. Do not add another platform or runtime while free space is 36 GiB.
- Keep Samadhi as one Git checkout. Do not copy the Mac Mini's Derived Data, Simulator contents, device support files, app container, Apple Music data, provisioning profiles, or certificates. Those are machine-specific and copying them is unreliable or unsafe.
- Let `xcodebuild` reuse its normal Derived Data while actively working. If space later becomes tight, inspect Samadhi-specific Derived Data first and remove only that identified build output after confirming no active build is using it. Do not wipe global Xcode or Simulator directories as routine maintenance.
- Keep evidence in Git. Capture new Simulator frames or device receipts only when they prove a milestone, then prune redundant local exports before committing.

## Verification ladder

| Level | Command or action | What it proves |
| --- | --- | --- |
| Project generation | `./Scripts/bootstrap.sh` | The versioned XcodeGen input reproduces `Samadhi.xcodeproj` |
| Domain tests | `swift test --package-path Packages/SamadhiKit` | Core audio, motion, design, and reducer behavior compiles and passes without a Simulator |
| Full software gate | `./Scripts/test.sh` | Package, app-model, and UI tests on the current iPhone 17 Pro Simulator destination |
| Signing readiness | `security find-identity -v -p codesigning` | This MacBook has a usable local signing identity |
| Device installation | `Docs/DEVICE_RUNBOOK.md` | Exact-app-ID signing, installation, and launch on the paired iPhone |
| Product quality | One short physical run, then the remaining Milestone 2 reliability checks | Cadence, audible rate change, wheel feel, natural transition, background playback, interruption, and route recovery |

The first useful session on this MacBook is now a physical-device session: reconnect and pair the iPhone, verify exact-app-ID signing, then take one focused product check from `PLAN.md`. The local software gate passed on 2026-08-13 with 118 Swift package tests and 46 iPhone 17 Pro Simulator tests.

## Boundaries

- The July device notes are historical evidence, not a request to overwrite the phone or recreate its old app state.
- Do not use the old documented profile expiration as proof that a renewed profile is unavailable. Inspect the profile embedded in the build that will actually be installed.
- Do not treat a Simulator pass as proof of MusicKit, cadence, listening quality, haptics, or background behavior.
- Do not claim a physical install until the exact signed build, application identifier, device availability, install result, and launch state have been read back.
