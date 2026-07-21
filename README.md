![Samadhi: music in stride](Brand/GitHub-Cover-Samadhi-1280x640.png)

# Samadhi

*music in stride*

Samadhi is a native iPhone music experience that lets a runner's cadence and music settle into one rhythm. The current build imports an Apple Music playlist, analyzes available previews locally, remembers the selection, and sends ready tracks through the real cadence-driven run. The active mechanics work now separates compatible-track selection, fine tempo correction, and any future beat-phase claim.

## Current state

Milestones 0 and 1 are complete. Milestone 2 is in progress. Apple Music is the selected production source, subject to a new felt-perceptibility gate. Exact-App-ID signing fixed catalog access, analyzer version 2 passes a narrow 12-preview corpus, and a 59-second physical run averaged 155 SPM with 98 percent tempo matched from player read-back. A real 25-track playlist restores with 13 ready tracks. A source-neutral planner now chooses the compatible pulse requiring the least stretch. Production connection, obvious-change listening proof, natural transition, long-form background playback, and recovery remain open.

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
| What makes the music feel synchronized? | [Docs/ADAPTIVE-AUDIO-PLAYBOOK.md](Docs/ADAPTIVE-AUDIO-PLAYBOOK.md) |
| What is the prioritized execution sequence? | [Docs/FELT-SYNCHRONIZATION-EXECUTION-SPEC.md](Docs/FELT-SYNCHRONIZATION-EXECUTION-SPEC.md) |
| What do product terms mean? | [Docs/CONTEXT.md](Docs/CONTEXT.md) |
| How will the production music source be decided? | [Docs/MUSIC-SOURCE-RESOLUTION-SPEC.md](Docs/MUSIC-SOURCE-RESOLUTION-SPEC.md) |
| How is code shaped? | [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) |
| Why were key choices made? | [Docs/DECISIONS.md](Docs/DECISIONS.md) |
| What proves current behavior? | [Docs/TESTING.md](Docs/TESTING.md) |
| What changed over time? | [Docs/PROGRESS.md](Docs/PROGRESS.md) |
| How should brand feel? | [Docs/BRAND.md](Docs/BRAND.md) |

No third-party production dependency ships in app.
