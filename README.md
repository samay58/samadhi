![Samadhi: music in stride](Brand/GitHub-Cover-Samadhi-1280x640.png)

# Samadhi

*music in stride*

Samadhi is a native iPhone music experience that lets a runner's cadence and music settle into one rhythm. The current build proves complete interaction and now connects a verified Apple Music fixture, Core Motion cadence, bounded adaptation policy, and production playback adapter in one focused device configuration. The normal app remains deterministic until playlist import is connected.

## Current state

Milestones 0 and 1 are complete. Milestone 2 is in progress. Apple Music is the selected production source. Exact-App-ID signing fixed catalog access, City Pocket passed 10 of 10 local preview decodes, and real playback reached a Beoplay Eleven Bluetooth route with live 0.94, 1.00, and 1.06 writes. Analyzer version 2 passes 12 of 12 tempo-declared Apple music previews through the public file interface. A 29-second physical walk produced live cadence and an honest 142 SPM average. A follow-up with a 139.5 BPM fixture produced no perceptible speed change, so the focused build now separates target rate from MusicKit read-back and uses a validated 149.75 BPM fixture for one objective rate-response check.

Start with [product ethos](Docs/PRODUCT.md), then read [current status](Docs/STATUS.md), [next plan](Docs/PLAN.md), the [Milestone 2 specification](Docs/MILESTONE-2-SPEC.md), and the active [music-source resolution specification](Docs/MUSIC-SOURCE-RESOLUTION-SPEC.md).

## Build

Requirements:

- Xcode with iOS 26 SDK support
- XcodeGen

~~~sh
./Scripts/bootstrap.sh
./Scripts/test.sh
~~~

Code formatting:

~~~sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  xcrun swift-format lint --configuration .swift-format --recursive \
  App Packages/SamadhiKit/Sources Packages/SamadhiKit/Tests Tests
~~~

## Project guide

| Question | Source |
| --- | --- |
| What feeling are we building? | [Docs/PRODUCT.md](Docs/PRODUCT.md) |
| Where are we now? | [Docs/STATUS.md](Docs/STATUS.md) |
| What happens next? | [Docs/PLAN.md](Docs/PLAN.md) |
| What exactly are we building next? | [Docs/MILESTONE-2-SPEC.md](Docs/MILESTONE-2-SPEC.md) |
| How will the production music source be decided? | [Docs/MUSIC-SOURCE-RESOLUTION-SPEC.md](Docs/MUSIC-SOURCE-RESOLUTION-SPEC.md) |
| How is code shaped? | [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) |
| Why were key choices made? | [Docs/DECISIONS.md](Docs/DECISIONS.md) |
| What proves current behavior? | [Docs/TESTING.md](Docs/TESTING.md) |
| What changed over time? | [Docs/PROGRESS.md](Docs/PROGRESS.md) |
| How should brand feel? | [Docs/BRAND.md](Docs/BRAND.md) |

No third-party production dependency ships in app.
