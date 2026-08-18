# Handoff verification

## Preserved source

| Check | Result |
| --- | --- |
| Source size | 72,940 bytes |
| Source lines | 1,841 |
| SHA-256 | `a69a0d6d51213ff6d435f0bbf56205f1140702cc39b2aedcaeb3da8cd0a7b315` |
| Byte comparison | Passed |
| Original modified | No |
| Button-craft addendum preserved | Yes, as a separate immutable file |
| Workout-feedback addendum preserved | Yes, as a separate immutable file |
| Transition-haptics addendum preserved | Yes, as a separate immutable file |
| Workout-context correction preserved | Yes, as a separate immutable file |

## Repository and environment

| Check | Result |
| --- | --- |
| Fresh `origin/main` | `4f5394f3158dde9ad891b8b772b197c4c26090b2` |
| Local `main` | Same SHA |
| User-owned dirty files preserved | Yes |
| Xcode | 27.0, build `27A5209h` |
| XcodeGen | 2.45.4 |
| Swift | 6.4 |
| Simulator | iPhone 17 Pro, iOS 27.0, booted |
| Physical iPhone | Paired and available |
| Installed Samadhi | Version 1.0, build 1 |
| Baseline build record | Base commit `4f5394f3158dde9ad891b8b772b197c4c26090b2`, tracked dirty state, build time, and a deterministic source fingerprint |
| Fresh physical build | Passed |
| Fresh provisioning | Exact profile `Samadhi Development 2026-08-15` for `ZL5U59XBJ6.com.samaydhawan.Samadhi` |
| Physical install performed | Yes, in place without deleting app data |
| Selected collection | SHA-256 unchanged before and after install |

## Software checks

| Check | Result |
| --- | --- |
| `./Scripts/bootstrap.sh` | Passed |
| Swift formatter lint | Passed |
| Swift package tests | 153 passed |
| App-model tests | 27 passed |
| UI tests | 28 passed |
| Full serial test set | Passed |
| Signed physical-destination build | Passed mechanically |
| Resource-inclusive Debug Simulator build | Passed |
| Resource-inclusive Release Simulator build | Passed |
| Hidden Debug screen | Passed at normal text, accessibility XXXL, and Reduce Motion |
| Normal Release interface | Hidden Debug screen excluded |

The exact profile has UUID `1b613344-c5cd-4802-a31f-9ff5088c1802` and expires August 15, 2027. The embedded profile and the app signature both use `ZL5U59XBJ6.com.samaydhawan.Samadhi`.

The expanded-rate candidate records source fingerprint `fd8120ad2ac14e1090a687438e6564beb65bde0a61d58fab04d4ec7295535684`. It was installed over the existing app. The selected collection stayed byte-for-byte unchanged at SHA-256 `81a9b31fbc115d607bc766dd25374ecff6874b079276b68c3719cb122cea3f52`. The phone locked when launch was attempted, so in-app identity, endpoint Apple Music read-back, physical walking, and listening remain open.

## Review artifacts

- `MANIFEST.md`: exact-source receipt.
- `MAP.md`: product, architecture, dependency, conflict, and proof map.
- `WORKPLAN.md`: Phase 0 work items and later gated phases.
- `Docs/CORE-RESET-ADVERSARIAL-REVIEW.md`: H-001 through H-020 verdicts and current code traces.

## What is proved

- The current repository and software baseline are healthy.
- The phone is reachable from this Mac.
- Manual now belongs to one confirmed song. It survives same-song pause and route recovery, then returns to Auto only after the player confirms a different song.
- Responsive cadence and the settled Auto target are separate policies.
- The run surface mixes cadence-like and musical values under BPM language.
- The tempo editor has an explicit accessible close action that restores playback controls without changing rhythm or playback.
- Existing diagnostics already contain most of the numerical tempo chain.
- Every new build records its base commit, branch state, build date, app version, and build number.
- The hidden Debug screen separates musical BPM from step rhythm in SPM.
- Waiting, verified, song-limited, and rejected Apple Music results are distinct.
- A confirmed new song clears the prior song's read-back and requires a fresh reply.
- One baseline phone run captured 16 numeric cadence readings from 151.56 to 158.10 SPM and real Apple Music replies in about 0.04 to 0.07 seconds.
- Fourteen readings were about 2.57 seconds old and failed the old 2.0-second freshness rule. The saved pattern then acquired in deterministic replay because advancing Core Motion timestamps prove that each delayed reading is new. That replay alone did not prove the repair on the phone.
- The fingerprinted August 17 workout physically confirmed that repair. Four supported delayed readings acquired 133 SPM. Apple Music reported the exact 1.0390625 command after 0.066 seconds.
- The same workout retained 61 numeric cadence readings. Fifty-seven were below the current 120 SPM running range. The workout mixed brisk walking, light jogging, and lifting, so the trace cannot assign every low reading to walking.
- Samay felt Auto changing the music. He judged the transitions jarring and unexplained. This proves a product feedback problem, not the final cause or solution quality.
- The app counted 5 minutes 28 seconds. The larger 30-minute period included substantial lifting, so it is not valid evidence that the summary omitted a specific amount of rhythmic movement.
- The source fingerprint changes for covered source, configuration, resources, and build scripts, stays stable when those inputs do not change, and returns to its prior value after a revert.
- The close action retains a 44-point touch target, no longer covers the dial, and stays quiet at normal text, accessibility XXXL with Reduce Motion, and Increased Contrast.
- The importer is typed and bounded, but not yet a complete failure census.
- The installed SDK supports the MusicKit and Core Motion capabilities relied on by the handoff.

## Current behavior recorded by tests

| Case | Current behavior |
| --- | --- |
| 84 BPM song with two steps per beat | Kept as 84 musical BPM and 168 running SPM. The two values are never relabeled as each other. |
| Auto to Manual | Manual takes control and starts from the current reachable rhythm. |
| Manual to Auto | Auto returns to its neutral correction and uses the sensed cadence again. |
| Manual, then Skip | Manual remains active. Skip requests a player change; the app waits for the player to confirm the new song. |
| Manual, then confirmed different song | Manual returns to Auto only after the player confirms the different song. |
| Manual, then same-song confirmation | Manual remains active and keeps its current read-back. |
| Lower and upper song limits | Manual stops at the current song's reachable boundary. It does not silently select another song. |
| Tempo wheel close | The visible close action restores playback controls immediately without pausing, skipping, changing rhythm, or resetting Manual. |
| Steady running rhythm | Stable readings lock, and requested music speeds stay within the allowed range. |
| One false spike | The spike is ignored. |
| Sustained faster rhythm | The smoothed reading follows most of the change within three seconds. |
| Sustained slower rhythm | The smoothed reading follows most of the change within three seconds. |
| Steady brisk walking | Values from 90 through 119 SPM can settle after five seconds of steady evidence and use the bounded music-speed path. |
| Broken lifting-like movement | Disagreeing values and missing readings cannot accumulate a walking target. |
| Raw cadence before Auto settles | The song stays at its current speed until the separate Auto target has enough evidence. |
| Approximate match | Five SPM of remaining error is accepted; six SPM is rejected. The software candidate remains inside 0.85 through 1.15. |
| Delayed Apple Music reply | The matching reply is accepted and its 1.75-second delay is retained. |
| Mismatched Apple Music reply | The change is marked rejected and the response time is retained. |
| Route loss during Manual | Playback pauses. Manual remains active through explicit recovery. |
| Pause and resume during Manual | Manual remains active and cadence is reacquired. |
| Confirmed new song | Old reply, response time, and result are cleared. A fresh reply is required even when the requested speed number matches. |

## What is not proved

- Current-main physical reproduction of every complaint.
- Representative-track analyzer accuracy.
- The dominant causes of import failure.
- Five-track, two-route playback quality.
- Clean sound and stable Apple Music read-back at the 0.85 and 1.15 candidate endpoints.
- Current wheel, setup, summary, and icon taste.
- Transport and Finish visual craft, including the reported Finish border overflow, pressed response, and physical feel.
- Natural prepared transition reliability.
- Locked-screen, interruption, and route-loss reliability.
- The final settled Auto policy across sustained running, walking, and repeated pace changes.
- Directional Auto haptic patterns, completion sound, playback mechanism, screen-lock delivery, or physical feel.
- Whether the 90 SPM walking floor and five-second delay feel right on the phone.
- Whether a clean locomotion-only run exposes a real elapsed-duration problem.
- A 20-minute outdoor run.

## Current work state

- P0-00 preserve handoff: complete.
- P0-01 fingerprint environment: complete, including exact provisioning and installed app version.
- P0-02 software baseline: complete.
- P0-03 adversarial review: complete.
- P0-04 build record: complete in software, Simulator, signed installation, and the pulled fingerprinted workout file.
- P0-05 numerical Debug explanation: complete in software and Simulator, with two real-phone traces.
- P0-06 baseline matrix: deterministic software and Simulator complete, with repaired acquisition and one exact Apple Music response confirmed physically. Known-cause song boundaries, haptics, broader listening, and sustained running remain open.
- P0-07 disagreement corpus: pending.
- P0-08 import census: pending.
- P0-09 Phase 0 close: pending.
