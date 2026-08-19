# Auto feedback prototypes, 2026-08-18

This folder records the first set of directional Auto feedback prototypes: three haptic families as
AHAP files, three matching arrival sounds in faster and slower forms, and the hidden Debug screen that
plays them by hand.

Nothing here is approved product material. Every pattern and every sound is a prototype built for the
physical comparison on the phone.

## Where the files live

- Patterns and sounds: `Resources/AutoFeedback/<family>/`
- Sound generator: `Scripts/generate-auto-feedback-sounds.py`
- Shell service: `App/AutoFeedbackService.swift`
- Debug audition screen: `App/FeedbackAuditionView.swift`
- Manifest with full parameters and checksums: `sound-manifest.json`
- Waveform sheet: `waveforms.png`
- Audition screenshot: `feedback-audition.png`

## Rights

The six arrival sounds are original offline prototypes. They were synthesized on this machine by
`Scripts/generate-auto-feedback-sounds.py` using only the Python standard library. No sample pack, no
recording, no library asset, no online service, and no paid API was involved. There is no third-party
license to preserve, because there is no third-party material in these files.

Re-running the script with the same parameters reproduces the same bytes, so the checksums below are
the record of exactly which prototype was tested.

## Haptic families

Each family has six start patterns, two directions crossed with three size bands, and one soft
terminal arrival pattern per direction. That is 24 AHAP files in total.

| Family | Faster start | Slower start |
| --- | --- | --- |
| pulse | light anchor pulse, then a firmer sharper pulse 110 ms later | firm anchor pulse, then a softer longer continuous release |
| swell | one continuous event whose intensity and sharpness climb | one continuous event whose intensity and sharpness fall away |
| step | three transients with tightening gaps and rising weight | three transients with widening gaps and falling weight |

Size bands scale intensity only. The event order inside a pattern never changes, so the learned
direction stays the same at every size. The bands are 0.45 for small, 0.65 for medium, and 0.95 for
large, applied to the strongest event in the pattern.

Start pattern spans run from 160 ms to 240 ms. The arrival pattern in every family is one transient at
0.4 intensity with low sharpness, shaded slightly per family and direction.

## Arrival sounds

All six files are 48 kHz, mono, 16-bit PCM. Each is a sine with a quiet second harmonic at 0.18 of the
fundamental, a raised-cosine attack between 9 ms and 15 ms, and an exponential release with a short
linear fade to exact zero at the end. Faster forms move up a fourth or a fifth. Slower forms move down.
Every file is normalised to a peak of -9 dBFS, which is below the -6 dBFS ceiling in the brief.

| File | Material | Duration (s) | Sample rate | Peak dBFS | RMS dBFS |
| --- | --- | --- | --- | --- | --- |
| pulse/arrival-faster.wav | two short soft tones a fifth apart, rising | 0.310 | 48000 | -9.00 | -20.56 |
| pulse/arrival-slower.wav | two short soft tones a fifth apart, falling | 0.340 | 48000 | -9.00 | -21.01 |
| swell/arrival-faster.wav | one gliding tone up a fifth | 0.320 | 48000 | -9.00 | -17.34 |
| swell/arrival-slower.wav | one gliding tone down a fifth | 0.340 | 48000 | -9.00 | -19.88 |
| step/arrival-faster.wav | three stepped tones, root to fourth to fifth | 0.350 | 48000 | -9.00 | -19.83 |
| step/arrival-slower.wav | three stepped tones, fifth to fourth to root | 0.375 | 48000 | -9.00 | -19.84 |

SHA-256:

| File | SHA-256 |
| --- | --- |
| pulse/arrival-faster.wav | 931489e1cce2e6fc7d1bf4fe571f7e360393940571ddfd6b797d0730e7610ae3 |
| pulse/arrival-slower.wav | feb673af3043aac44eed16bdd9495e33aaaffc6fb2e0a91155ec9f03468e5e97 |
| swell/arrival-faster.wav | 52fdc7895d2404b3208cbc8e91cb405dd976d2acd2008201fcc48aef03ebd29f |
| swell/arrival-slower.wav | 57bef5665ebdaf0a6265a335b41ad30de82a0872422b0d935383f0bb5039c221 |
| step/arrival-faster.wav | 49b8037a838e1e3d7a4d2f56567c8a9561c8222bd105762c3d09bb628edbe88d |
| step/arrival-slower.wav | 6adca6c4fbb51364d3aa425950a4d827d7cfd9f971226001283f2b2f721159e8 |

The authoritative checksums are the ones in `sound-manifest.json`. That file is written by the same
run that writes the audio, so it cannot drift from the bytes.

## How the sounds were checked without listening

Listening is not possible in this session. The checks that were run are numeric and visual:

- Peak and RMS were measured from the written 16-bit samples, not from the pre-quantisation floats.
- Every file peaks at exactly -9.00 dBFS, so no file clips and none is louder than the brief allows.
- Every duration sits inside the 180 ms to 450 ms window.
- Every file reports one channel and 48000 Hz in its own WAV header, read back from the bundle by an
  app-model test rather than from the source tree.
- `waveforms.png` renders all six files stacked. The pulse lanes show two bursts, the step lanes show
  three, and the swell lanes show one. The faster lanes gain weight toward the end and the slower lanes
  lose it, which is the shape the brief asks for.

## Release isolation

Both builds targeted the same Simulator.

```sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
xcodebuild build -project Samadhi.xcodeproj -scheme Samadhi -configuration Debug \
  -destination 'platform=iOS Simulator,id=EA771220-82AB-4D98-A016-C5FD7951D5DC' \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
xcodebuild build -project Samadhi.xcodeproj -scheme Samadhi -configuration Release \
  -destination 'platform=iOS Simulator,id=EA771220-82AB-4D98-A016-C5FD7951D5DC' \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

A Debug build of this app does not keep its code in `Samadhi.app/Samadhi`. That file is a 40 KB
launcher stub and the app code lives in `Samadhi.app/Samadhi.debug.dylib`. Checking the stub reports
zero matches for everything, including code that is definitely present, so the Debug side of this
proof must read the dylib. Release has no such split and keeps its code in `Samadhi.app/Samadhi`.

```sh
D=~/Library/Developer/Xcode/DerivedData/Samadhi-gtimgpwnsrcyorajbfznudvlcryq/Build/Products
DBG="$D/Debug-iphonesimulator/Samadhi.app/Samadhi.debug.dylib"
REL="$D/Release-iphonesimulator/Samadhi.app/Samadhi"
strings -a "$DBG" | grep -cF FeedbackAudition
strings -a "$REL" | grep -cF FeedbackAudition
nm -a "$DBG" | grep -c Audition
nm -a "$REL" | grep -c Audition
```

Match counts:

| Pattern | Debug dylib | Release binary |
| --- | --- | --- |
| `FeedbackAudition` (strings) | 5 | 0 |
| `Feedback audition` (strings) | 1 | 0 |
| `Play arrival` (strings) | 1 | 0 |
| `Blinded trial` (strings) | 1 | 0 |
| `feedback-audition` (strings) | 2 | 0 |
| `audition-summary` (strings) | 1 | 0 |
| `core-loop-diagnostics` (strings) | 1 | 0 |
| `Audition` (nm symbols) | 594 | 0 |
| `CoreLoopDiagnostics` (nm symbols) | 382 | 0 |
| `AutoFeedbackService` (strings) | 4 | 6 |

The last two rows are the controls. `core-loop-diagnostics` is the hidden Debug screen that already
existed, and it disappears from Release the same way, so the method matches the established check.
`AutoFeedbackService` is production code and stays in Release, so the zeros above are specific to the
audition surface rather than a build that dropped the whole feature.

Release still packages the prototype assets. `Release-iphonesimulator/Samadhi.app/AutoFeedback`
contains 30 files, the 24 patterns and 6 sounds.

## Audition screenshot

`feedback-audition.png` is a Debug build installed and launched on Simulator
`EA771220-82AB-4D98-A016-C5FD7951D5DC`:

```sh
xcrun simctl install "$SIM" "$D/Debug-iphonesimulator/Samadhi.app"
xcrun simctl launch "$SIM" com.samaydhawan.Samadhi --feedback-audition
xcrun simctl io "$SIM" screenshot feedback-audition.png
```

The frame shows the family picker on Pulse, direction on Faster, size on Medium, the sound path on
Core Haptics audio, both toggles on, and the three play buttons. The blinded trial section sits below
the fold in that frame. Controls are plain native List rows with no decoration, which matches the
existing hidden Debug screen.

## File format

The service loads WAV directly. Core Haptics `registerAudioResource` and `AVAudioPlayer` both read it,
so no CAF conversion was made and none is bundled. WAV is the only source and the only shipped form.

## What software proved

- All 24 AHAP files parse with `CHHapticPattern(contentsOf:)` inside the running app bundle.
- The asset catalog resolves a URL for every family, direction, and size, and for every arrival sound.
- The service plays each moment of a transaction once, holds an arrival that would land on top of its
  own start, and clears pending arrivals on `cancelAll`.
- The Debug audition screen is present in a Debug build launched with `--feedback-audition` and absent
  from a Release build of the same source.
- Samadhi calls no `setCategory`, `setMode`, or `setActive` anywhere in the app. The only
  `AVAudioSession` use is reading route and interruption notifications. Nothing requests ducking, and
  `AutoFeedbackService` deliberately does not touch the session at all.

## What software did not prove

- How any pattern feels in the hand or in a pocket. No Simulator result can judge tactile quality.
- How any sound sits against real Apple Music. Level, warmth, masking, and tail behavior are open.
- Whether Apple Music keeps playing clean and unducked while a cue plays. Only the phone can show that.
- Whether cues arrive while the screen is locked, or survive an interruption and an engine reset on a
  real device.
- Which of the two sound paths, Core Haptics custom audio or the local audio player, behaves better
  alongside Apple Music.
- Whether faster and slower are recognisable without looking. The blinded trial in the audition screen
  exists to answer that tomorrow, not today.

## Tomorrow

Use the audition screen with a seed written down, run ten blinded trials per family, and copy the
summary line out of the screen after each set. Compare both sound paths on the same family before
choosing. Nothing in this folder should be promoted to a product asset before that comparison.
