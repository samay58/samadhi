# Verification

## Full gate

~~~sh
./Scripts/bootstrap.sh
./Scripts/test.sh
~~~

Scripts/test.sh runs Swift package tests, app-model tests, and UI tests serially on iPhone 17 Pro Simulator.

The current gate passed 29 Swift package tests, 2 app-model tests, and 4 UI tests. The result summary lives at `Evidence/Logs/final-test-summary.json`; the full log lives at `Evidence/Logs/milestone-2-safe-groundwork-test.log`.

Formatter gate:

~~~sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  xcrun swift-format lint --configuration .swift-format --recursive \
  App Packages/SamadhiKit/Sources Packages/SamadhiKit/Tests Tests
~~~

## Coverage

Domain tests cover:

- Adaptive and fixed starts
- Stale cadence and timeout tokens
- Paused-time exclusion
- Resume reacquisition with cadence prior
- Permission fallback
- Route loss and explicit resume
- Finish visibility and hold identity
- Cancellation ordering
- VoiceOver control pinning
- Mixed summary metrics
- Track progress reset and configured collection wraparound
- Half-time and double-time tempo normalization
- Safe rate bounds, initial and ongoing ramps, deadband, and target update interval
- Target recomputation when the track changes at a steady cadence
- Confidence hold, return to normal rate, and reacquisition reset
- Incompatible tracks and applied-rate match timing
- Honest tempo measurement and fixed-rhythm Not measured summary

Motion tests cover:

- The simulation and production provider boundary
- Five-observation stable lock
- Three-observation resume lock with the prior estimate as a smoothing seed
- Walking-range rejection, isolated spike rejection, and sustained missing cadence

The Core Motion adapter compiles for a generic iPhone target. Its sensor quality is not covered by automated tests.

UI tests cover:

- Complete golden run
- Motion permission recovery
- Audio route recovery
- Missing artwork

App-model tests cover ready mapping and start transition.

## Visual proof

Final frames under Evidence/Simulator/ cover ready, locked run, controls, summary, and Home Screen icon. Evidence/Previews/ covers accessibility text and state-specific visual checks.

## Truth boundary

Simulator verifies interaction, accessibility structure, reducer behavior, resource packaging, and deterministic motion. It cannot validate physical cadence quality, real headphone route behavior, tempo adaptation, or listening artifacts.

The `Samadhi MusicKit Gate` scheme verifies that the harness and framework calls compile. It does not pass authorization, library, preview coverage, playback, rate quality, background, interruption, or route gates without a physical iPhone and account.

## Current device checks

- Unsigned generic iPhone build: passed
- Signed generic iPhone build: failed because `DEVELOPMENT_TEAM` is blank
- Normal Simulator app: launched and visually checked
- MusicKit harness Simulator app: launched and visually checked
- Background audio entry in built Info.plist: verified as an array containing `audio`
- Physical device and listening checks: blocked

## Known environment behavior

iOS 27 beta Simulator can terminate concurrent UI test runners. Test script disables parallel execution. Serial suite is required gate.
