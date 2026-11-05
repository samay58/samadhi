# Color refresh, dark mode, and the Slipstream name

Source fingerprint `5ef58e035a78189710163d9abf24ed2cea1b7248567fa563e0df652be1ec4411`. iPhone 17 Pro Simulator with Xcode 27.2.

`dark-sheet.jpg` and `light-sheet.jpg` hold 16 screens drawn directly from state by `everyScreenDrawsInBothAppearances`: empty, reading, ready, failed, listening, running, lock brief, controls, wheel in Auto, wheel in Manual, paused, Finish armed, headphones lost, headphones back, motion permission, and summary.

`real-frames.jpg` comes from the launched app: the playlist sheet in dark, a ready playlist in dark, the run in dark, a ready playlist in light, and the largest text size in light.

What these frames prove: every screen uses the new palette in both appearances, text stays readable, the field has no bands or seams, and the run stays dark when the system is light.

What they do not prove: how lime looks in sun, how real glass looks on a phone, or what the high-precision field costs on a phone. The Reduce Transparency launch argument produced no visible change in the Simulator, so that setting needs a look on the phone. Nothing in this folder has been on a phone.
