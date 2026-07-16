# Apple Music feasibility gate

Date: 2026-07-15

Status: Blocked before physical execution. No source decision was made.

## Environment

| Item | Observed |
| --- | --- |
| Xcode | 27.0, build 27A5218g |
| iOS SDK | 27.0 |
| Connected devices | iPhone 17 Pro Simulator only |
| Physical iPhone | Not connected |
| Development team | Blank in project settings |
| Signed generic iPhone build | Failed because Samadhi requires a development team |
| Unsigned generic iPhone build | Passed |
| MusicKit harness Simulator build | Passed |
| Background audio declaration | Present as `UIBackgroundModes: audio` |
| Music permission text | Present |
| Motion permission text | Present |

`xcrun devicectl list devices` returned only the simulated iPhone. The installed signing identity is a self-signed local identity named `Conn Dev Signing`; it does not identify an Apple development team. Apple documents MusicKit as an App Service enabled for the bundle identifier in the developer portal, not as a code-signature entitlement. That server-side state cannot be verified without the relevant developer account.

## Gate checklist

| Requirement | Result |
| --- | --- |
| Contextual authorization | Blocked on physical iPhone and account |
| Library playlist and ten tracks | Blocked on physical iPhone and account |
| Decodable PCM preview coverage of at least 80 percent | Blocked on real library data |
| Real playback | Blocked on physical iPhone and account |
| Rate writes at 0.94, 1.00, and 1.06 | Harness compiled; physical behavior not tested |
| Pitch stability and artifact check | Blocked on physical iPhone and headphone route |
| Five minutes with screen locked | Blocked on physical iPhone |
| Pause, resume, track change, interruption, and route loss | Harness observes them; physical behavior not tested |

## Safe progress completed

- Added the source-controlled `Samadhi MusicKit Gate` scheme.
- Added a debug-only MusicKit harness with contextual authorization, playlist selection, ten-track decoded PCM preview coverage, queue playback, rate writes, playback controls, route and interruption observation, and JSON evidence export.
- Added the required music and motion usage descriptions and background audio mode.
- Added source-neutral collection, track, tempo, cadence, progress, adaptation, and honest tempo-measurement values.
- Added deterministic adaptation and cadence-filter tests.
- Added a Core Motion cadence provider behind the source-neutral boundary and compiled it for a generic iPhone target.
- Passed formatter, 29 package tests, 2 app-model tests, and 4 UI tests on the final tree.

## Shortest next action

Connect an unlocked, trusted iPhone with Developer Mode enabled. Then set the Apple development team for `com.samaydhawan.Samadhi`, confirm the MusicKit App Service is enabled for that bundle identifier, select the `Samadhi MusicKit Gate` scheme, and run the checklist above with one library playlist and one Bluetooth A2DP headphone route.
