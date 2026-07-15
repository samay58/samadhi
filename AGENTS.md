# In Step repository instructions

## Product
- This is a minimal body-aware music player, not a fitness platform.
- Do not add features not present in PRODUCT.md.
- The shipped app contains no AI or network dependency.
- Interaction quality and reliable audio behavior outrank feature breadth.

## Architecture
- Keep InStepDomain free of UI and Apple media frameworks.
- Use the functional-core, actor-shell architecture in ARCHITECTURE.md.
- Do not introduce a production dependency without documenting why.
- Do not call audio or motion services directly from SwiftUI views.
- Represent mutually exclusive states with enums, not boolean clusters.

## Design
- Use native SwiftUI.
- Use Liquid Glass sparingly and only for interactive raised controls.
- Do not add neon gradients, fake waveforms, glowing orbs, dashboards, cards, or decorative charts.
- Every interactive component needs accessibility labels and previews.
- Every animation must be interruptible and respect Reduce Motion.

## Validation
- Build after each coherent change.
- Run relevant unit tests after domain changes.
- Verify every visual milestone in a real Simulator frame.
- Capture screenshots before claiming UI completion.
- Do not claim cadence quality without physical-device evidence.
- Do not claim audio quality without a listening check.
- Keep Docs/DECISIONS.md and Docs/TESTING.md current.

## Scope discipline
- When a requested implementation implies new scope, stop and record it under Deferred rather than silently adding it.

