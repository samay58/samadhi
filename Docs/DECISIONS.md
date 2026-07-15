# Decisions

## D-001. Deployment target

Target iOS 26. The installed Xcode 27 SDK is used to compile, but the product target remains the handoff's specified minimum.

## D-002. Project generation

Use XcodeGen to keep the Xcode project reproducible and reviewable. XcodeGen is a development tool only and adds no shipped dependency.

## D-003. Milestone 1 simulation boundary

Use deterministic simulated cadence and beat-clock implementations. Do not link Core Motion or build a production audio graph.

## D-004. State architecture

Use a pure reducer and one main-actor presentation model. Avoid screen-level view models and mutually exclusive boolean clusters.

## D-005. Evidence substitute

Appshots and Record & Replay are unavailable locally. Preserve Simulator screenshots, video, runtime UI snapshots, logs, XCUITests, and preview-host proof instead. Do not label these substitutes as Appshots.

