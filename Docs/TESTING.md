# Testing

## Repeatable commands

```sh
./Scripts/bootstrap.sh
./Scripts/test.sh
```

## Milestone 0

- Generate the Xcode project.
- Build the app for the selected Simulator.
- Run Swift package tests.
- Run app unit and UI test targets.

## Milestone 1

- Reducer transition tests cover all phases and recovery paths.
- Summary tests verify excluded acquisition and paused time.
- Domain effect tests verify cancellation ordering, route safety, VoiceOver control pinning, finish persistence, and song-progress resets.
- Beat-clock and cadence-provider tests verify deterministic phase, paused freezing, ordered samples, and completion.
- Preview matrix covers every meaningful product and accessibility state.
- Golden XCUITest covers Start, lock, controls, pause, resume, skip, finish hold, summary, and Done.
- Failure XCUITests cover permission denial and route loss.
- Missing-artwork UI coverage starts the run rather than checking only the ready screen.

## Evidence record

Runtime commands, Simulator identity, test outcomes, screenshots, and known limitations are recorded in `Docs/BUILD_LOG.md`.

The iOS 27 beta runtime can terminate UI test runners when tests execute concurrently. `Scripts/test.sh` disables parallel testing; the serial suite is the repeatable gate and passes cleanly.
