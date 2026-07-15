# In Step

In Step is a native iPhone interaction prototype for a body-aware music player. Milestones 0 and 1 use deterministic simulated cadence and a simulated beat clock. Core Motion and adaptive audio are intentionally outside this build.

## Requirements

- Xcode 27 or later with an iOS Simulator
- XcodeGen

## Build

```sh
./Scripts/bootstrap.sh
./Scripts/test.sh
```

The generated Xcode project targets iOS 26 and contains no third-party production dependencies.

