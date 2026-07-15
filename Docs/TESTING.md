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
- Preview matrix covers every meaningful product and accessibility state.
- Golden XCUITest covers Start, lock, controls, pause, resume, skip, finish hold, summary, and Done.
- Failure XCUITests cover permission denial and route loss.

## Evidence record

Runtime commands, Simulator identity, test outcomes, screenshots, and known limitations are recorded in `Docs/BUILD_LOG.md`.

