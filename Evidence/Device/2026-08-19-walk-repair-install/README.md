# Phone install of the walk repair build

Installed on 2026-08-19 from clean `main` at commit `0aa99a70d068485295a630dd3659768704b96e5d`, after the full software gate passed (193 package tests, 48 app-model tests, 34 serial interface tests, formatter lint, source-fingerprint tests). This record covers the build, the signature, and the install. The phone was locked, so there is no in-app read-back for this build yet, and it makes no claim about feel, sound, ducking, lock screen, route recovery, or anything else physical.

## Signed build

| Item | Value |
| --- | --- |
| Scheme and configuration | `Samadhi`, Debug, physical iOS destination |
| Profile | `Samadhi Development 2026-08-15`, UUID `1b613344-c5cd-4802-a31f-9ff5088c1802`, expires 2027-08-15 |
| Application identifier | `ZL5U59XBJ6.com.samaydhawan.Samadhi` in both the embedded profile and the signature entitlements |
| Strict signature verification | Passed, valid on disk and satisfies its Designated Requirement |
| Built Info.plist commit | `0aa99a70d068485295a630dd3659768704b96e5d`, branch `main`, tracked files clean |
| Built Info.plist source fingerprint | `a05aaa3cc77a0df2e86f88754f38b03312226375c408940c881df79e0a3e709a` |
| `Scripts/source-fingerprint.sh` on the same checkout | Same value |
| Build date recorded in the app | 2026-08-19T19:52:27Z |
| App version | 1.0 (1) |

## Install

| Item | Value |
| --- | --- |
| Device | iPhone 17 Pro, `iPhone18,1`, iOS 27.0, paired and available over the local network |
| Installed app before | Samadhi 1.0 (1), the analyzer version 5 build `294981e` |
| Method | `devicectl device install app` over the existing app, nothing uninstalled, no app data touched |
| Installed app after | Samadhi 1.0 (1), listed by `devicectl device info apps` |
| Selected collection SHA-256 before | `a51a8e4ab361a1c7c47669aeb02777276eee89600367a1e9efafed03a80f64bf` |
| Selected collection SHA-256 after | `a51a8e4ab361a1c7c47669aeb02777276eee89600367a1e9efafed03a80f64bf`, byte-identical |
| Phone state | Locked; `devicectl device process launch` returned `Locked` (FBSOpenApplicationErrorDomain 7), so no Debug screen read-back |

The collection checksum differs from the `4866a2e5...` recorded at the analyzer version 5 install because the app was used for the Easy Miles walk in between and rewrote the file in normal use. The install did not change it.

## What this build carries

Diagnostic schema 11: a 2,048-entry record that drops per-second ticks first; an `autoFeedbackDelivery` entry for every cue the service handles and a `hapticEngine` entry for every engine event; the boundary look-ahead, with `nextSongPlanned` entries and a `nextSongOutlook` field on every entry; and the one reach line, with a `reachNoticed` entry when it is allowed.

## Still open

The walk itself. Walk Easy Miles again for at least ten minutes with the phone in the pocket and the screen locked part of the time, then pull `latest-run-diagnostics.json` and parse it. Everything in `Docs/PHONE-CHECK-2026-08-19.md` remains open as well.
