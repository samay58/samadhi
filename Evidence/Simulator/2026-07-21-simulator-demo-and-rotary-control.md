# Simulator demo and rotary control evidence

Date: 2026-07-21

Environment: iPhone 17 Pro Simulator, iOS 27.0, Debug build

## Result

The normal app launches without Apple Music and presents `Samadhi demo` immediately. A second local collection, `Soft Miles`, follows the same selection and import presentation. Both use simulated cadence and silent simulated playback. This path is compiled only for Debug Simulator builds.

The rotary control passed these checks:

| Check | Result |
| --- | --- |
| Clockwise quarter-turn from neutral Auto | 168 to the plus-eight limit at 176 |
| Counterclockwise quarter-turn from 176 | 165 |
| Gesture beginning in protected center | No BPM change |
| Angle crossing positive and negative pi | Direction preserved |
| Fast movement across several detents | One reducer action and haptic event per accepted BPM step |
| Ninth positive Auto step | State remains at plus eight and emits the distinct limit event |
| Manual then Auto | Ownership changes and Auto returns to 168 |

The pass found and fixed two real defects. The opening part of a turn was initially discarded because tracking began at the first changed point rather than finger-down. The automatic bound was also recalculated after each accepted detent, which made a plus-eight gesture converge at plus four. The final implementation fixes the finger-down origin and the cadence-relative bounds for the entire gesture.

Simulator proves geometry, direction, state changes, accessibility exposure, visual feedback, and the reducer-to-haptic event contract. It does not reproduce the iPhone haptic motor or audible Apple Music rate changes. Physical tactile quality and listening remain separate short checks.

## Artifacts

- `2026-07-21-simulator-demo-ready.png`
  - SHA-256: `722fd517653a02156ca272918b01e39355e5b29952076fdaf36b59524d24e2ec`
- `2026-07-21-rotary-bpm-demo.mov`
  - SHA-256: `06012ba16e94f42eb4cea84877f39008abf954b1e622b6a88bd8274c784f24c0`
