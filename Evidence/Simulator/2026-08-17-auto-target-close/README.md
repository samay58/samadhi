# Auto target and quiet close evidence

Captured on August 17, 2026 with the iPhone 17 Pro Simulator on iOS 27.0.

## Frames

- `tempo-control-open-after.png`: normal text size. The visible close mark is outside the ring and leaves every detent clear.
- `playback-controls-after-close.png`: one tap restores playback controls.
- `tempo-control-accessibility-xxxl-reduce-motion.png`: accessibility XXXL and Reduce Motion remain usable.
- `tempo-control-increased-contrast.png`: Increased Contrast strengthens the close surface without turning it into the main control.
- `core-diagnostics-low-tempo.png`: musical BPM, the supported alternate pulse, and running SPM remain separate.
- `core-diagnostics-sensor-and-auto-target.png`: the delayed new sensor sample, responsive filtered reading, settled target, requested rate, sent rate, and Apple Music reply are readable together.

The matched before frame is `../2026-08-15-manual-close/BD9929AF-8E87-4E02-ADC8-8189AF796178.png`. It shows the prior full-size glass circle competing with the wheel.

## Proof boundary

The interface tests verify a touch target of at least 44 by 44 points, no geometric overlap with the dial, clean dismissal, and no playback or rhythm mutation. These frames prove Simulator layout only. They do not prove touch feel, haptics, cadence quality, Apple Music behavior, or outdoor reliability.
