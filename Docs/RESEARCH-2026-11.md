# Technology check, November 2026

One bounded pass, run 2026-11-02. The question: what current iOS tooling or music and motion technology would materially improve Samadhi that it does not already use?

Labels: SDK-read means read from the installed Xcode SDK. Primary means Apple or the original paper. Secondary means a third-party write-up, so treat it as a lead until tried here.

## Worth acting on

| Finding | Why it matters | Evidence | Next step |
| --- | --- | --- | --- |
| `ApplicationMusicPlayer.transition` accepts `.crossfade(duration:)`, available since iOS 18. Samadhi had never set it | Samay's largest reported hole is the abrupt break between songs. This is a one-line, Apple-supported softening that needs no audio engine | SDK-read in `MusicKit.swiftinterface`. How it behaves with `playbackRate` and with `skipToNextEntry` is unknown | Set to four seconds on 2026-11-02 at Samay's word. The phone decides whether it stays |
| Xcode 27.2 ships `xcrun mcp-server`, whose 54 tools include `RenderPreview`, `RunSomeTests`, `GetConsoleOutput`, and `DeviceInteractionSynthesize` | An agent can see a preview for each state without launching the app, and may be able to tap through the Simulator without a third-party tool | The service runs on the Mac Mini and its tool list was read directly. No tool has been used on Samadhi yet, because the first call needs an approval on the Mac's screen. Headless steps came from one [secondary guide](https://mehmetbaykar.com/posts/how-to-run-xcode-27-mcp-server-headless-with-claude-code/), and one of its commands was out of date | Setup is in [DEVELOPMENT.md](DEVELOPMENT.md) |
| Xcode 27.2 is released, while the scripts were pinned to a beta | A release toolchain is more stable, and the beta lacks the agent service | The full gate passes on Xcode 27.2 with the iOS 27.0 Simulator on the Mac Mini | Done. Scripts follow the selected Xcode |

## Worth trying only if a phone check asks for it

| Finding | The trigger | Evidence |
| --- | --- | --- |
| `HKWorkoutSession` and `HKLiveWorkoutBuilder` now run on iPhone from iOS 26 | Locked-screen cadence stops during the walk or the lock check. It would add a HealthKit permission to an app that is deliberately not a fitness product, so it must earn its place | [Apple's workout session guide](https://developer.apple.com/documentation/healthkit/running-workout-sessions) and [secondary notes on the iPhone runtime](https://blakecrosley.com/blog/watchos-workout-lifecycle). The iPhone background behavior is not confirmed by Apple's pages |
| `CMHeadphoneActivityManager` reports motion activity from AirPods Pro 2 and AirPods 4 from iOS 18 | Lifting keeps looking like walking, and Samay runs with supported AirPods. His recorded route is Beoplay Eleven, which is not listed. It reports activity type, not steps or cadence | [Apple's headphone activity guide](https://developer.apple.com/tutorials/data/documentation/coremotion/getting-motion-activity-data-from-headphones.md) |
| Beat This! is a neural beat and downbeat tracker with a community Core ML port | The beat-phase gate opens after the outdoor run. The current analyzer already passes 12 of 12 for tempo, so this only buys beat positions. Preview positions may not map to the full stream. The port's license and speed were not confirmed because the page refused the fetch | [Core ML port](https://huggingface.co/schism-audio/beat-this-coreml) |

## Checked and not worth adopting

| Option | Why not |
| --- | --- |
| A public AutoMix API | None found. The iOS 27 MusicKit additions are a music picker and item accessors, none about playback. [Summary of the additions](https://miniswift.run/whats-new/musickit/), [Apple forum question left open](https://developer.apple.com/forums/tags/musickit). Public MusicKit still offers rate and queue control, not a beat grid |
| `musicPicker(isPresented:title:selection:)` from the iOS 27 SDK | The custom playlist instrument is deliberate, proved in Simulator, and already handles every failure state. Replacing it would raise the iOS floor from 26 to 27 for no run-quality gain |
| AXe or XcodeBuildMCP for tapping through Simulator | A report says bundled AXe fails under Xcode 27 because `SimulatorKit.framework` moved, and it was [closed as not planned](https://github.com/getsentry/XcodeBuildMCP/issues/446). The existing XCUITest suite already drives every flow by accessibility label, and Xcode's own service now lists a tap tool |
| Snapshot testing with `swift-snapshot-testing` | [One write-up reports](https://dev.classmethod.jp/en/articles/swift-snapshot-testing/) that Liquid Glass does not render in its snapshots, and [iOS 26 failures remain discussed](https://github.com/pointfreeco/swift-snapshot-testing/discussions/1036). It would also add a dependency to verify a surface it cannot see. Real Simulator frames stay the proof |

## Science worth keeping in mind

Runners shift cadence toward a tempo without being told to, within a narrow window. One analysis puts the tolerance for unintentional entrainment at about 2.5 percent of initial cadence ([Van Dyck and colleagues](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4526248/)). Entrainment is weaker without an instruction to match ([later study](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8048782/)). A positive phase angle was linked to higher motivation and cadence ([Buhmann and colleagues](https://pmc.ncbi.nlm.nih.gov/articles/PMC6283599)).

The practical reading for Samadhi is an inference, not a tested result: exact tempo matching may matter less than choosing songs that land close, then keeping changes rare and clear. That agrees with Samay's August feedback favoring approximate alignment over constant correction.

## What this pass did not settle

It found no benchmark of AirPods-based cadence, no measurement of Bluetooth delay against footfall, and no running app built on these APIs. It did not test anything on the phone.
