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

## D-006. Ambient visual surface

Replace the square demo artwork with a native full-screen fluid field built from `MeshGradient` and restrained contour lines. The field is deterministic, collection-colored, local, and frozen under Reduce Motion. Do not use generated video, AgentCash, hosted assets, or a free-running decorative loop. The live renderer is cheaper, sharper at every device size, and can preserve continuity into the tempo aperture.

## D-007. Product-wide depth

Use depth as interaction hierarchy, not decoration. The musical surface is continuous, one object owns attention, and native glass is reserved for controls that sit above it. State changes should compress, settle, reveal, or transform in place. Summary and recovery screens remain still enough to signal a change in energy. This takes the useful lessons from Avec and v0 for iOS without copying their layout or importing a web component system.

## D-008. Open information hierarchy

Do not use passive glass or bordered cards for labels, music identity, recovery copy, or summary metrics. Use spacing, type scale, and edge-free tonal contrast fields. Glass indicates an actionable control. Persistent circular marks must communicate progress or cadence state.

## D-009. Brand mark boundary

Use the first user-provided interlocking ribbon direction for the production app icon. Refine it on an opaque parchment field, scale it for a 60-point Home Screen presentation, and keep it free of text and literal fitness or music symbols. Use the native ribbon glyph inside the interface so a square app icon is never nested into the app chrome. The icon decision, optical scale, and generation record are versioned in `Docs/BRAND.md`.

## D-010. Product name

Rename the product to Samadhi across the application target, Xcode project and scheme, bundle identifiers, Swift package modules, tests, documentation, repository folder, and final handoff path. Preserve “in step” only as a lowercase cadence-quality metric. Samadhi names the intended feeling of meditative consciousness.
