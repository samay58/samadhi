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

The `Samadhi MusicKit Gate` scheme verifies that the harness and framework calls compile. Physical traces separately prove authorization, library loading, playback, mechanical rate writes, pause, and resume. Preview coverage, listening quality, background, controlled interruption, and route checks remain separate physical gates.

## Current device checks

- Unsigned generic iPhone build: passed
- Signed generic and physical iPhone builds: passed
- Physical iPhone installation and gate launch: passed
- Normal Simulator app: launched and visually checked
- MusicKit harness Simulator app: launched and visually checked
- Background audio entry in built Info.plist: verified as an array containing `audio`
- Physical device signing, build, installation, and launch: passed
- Contextual Music authorization and 40-playlist loading: passed
- Real playback plus 0.94, 1.00, and 1.06 rate writes: passed mechanically
- Pause and resume observation: passed
- Direct library preview coverage: failed at 0 of 10 in every sample
- ISRC catalog retry: blocked because all 40 sampled tracks omitted ISRC
- Equivalent-ID catalog retry: blocked by 40 `.developerTokenRequestFailed` results before catalog response
- Installed development profiles: only Xcode-managed wildcard `ZL5U59XBJ6.*` found; no exact Samadhi profile is installed
- Spotify adaptive playback: rejected by documented platform capability and policy review; no code spike warranted
- Listening, screen-lock background, controlled interruption, and route-loss checks: not proven

## Next source gate

Create a fresh development profile for the exact Samadhi App ID, sign and install a clean harness build, inspect the embedded identity, and run one minimal catalog request. Save the trace under `Evidence/Device/`. A real catalog response passes the token gate. A repeated `developerTokenRequestFailed` result after one clean reinstall fails it and selects local-file playback.

## Known environment behavior

iOS 27 beta Simulator can terminate concurrent UI test runners. Test script disables parallel execution. Serial suite is required gate.
