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
| Transport and Finish | Previous, Pause or Resume, and Next are one glass capsule bar with a raised primary disc. Finish is a quiet hairline button below the bar that arms a hold whose fill is drawn inside the pill and clipped by the same capsule | Serial interface tests and 39 inspected Simulator images covering five environments, two of them contact sheets, with no fill edge outside the border in any after frame |
| Auto feedback | The reducer owns one directional transaction per meaningful Auto change. Three prototype haptic families, six arrival sounds, and a hidden audition screen exist in the app | Domain, app-model, and packaged-asset tests. Nothing about tactile feel, sound quality, or Apple Music coexistence is physically proved |
| Song-change cause | Every confirmed song change records a cause: natural end, an outside change, or an explicit Previous or Next | Pure attribution tests, scripted Simulator boundary events, and the Debug row `Last song change` |
| Debug explanation | Debug builds show the exact source fingerprint, the full motion-to-music calculation, the Auto cue in flight, and the cause of the last song change | Build inspection, schema-version-10 diagnostic tests, and Simulator frames |
| Release isolation | Neither the hidden Debug screen nor the feedback audition screen ships in Release | Release binary strings and symbol counts read against the Debug dylib |

## What the phone has proved

The August 17 workout came from an exact-profile build with a matching source fingerprint. Four delayed but forward-moving cadence readings acquired 133 SPM. Apple Music received 1.0390625 and reported 1.0390625 after 0.066 seconds. This proves the repaired timing rule for that observed phone pattern.

Samay also felt Auto changing the music. The changes felt jarring and unexplained. The workout mixed walking, light jogging, and lifting, so it does not prove the best walking threshold or how much time belonged to each activity.

The current candidate from `main` at `67adf80` is installed over Samadhi 1.0 build 1 with exact signing. The selected collection stayed byte-for-byte unchanged at SHA-256 `51b4096cc3b2c29ae32d85290b5a9f72166460f23b130d818508f7507b4e8397`. The phone was unlocked, so the hidden Debug screen was read on the device: its source fingerprint `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6` equals the signed build. The new endpoints, the transport and Finish feel, the Auto cues, and the song-change causes have not produced an Apple Music reply, a listening result, or any physical judgment yet.

## Current software gate

- Project generation passed.
- Formatter lint passed.
- 179 Swift package tests passed.
- 39 app-model tests passed.
- 32 serial interface tests passed.
- Source-fingerprint tests passed.
- Resource-inclusive Debug and Release Simulator builds passed.
- The hidden Debug screen was absent from Release.
- The feedback audition screen was absent from Release. The Debug side of that check reads `Samadhi.app/Samadhi.debug.dylib`, because the Debug `Samadhi.app/Samadhi` is a launcher stub.
- This candidate was built for the phone with exact profile `Samadhi Development 2026-08-15`, which expires August 15, 2027, installed in place on 2026-08-19, and read back on the device: in-app source fingerprint `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6`, matching the built Info.plist.
- The embedded profile and app signature both use `ZL5U59XBJ6.com.samaydhawan.Samadhi`.
- The `Samadhi Feedback Audition` scheme builds for the phone from the same bundle with the same fingerprint.

## Still open

The whole physical list is written as one ordered checklist in [PHONE-CHECK-2026-08-19.md](PHONE-CHECK-2026-08-19.md). The candidate is installed and its fingerprint is confirmed; every item below is still a body, ear, or real Apple Music judgment.

- Get Apple Music read-back at 0.85 and 1.15, then judge both endpoints through headphones for a full musical section.
- Judge transport and Finish by hand: press response, one tick per Previous or Next, arming, early release, and one completed hold.
- Run the blinded faster and slower trials for all three prototype families on both sound paths, and listen for ducking, gaps, or a route change while Apple Music plays.
- Read `Last song change` after one natural end and after one explicit Next, and confirm both causes.
- Check screen lock, an interruption, and route recovery, including that no old Auto cue replays afterward.
- Run a clean walking-only check. The 90 SPM floor and five-second walking delay are software choices, not physically tuned constants.
- Check whether steady lifting motion can falsely look like walking. Samadhi does not need a lifting mode.
- Complete one 20-minute outdoor run.

## Where we left off

The transport and Finish pass, deterministic song-change causes, and the first directional Auto feedback prototype are merged on `main`, pass the software gate, and are installed on the phone with the in-app fingerprint confirmed on 2026-08-19. Endpoint read-back and listening at 0.85 and 1.15 are still open from the previous candidate and carry over.

The next step is the checklist in [PHONE-CHECK-2026-08-19.md](PHONE-CHECK-2026-08-19.md) from step 2 onward: endpoint listening, transport and Finish feel, blinded direction trials, song-change causes, and lock, call, and route recovery. After that check, the next Main Thing is the 20-minute outdoor run.

Historical implementation detail lives in [PROGRESS.md](PROGRESS.md). Product choices live in [DECISIONS.md](DECISIONS.md). Exact checks and proof limits live in [TESTING.md](TESTING.md).
