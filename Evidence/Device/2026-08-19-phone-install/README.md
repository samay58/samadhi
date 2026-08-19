# Phone install of the transport, cause, and Auto feedback candidate

Installed on 2026-08-19 from clean `main` at commit `67adf80f4f9c31ec7a853dd3645cc0f2feebcc4c`. This record covers the build, the signature, the install, and one in-app read-back. It makes no claim about feel, sound, ducking, lock screen, route recovery, or anything else on the checklist in `Docs/PHONE-CHECK-2026-08-19.md`.

## Signed build

| Item | Value |
| --- | --- |
| Scheme and configuration | `Samadhi`, Debug, physical iOS destination |
| Profile | `Samadhi Development 2026-08-15`, UUID `1b613344-c5cd-4802-a31f-9ff5088c1802`, expires 2027-08-15 |
| Application identifier | `ZL5U59XBJ6.com.samaydhawan.Samadhi` in both the embedded profile and the signature entitlements |
| Signing authority | Apple Development: Samay Dhawan (2UQFX5QB82), team `ZL5U59XBJ6` |
| Strict signature verification | Passed, valid on disk and satisfies its Designated Requirement |
| Built Info.plist commit | `67adf80f4f9c31ec7a853dd3645cc0f2feebcc4c`, branch `main`, tracked files clean |
| Built Info.plist source fingerprint | `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6` |
| `Scripts/source-fingerprint.sh` on the same checkout | Same value |
| Build date recorded in the app | 2026-08-19T14:23:30Z |
| App version | 1.0 (1) |

The `Samadhi Feedback Audition` scheme exists in the generated project and builds for the same phone destination with the same profile. It is the same bundle with the `--feedback-audition` launch argument, and its built Info.plist carries the same fingerprint. It was not installed as a second app.

## Install

| Item | Value |
| --- | --- |
| Device | iPhone 17 Pro, `iPhone18,1`, iOS 27.0 build `24A5408d`, Developer Mode enabled, reached over the local network |
| Installed app before | Samadhi 1.0 (1), the August 17 expanded-rate build |
| Method | `devicectl device install app` over the existing app, nothing uninstalled, no app data touched |
| Installed app after | Samadhi 1.0 (1) |
| Selected collection SHA-256 before | `51b4096cc3b2c29ae32d85290b5a9f72166460f23b130d818508f7507b4e8397` |
| Selected collection SHA-256 after | `51b4096cc3b2c29ae32d85290b5a9f72166460f23b130d818508f7507b4e8397`, byte-identical |

The before checksum differs from the `81a9b31f...` value recorded at the August 17 install. The file on the phone was last written on August 18, after that install, so the app itself rewrote it during normal use. The install did not change it.

## Launch and in-app read-back

The phone was unlocked. The app was launched once normally, then once with `--core-diagnostics` so the hidden Debug screen opened directly, and a screenshot was taken with `devicectl device capture screenshot`. That screenshot is `debug-screen.png` in this folder. It shows code version `67adf80...`, branch `main, clean`, built `2026-08-19T14:23:30Z`, source fingerprint `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6`, app 1.0 (1), tempo analyzer version 4, diagnostic file version 10, device `iPhone18,1`, system 27.0 (24A5408d), real Apple Music, and real phone motion. The in-app fingerprint equals the built Info.plist fingerprint. The app was then relaunched normally and left on its ordinary screen.

## Still open

Everything in `Docs/PHONE-CHECK-2026-08-19.md`: endpoint listening and read-back at 0.85 and 1.15, transport and Finish feel, the blinded faster and slower trials on both sound paths, the recorded cause after a natural end and after an explicit Next, and lock, interruption, and route recovery. No run was started and no diagnostics file was pulled for this build.

## Second install the same day, commit 13e88bf

The glass transport circles and the catalog tie fix were built and installed in place later on 2026-08-19 with the same profile and procedure.

| Item | Value |
| --- | --- |
| Commit | `13e88bff4b5d0604715de7000d3671e668725a5b`, `main`, clean |
| Profile and identifier | `Samadhi Development 2026-08-15`, UUID `1b613344-c5cd-4802-a31f-9ff5088c1802`, `ZL5U59XBJ6.com.samaydhawan.Samadhi` in the embedded profile and the signature; strict verification passed |
| Built Info.plist source fingerprint | `085e5fe7b0e080a19efe281bd69fa5ebaeab00e0d082bc64701cd03d98de4f82`, equal to `Scripts/source-fingerprint.sh` on the same checkout |
| Build date recorded in the app | 2026-08-19T15:18:28Z |
| Install | In place over the morning build, nothing uninstalled, no app data touched |
| Selected collection SHA-256 before and after | `524c641b7f304758aafdc4ec8502d2a347b05dac3d18ae69b1650e65b5f24aee`, byte-identical |
| Phone state | Locked at the first install attempt; unlocked shortly after, so the app was reinstalled, launched with `--core-diagnostics`, and its hidden Debug screen read `13e88bf`, `main, clean`, built `2026-08-19T15:18:28Z`, source fingerprint `085e5fe7b0e080a19efe281bd69fa5ebaeab00e0d082bc64701cd03d98de4f82`, equal to the built Info.plist. The app was then relaunched normally |

The selected collection on the phone had changed again between the two installs because the app was used in between; at this install it held 25 songs with 13 not ready, 11 of them `catalogMatchUnavailable` and 2 `rhythmUnclear`. That is the population the tie fix targets. The playlist must be chosen again in the app for the 11 to resolve; nothing on the phone was changed to force that.

