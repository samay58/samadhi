![Samadhi: music in stride](Brand/GitHub-Cover-Samadhi-1280x640.png)

# Samadhi

*music in stride*

Samadhi is a native iPhone music experience that helps movement and music settle into one rhythm. It imports an Apple Music playlist, analyzes available previews on the phone, remembers the selection, and plays ready tracks through a cadence-aware run.

## Current state

Milestone 2 is in progress. Apple Music is the production player. Tempo analyzer version 4 passes 12 of 12 public preview references. A physical run confirmed that delayed iPhone cadence readings can settle Auto and that Apple Music reports the requested playback speed. Manual belongs to the current song, and the tempo wheel closes without changing playback. The current candidate supports steady movement from 90 through 210 steps per minute and can adjust one song from 85 to 115 percent of normal speed.

The run controls are now three separate Liquid Glass circles, a larger tinted one for Pause or Resume between Previous and Next, each springing under the finger, with a quiet hold-to-finish button below. Every confirmed song change records why it happened, and the hidden Debug screen shows the cause. A directional Auto feedback prototype exists in three haptic families with paired arrival sounds, playable from a hidden audition screen, and waits on the phone comparison before any of it is chosen.

The 85 and 115 percent endpoints pass software checks and are installed with exact Samadhi signing. They still need Apple Music read-back and listening approval on the phone. The feel of the new controls, the Auto feedback cues, a known natural song transition, background recovery, and the outdoor run also remain open.

Start with [product ethos](Docs/PRODUCT.md), [current status](Docs/STATUS.md), and [next plan](Docs/PLAN.md). Use the [Milestone 2 specification](Docs/MILESTONE-2-SPEC.md) for the complete release contract. The [music-source decision record](Docs/MUSIC-SOURCE-RESOLUTION-SPEC.md) explains why Apple Music was selected.

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

The `Samadhi Feedback Audition` scheme opens a Debug-only screen that plays the Auto feedback prototypes by hand; it is absent from Release builds.

A normal Debug launch on iPhone Simulator uses two local placeholder playlists, simulated cadence, and silent simulated playback. This keeps the complete import, run, rotary BPM, transport, transition, and summary flow available without Apple Music. Physical iPhone and Release builds never enable this path. Pass `--real-apple-music` only when intentionally debugging MusicKit in Simulator.

## Project guide

| Question | Source |
| --- | --- |
| What feeling are we building? | [Docs/PRODUCT.md](Docs/PRODUCT.md) |
| Where are we now? | [Docs/STATUS.md](Docs/STATUS.md) |
| What happens next? | [Docs/PLAN.md](Docs/PLAN.md) |
| What exactly are we building next? | [Docs/MILESTONE-2-SPEC.md](Docs/MILESTONE-2-SPEC.md) |
| What makes the music feel synchronized? | [Docs/ADAPTIVE-AUDIO-PLAYBOOK.md](Docs/ADAPTIVE-AUDIO-PLAYBOOK.md) |
| What is the prioritized execution sequence? | [Docs/FELT-SYNCHRONIZATION-EXECUTION-SPEC.md](Docs/FELT-SYNCHRONIZATION-EXECUTION-SPEC.md) |
| How is this MacBook prepared to continue the work? | [Docs/MACBOOK-SETUP.md](Docs/MACBOOK-SETUP.md) |
| What do product terms mean? | [Docs/CONTEXT.md](Docs/CONTEXT.md) |
| Why was Apple Music selected? | [Docs/MUSIC-SOURCE-RESOLUTION-SPEC.md](Docs/MUSIC-SOURCE-RESOLUTION-SPEC.md) |
| How is code shaped? | [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) |
| Why were key choices made? | [Docs/DECISIONS.md](Docs/DECISIONS.md) |
| What proves current behavior? | [Docs/TESTING.md](Docs/TESTING.md) |
| What changed over time? | [Docs/PROGRESS.md](Docs/PROGRESS.md) |
| How should brand feel? | [Docs/BRAND.md](Docs/BRAND.md) |

No third-party production dependency ships in app.
