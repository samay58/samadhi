# Verification

## Full gate

~~~sh
./Scripts/bootstrap.sh
./Scripts/test.sh
~~~

Scripts/test.sh runs Swift package tests, app-model tests, and UI tests serially on iPhone 17 Pro Simulator.

Latest gate passed 15 Swift package tests, 2 app-model tests, and 4 UI tests. Result summary lives at Evidence/Logs/final-test-summary.json.

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

## Known environment behavior

iOS 27 beta Simulator can terminate concurrent UI test runners. Test script disables parallel execution. Serial suite is required gate.
