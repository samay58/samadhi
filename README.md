![Samadhi: music in stride](Brand/GitHub-Cover-Samadhi-1280x640.png)

# Samadhi

*music in stride*

Samadhi is a native iPhone music experience that lets a runner's cadence and music settle into one rhythm. The current build proves complete interaction with deterministic simulated cadence and beat timing. Milestone 2 is specified to add playlist import, real cadence, and adaptive audio.

## Current state

Milestones 0 and 1 are complete. The app builds for iOS 26, covers the full run flow, preserves calm recovery behavior, supports accessibility states, and passes automated domain, presentation, and UI tests. Milestone 2 implementation has not started.

Start with [product ethos](Docs/PRODUCT.md), then read [current status](Docs/STATUS.md), [next plan](Docs/PLAN.md), and the [Milestone 2 specification](Docs/MILESTONE-2-SPEC.md).

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
| How is code shaped? | [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) |
| Why were key choices made? | [Docs/DECISIONS.md](Docs/DECISIONS.md) |
| What proves current behavior? | [Docs/TESTING.md](Docs/TESTING.md) |
| What changed over time? | [Docs/PROGRESS.md](Docs/PROGRESS.md) |
| How should brand feel? | [Docs/BRAND.md](Docs/BRAND.md) |

No third-party production dependency ships in app.
