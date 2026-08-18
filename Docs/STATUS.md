# Current status

## Product state

| Area | Current truth | Proof |
| --- | --- | --- |
| Music source | Apple Music is selected | Authorization, catalog access, preview decoding, playback, and rate writes passed on iPhone |
| Music import | One playlist can be selected, analyzed locally, restored, retried, and filtered to ready tracks | Automated tests, Simulator frames, and prior phone import |
| Tempo analysis | Version 4 keeps musical BPM separate from the supported step relationship | 12 of 12 public preview references and deterministic ambiguity tests |
| Motion | Steady readings from 90 through 210 SPM are accepted; walking needs longer evidence | Saved phone replay, deterministic stale-data rejection, and one attributed workout |
| Auto | A responsive sensor estimate feeds a separate calm musical target | Noise, spike, faster, slower, missing-input, and walking tests |
| Manual | Manual stays with the confirmed song and returns to Auto only after a different song is confirmed | Reducer, app-model, and interface tests |
| Playback range | The software candidate is 0.85 through 1.15 | Shared limits and endpoint tests across Auto, Manual, track fit, diagnostics, and player commands |
| Tempo wheel | The wheel has a quiet close action with a separate 44-point touch target | Interface tests and inspected Simulator frames |
| Debug explanation | Debug builds show the exact source fingerprint and the full motion-to-music calculation | Build inspection, diagnostic tests, and Simulator frames |
| Release isolation | The hidden Debug screen does not ship in Release | Release binary inspection |

## What the phone has proved

The August 17 workout came from an exact-profile build with a matching source fingerprint. Four delayed but forward-moving cadence readings acquired 133 SPM. Apple Music received 1.0390625 and reported 1.0390625 after 0.066 seconds. This proves the repaired timing rule for that observed phone pattern.

Samay also felt Auto changing the music. The changes felt jarring and unexplained. The workout mixed walking, light jogging, and lifting, so it does not prove the best walking threshold or how much time belonged to each activity.

The expanded 0.85 through 1.15 candidate is installed over Samadhi 1.0 build 1 with exact signing. The selected collection stayed byte-for-byte unchanged at SHA-256 `81a9b31fbc115d607bc766dd25374ecff6874b079276b68c3719cb122cea3f52`. The phone locked before launch, so the new endpoints have not produced an in-app fingerprint read-back, Apple Music reply, or listening result.

## Current software gate

- Project generation passed.
- Formatter lint passed.
- 153 Swift package tests passed.
- 27 app-model tests passed.
- 28 serial interface tests passed.
- Source-fingerprint tests passed.
- Resource-inclusive Debug and Release Simulator builds passed.
- The hidden Debug screen was absent from Release.
- The physical build used exact profile `Samadhi Development 2026-08-15`, which expires August 15, 2027.
- The embedded profile and app signature both use `ZL5U59XBJ6.com.samaydhawan.Samadhi`.

## Still open

- Launch the installed expanded-rate build and confirm its in-app source fingerprint.
- Get Apple Music read-back at 0.85 and 1.15, then judge both endpoints through headphones for a full musical section.
- Run a clean walking-only check. The 90 SPM floor and five-second walking delay are software choices, not physically tuned constants.
- Check whether steady lifting motion can falsely look like walking. Samadhi does not need a lifting mode.
- Rebuild Play, Pause, Previous, Next, and Finish as one coherent control system. Fix the Finish border overflow.
- Prove one known natural song boundary, screen lock, interruption, and route recovery.
- Prototype the faster and slower haptic and sound cues only after the core behavior gate.
- Complete one 20-minute outdoor run.

## Where we left off

The core reset is consolidated in the current candidate. The next physical gate is short: launch, confirm the fingerprint, compare 0.85 and 1.15 with the known 0.90 and 1.10 pair, and record Apple Music's replies. If the endpoints sound clean, the next Main Thing is the transport and Finish craft pass.

Historical implementation detail lives in [PROGRESS.md](PROGRESS.md). Product choices live in [DECISIONS.md](DECISIONS.md). Exact checks and proof limits live in [TESTING.md](TESTING.md).
