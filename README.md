![Samadhi: music in stride](Brand/GitHub-Cover-Samadhi-1280x640.png)

# Samadhi

*music in stride*

Samadhi is a native iPhone music player that lets movement and music settle into one rhythm. You import an Apple Music playlist. The phone analyzes each song's tempo locally, senses your steps through Core Motion, chooses songs that fit, and gently adjusts their speed while you walk or run.

It is deliberately small. There is no backend, account, analytics, GPS, or coaching, and no third-party code ships in the app.

## Current state

The software works end to end, and the proof that it feels right is still open. The finish line for this milestone is one 20-minute outdoor run with one imported playlist. [Docs/STATUS.md](Docs/STATUS.md) says exactly what has and has not been proved on a phone, and [Docs/PLAN.md](Docs/PLAN.md) says what happens next.

## Build

You need Xcode with an iOS 26 or later SDK and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

~~~sh
./Scripts/bootstrap.sh    # Generate the Xcode project from project.yml
./Scripts/gate.sh         # Run every software check
./Scripts/sim.sh run      # See the app in Simulator
~~~

A Debug launch in Simulator uses two local placeholder playlists, simulated cadence, and silent playback, so the whole flow works without Apple Music. Physical iPhones and Release builds never take this path.

[Docs/DEVELOPMENT.md](Docs/DEVELOPMENT.md) covers machine setup and the development loop.

## Layout

| Path | Holds |
| --- | --- |
| `App/` | The app shell: Apple Music, haptics, task ownership, diagnostics, and Debug harnesses |
| `Packages/SamadhiKit/` | The tested core: `SamadhiDomain`, `SamadhiMotion`, `SamadhiAudio`, `SamadhiDesign`, and two tempo tools |
| `Tests/` | App-model and interface tests |
| `Scripts/` | The gate, the Simulator loop, and the phone loop |
| `Docs/` | The project guide below |
| `Evidence/` | Proof behind the claims, described in [Evidence/README.md](Evidence/README.md) |

## Project guide

| Question | Source |
| --- | --- |
| What feeling are we building? | [PRODUCT.md](Docs/PRODUCT.md) |
| Where are we now? | [STATUS.md](Docs/STATUS.md) |
| What happens next? | [PLAN.md](Docs/PLAN.md) |
| How do I work on it? | [DEVELOPMENT.md](Docs/DEVELOPMENT.md) |
| How do I use a real phone? | [DEVICE_RUNBOOK.md](Docs/DEVICE_RUNBOOK.md) |
| What must a phone check prove? | [PHONE-CHECK.md](Docs/PHONE-CHECK.md) |
| How is the code shaped? | [ARCHITECTURE.md](Docs/ARCHITECTURE.md) |
| What proves current behavior? | [TESTING.md](Docs/TESTING.md) |
| Why were key choices made? | [DECISIONS.md](Docs/DECISIONS.md) |
| What exactly is the milestone? | [MILESTONE-2-SPEC.md](Docs/MILESTONE-2-SPEC.md) |
| How should an Auto change feel? | [AUTO-CHANGE-INTERACTION-SPEC.md](Docs/AUTO-CHANGE-INTERACTION-SPEC.md) |
| What makes music feel synchronized? | [ADAPTIVE-AUDIO-PLAYBOOK.md](Docs/ADAPTIVE-AUDIO-PLAYBOOK.md) |
| Which technology was checked? | [RESEARCH-2026-11.md](Docs/RESEARCH-2026-11.md) |
| What do product terms mean? | [CONTEXT.md](Docs/CONTEXT.md) |
| How should the brand feel? | [BRAND.md](Docs/BRAND.md) |
| What changed over time? | [PROGRESS.md](Docs/PROGRESS.md) |
| What is finished and kept for reference? | [Archive](Docs/Archive/README.md) |
