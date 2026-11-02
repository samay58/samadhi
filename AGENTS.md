# Samadhi repository instructions

Start with Docs/STATUS.md and Docs/PLAN.md. Docs/DEVELOPMENT.md explains the development loop and its commands. Docs/Archive/ is history, not instruction.

## Product
- This is a minimal body-aware music player, not a fitness platform.
- Do not add features not present in Docs/PRODUCT.md and Docs/PLAN.md.
- The shipped app contains no AI or network dependency beyond Apple Music.
- Interaction quality and reliable audio behavior outrank feature breadth.

## Architecture
- Keep SamadhiDomain free of UI and Apple media frameworks.
- Use the functional-core, main-actor-shell architecture in Docs/ARCHITECTURE.md.
- Do not introduce a production dependency without documenting why.
- Do not call audio or motion services directly from SwiftUI views.
- Represent mutually exclusive states with enums, not boolean clusters.
- Comments explain intent, invariants, or architectural seams. Never narrate obvious syntax or history.

## Design
- Use native SwiftUI.
- Use Liquid Glass sparingly and only for interactive raised controls.
- Do not add neon gradients, fake waveforms, glowing orbs, dashboards, cards, or decorative charts.
- Every interactive component needs accessibility labels and previews.
- Every animation must be interruptible and respect Reduce Motion.

## Validation
- Run `./Scripts/gate.sh` before a phone install or a push to main.
- Run relevant unit tests after domain changes. Write the failing test first when fixing a bug.
- Verify every visual milestone in a real Simulator frame, and open the frame before claiming a result.
- Do not claim cadence quality without physical-device evidence.
- Do not claim audio quality without a listening check.
- Never uninstall the app from the phone.
- Keep Docs/DECISIONS.md and Docs/TESTING.md current.
- Update Docs/STATUS.md, Docs/PLAN.md, and Docs/PROGRESS.md at each milestone boundary. STATUS holds current truth only.
- Keep raw captures in Evidence/Temp/. Follow Evidence/README.md for what gets committed.

## Scope discipline
- When implementation implies new scope, stop and record the decision in Docs/PLAN.md rather than silently adding it.
