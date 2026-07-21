# Forty-BPM click wheel

Date: 2026-07-21

Device: iPhone 17 Pro Simulator

OS: iOS 27.0

## Result

- The expanded control opens inside the existing tempo aperture without adding another panel.
- Forty visible detents match forty one-BPM steps per revolution. Every fifth landmark is longer.
- A clockwise quarter-turn changes the simulated target from 168 to 178 BPM. The reverse gesture returns it to 168 BPM.
- The protected center, Auto and Manual ownership, and return to neutral pass the focused UI test.
- Deterministic tests cover the minus-20 through plus-20 Auto range, 120 through 210 running bounds, one event per accepted detent, five-BPM tactile landmarks, and forty detents per revolution.

Simulator cannot reproduce the iPhone Taptic Engine or audible Apple Music adaptation. The low-sharpness custom haptics, five-BPM landmarks, and soft Auto landing still require one brief physical judgment.

## Artifact

`2026-07-21-forty-bpm-click-wheel.png`

SHA-256: `8d940a117741b19c08dc43339afc9186324e0dae4d22627fcfac2e9df720811b`
