# Manual song ownership and tempo close

These frames come from passing iPhone 17 Pro Simulator interface tests on iOS 27.0.

- `BD9929AF-8E87-4E02-ADC8-8189AF796178.png`: Manual is active before the player confirms a different song.
- `76C45E52-4968-403A-BB04-A74F358A148E.png`: Auto is active after the player confirms the different song.
- `DBADB457-435B-4FB4-8943-EDE3A2FF832A.png`: the tempo wheel is closed and Previous, Pause, Skip, and Finish are restored.
- `BCB99ACF-6153-484C-9BDA-734337F1EFC0.png`: the close action remains visible and usable with accessibility XXXL text and Reduce Motion.

The full serial interface test run passed 27 tests with no failures. Simulator evidence proves the state and interface behavior. It does not prove physical cadence, Apple Music quality, haptic feel, or audible response.
