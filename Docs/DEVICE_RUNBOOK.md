# Device runbook

This covers using a real iPhone. [PHONE-CHECK.md](PHONE-CHECK.md) says what to check once it is installed.

## What the phone needs

- iPhone 17 Pro on iOS 27 with Developer Mode on and an active Apple Music subscription.
- A Mac paired with it. Pairing is per Mac. Connect by cable once, accept the trust prompt, then enable Connect via network in Xcode's Devices and Simulators window. After that the phone only needs to be awake on the same network.
- Team `ZL5U59XBJ6` and App ID `com.samaydhawan.Samadhi` with the MusicKit App Service enabled.

## Signing

MusicKit requires the exact App ID. A wildcard profile builds and installs, then fails at the first catalog request. Automatic signing can quietly choose a wildcard, so `./Scripts/phone.sh install` selects an exact profile itself and refuses to install anything else.

To get the profile onto a Mac, use one of these:

1. In Xcode, open Settings, then Accounts, select the team, and choose Download Manual Profiles.
2. In the Apple developer portal, download the iOS App Development profile for the exact App ID, then open the file.

The current profile is `Samadhi Development 2026-08-15`, which expires 2027-08-15. If it has expired, create a new one for the exact App ID, the current Apple Development certificate, and the registered iPhone.

Do not create a Media Services key or embed a developer token. Apple issues the token automatically to a correctly signed app.

## Installing

~~~sh
./Scripts/phone.sh status
./Scripts/phone.sh install
./Scripts/phone.sh launch --core-diagnostics
~~~

`install` builds with the exact profile, checks the embedded profile and the signature, installs over the existing app, and confirms that the selected collection did not change. It never uninstalls. If the phone is locked, the install still succeeds and only the launch waits.

`--core-diagnostics` opens the hidden Debug screen. Compare its source fingerprint with the one `install` printed. They must match before any result counts.

## Reading a run

After a run finishes, pull its record while the phone is awake:

~~~sh
./Scripts/phone.sh pull
~~~

This copies `latest-run-diagnostics.json` to `Evidence/Temp/phone/` and prints a summary. Each finished run overwrites the file on the phone, so pull before the next one. To reread a saved record, run `python3 Scripts/read-run.py <file>`. The raw file can hold personal music data, so it stays out of Git.

The record holds 2,048 entries and drops per-second ticks first, so every song change, rate write, mode change, cue, and notice from a realistic run survives.

## Reading cue outcomes

A cue the reducer sent is not a cue that played. In the run file:

1. Entries of kind `autoFeedbackDelivery` carry `autoFeedbackTransactionID`, `autoFeedbackMoment` (`began` or `arrived`), `autoFeedbackFamily`, `autoFeedbackSoundPath`, `autoFeedbackDeliveryOutcome`, and `autoFeedbackDeliveryDetail`.
2. `playedThroughEngine` means the haptic engine started the pattern. `playedLocalSoundOnly` means no engine, and the arrival sound used the local player. `engineUnavailable`, `patternMissing`, and `cancelledBeforePlay` mean nothing physical happened, and the detail says why.
3. Pair each delivery with the `autoFeedback` entry of the same transaction identifier. A `began` with no delivery entry after it is a bug in the shell.
4. Entries of kind `hapticEngine` show the engine's life: `created`, `started`, `startFailed`, `stopped` with Apple's reason, `reset`, `unsupported`. A `stopped: application suspended` between a `began` and its `arrived` is the locked-screen case the spec calls out.

On an unlocked phone, the hidden Debug screen shows the last three outcomes under `What became of the cues`, and the `Next song` row says whether a fitting song was prepared.

"Played" is the engine's word, not the hand's. Whether a cue could be felt in a pocket stays a physical judgment.

## Feedback audition

The Auto feedback prototypes are played by hand from a Debug-only screen.

1. Start a real song in the Music app and leave it playing. Ducking, gaps, and route changes only show up against real Apple Music.
2. Launch with `./Scripts/phone.sh launch --feedback-audition`, or run the `Samadhi Feedback Audition` scheme in Xcode.
3. Use headphones at a safe volume, and keep the phone in the pocket for anything about tactile recognition.
4. Pick a family, direction, size, and sound path, then play the start, the arrival, or both. Sound and haptics toggle independently.
5. For a blinded run, note the seed and start the 10 trials. Copy the summary line, which carries family, sound path, seed, and score.

Nothing here becomes a product asset before this comparison. The bar is in [AUTO-CHANGE-INTERACTION-SPEC.md](AUTO-CHANGE-INTERACTION-SPEC.md).

## Focused core loop

The `Samadhi Apple Music Core Loop` scheme, or launching with `--apple-music-core-loop`, runs one known catalog song through real cadence and real Apple Music, with `What Samadhi saw` on screen. Use it to separate a playback problem from a playlist problem.

## Explaining a rejected song

`TempoProbe` prints the analyzer's decision and strongest tempo candidates for Apple catalog song identifiers. It makes no product claim and does not touch the phone.

~~~sh
swift run --package-path Packages/SamadhiKit TempoProbe 1497226892 1561775000
~~~

## Tempo corpus

The real-preview accuracy check needs no device. It downloads 12 fixed previews to temporary storage, analyzes them, deletes them, and fails below 10 of 12. Normal tests never use the network.

~~~sh
swift run --package-path Packages/SamadhiKit TempoCorpusValidator \
  --output Evidence/Audio/YYYY-MM-DD-tempo-corpus-validation.json
~~~

Older procedures and device records are in [Archive/DEVICE-HISTORY.md](Archive/DEVICE-HISTORY.md).
