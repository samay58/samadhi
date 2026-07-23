# Response latency gate

Date: 2026-07-23

Environment:

- Xcode 27.0
- iOS 27.0
- iPhone 17 Simulator
- Normal `Samadhi` scheme

Runtime review:

- The normal local-demo ready screen launched without Apple Music.
- The active run retained its open hierarchy, full-screen field, progress ring, and integrated rotary aperture.
- No visual regression or obstructive debug surface appeared.

Interaction proof:

- The focused rotary UI test completed four strong clockwise turns.
- Requested BPM moved above 188.
- Simulated applied Music BPM reached the truthful 185 BPM boundary within two seconds.
- Track identity did not change.
- `Changing song` did not appear.

Policy proof:

- Manual finger-up remains one immediate absolute target and one immediate rate command.
- Reliable Auto changes retarget after one second.
- A full 1.00 to 1.10 Auto response completes within five one-second decisions.
- The cadence filter and 2 SPM request deadband remain in place.

Gate:

- 103 package tests passed.
- 15 app-model tests passed.
- 10 UI tests passed.
- Swift formatter lint passed.
- Resource-inclusive Simulator build passed.

The first physical build was rejected because automatic signing selected a wildcard profile. After the exact profile was renewed, pushed commit `66e0616` was rebuilt in a clean detached worktree, inspected, and installed. Physical evidence is recorded separately under `Evidence/Device/`.
