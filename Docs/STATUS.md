# Current status

## Product state

| Area | Current truth | Proof |
| --- | --- | --- |
| Music source | Apple Music is selected | Authorization, catalog access, preview decoding, playback, and rate writes passed on iPhone |
| Music import | One playlist can be selected, analyzed locally, restored, retried, and filtered to ready tracks. Library songs resolve through their own catalog identifier first, and an explicit versus clean tie picks the edit in the playlist instead of dropping the song | Automated tests, Simulator frames, and prior phone import. The tie fix is not yet proved on the phone |
| Tempo analysis | Version 5 keeps musical BPM separate from the supported step relationship and judges a tempo with its half or double, so swung and dotted grooves keep their true beat instead of a subdivision lag | 12 of 12 public preview references, 20 deterministic tests including swing and dotted-eighth cases, and a 138-song read of the phone's cache in which every changed answer matched a public BPM listing |
| Motion | Steady readings from 90 through 210 SPM are accepted; walking needs longer evidence | Saved phone replay, deterministic stale-data rejection, and one attributed workout |
| Auto | A responsive sensor estimate feeds a separate calm musical target | Noise, spike, faster, slower, missing-input, and walking tests |
| Manual | Manual stays with the confirmed song and returns to Auto only after a different song is confirmed | Reducer, app-model, and interface tests |
| Playback range | The software candidate is 0.85 through 1.15 | Shared limits and endpoint tests across Auto, Manual, track fit, diagnostics, and player commands |
| Tempo wheel | The wheel has a quiet close action with a separate 44-point touch target | Interface tests and inspected Simulator frames |
| Transport and Finish | Previous, Pause or Resume, and Next are three separate interactive Liquid Glass circles, the primary one larger and tinted, each compressing on a spring when pressed. Finish is a quiet hairline button below the row that arms a hold whose fill is drawn inside the pill and clipped by its own capsule | Serial interface tests and fresh Simulator frames under `Evidence/Simulator/2026-08-19-transport-glass/` covering five environments; the earlier capsule bar and its hold contact sheets remain under the 2026-08-18 folder |
| Auto feedback | The reducer owns one directional transaction per meaningful Auto change. Three prototype haptic families, six arrival sounds, and a hidden audition screen exist in the app. Every cue the service handles now reports what became of it, and the haptic engine reports its lifecycle, into the run record | Domain, app-model, and packaged-asset tests, plus a fake-factory test for each delivery outcome. Nothing about tactile feel, sound quality, or Apple Music coexistence is physically proved; "played" is the engine's word |
| Song boundaries | Inside the last 45 seconds of a song the reducer judges the queued next song against the settled Auto target and prepares one better fit when it cannot follow; a kept choice is not traded for a marginal one; Skip and Previous carry no plan | Reducer tests for the fitting, replaced, nothing-fits, window, anchor, and Skip cases. Not yet seen at a real boundary on the phone |
| Reach | When fewer than a quarter of the ready songs can reach the settled target for twenty seconds, the run screen says so once per run per direction in plain words, then takes the line down itself | Reducer one-shot tests and Simulator frames in four environments under `Evidence/Simulator/2026-08-19-out-of-reach/`. Whether a runner reads it is physical |
| Run record | 2,048 entries; per-second ticks are evicted first and the story of the run survives; schema 11 adds cue delivery, engine, next-song plan, and reach entries | A deterministic eviction test and a delivery-entry test. Under 3 MB for an hour |
| Song-change cause | Every confirmed song change records a cause: natural end, an outside change, or an explicit Previous or Next | Pure attribution tests, scripted Simulator boundary events, and the Debug row `Last song change` |
| Debug explanation | Debug builds show the exact source fingerprint, the full motion-to-music calculation, the Auto cue in flight, the next-song outlook, the last three cue outcomes, and the cause of the last song change | Build inspection, schema-version-11 diagnostic tests, and Simulator frames |
| Release isolation | Neither the hidden Debug screen nor the feedback audition screen ships in Release | Release binary strings and symbol counts read against the Debug dylib |

## What the phone has proved

The August 17 workout came from an exact-profile build with a matching source fingerprint. Four delayed but forward-moving cadence readings acquired 133 SPM. Apple Music received 1.0390625 and reported 1.0390625 after 0.066 seconds. This proves the repaired timing rule for that observed phone pattern.

Samay also felt Auto changing the music. The changes felt jarring and unexplained. The workout mixed walking, light jogging, and lifting, so it does not prove the best walking threshold or how much time belonged to each activity.

The current candidate from `main` at `67adf80` is installed over Samadhi 1.0 build 1 with exact signing. The selected collection stayed byte-for-byte unchanged at SHA-256 `51b4096cc3b2c29ae32d85290b5a9f72166460f23b130d818508f7507b4e8397`. The phone was unlocked, so the hidden Debug screen was read on the device: its source fingerprint `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6` equals the signed build. The new endpoints, the transport and Finish feel, the Auto cues, and the song-change causes have not produced an Apple Music reply, a listening result, or any physical judgment yet.

The analyzer version 5 build `294981e` ran a real 441-second brisk walk with Easy Miles on 2026-08-19, average cadence 113 steps per minute, and its diagnostic file was pulled and parsed under `Evidence/Device/2026-08-19-walk-easy-miles/`. The record proves Auto settled once on Numb and wrote 0.90, that a natural boundary landed on a 163.75 BPM song the walk could not reach, and that the reducer emitted five start cues and three arrivals in the visible window. It does not prove any cue physically played: that build's service wrote no delivery record, and its 512-entry buffer dropped the first 205 seconds and one song. Samay reported feeling perhaps one haptic and being unable to tell when a change happened. Only 7 of the 41 ready songs can reach a walking cadence inside the rate window, so Auto held the 0.85 floor for most of the walk.

The four software gaps that walk exposed are repaired on `main` as of later the same day and installed on the phone as commit `0aa99a7`, fingerprint `a05aaa3c...` (see the gate below). The repair build has not yet walked.

## Current software gate

- Project generation passed.
- Formatter lint passed.
- 193 Swift package tests passed.
- 48 app-model tests passed.
- 34 serial interface tests passed.
- Source-fingerprint tests passed.
- Resource-inclusive Debug and Release Simulator builds passed.
- The hidden Debug screen was absent from Release.
- The feedback audition screen was absent from Release. The Debug side of that check reads `Samadhi.app/Samadhi.debug.dylib`, because the Debug `Samadhi.app/Samadhi` is a launcher stub.
- Commit `67adf80` was built for the phone with exact profile `Samadhi Development 2026-08-15`, which expires August 15, 2027, installed in place on 2026-08-19, and read back on the device: in-app source fingerprint `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6`. The glass transport and catalog tie fix that followed it on the same day pass the same gate and were installed in place as commit `13e88bf` and read back on the phone's hidden Debug screen with source fingerprint `085e5fe7b0e080a19efe281bd69fa5ebaeab00e0d082bc64701cd03d98de4f82`, equal to the built Info.plist. Analyzer version 5 followed as commit `294981e`, installed in place with built fingerprint `55438218da031307a32d9e1fdb190ecf4a880571e17533d5436f19a81317f24b`; the phone was locked, so that build has no in-app read-back yet, and it will measure every song again on the next playlist choice or restore. The walk repair build followed as commit `0aa99a7`, built with the same exact profile after the gate above, installed in place on 2026-08-19 with built fingerprint `a05aaa3cc77a0df2e86f88754f38b03312226375c408940c881df79e0a3e709a` equal to `Scripts/source-fingerprint.sh`; the selected collection stayed byte-identical (`a51a8e4a...`); the phone was locked, so no in-app read-back yet. Record under `Evidence/Device/2026-08-19-walk-repair-install/`.
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
- Walk Easy Miles again on the repair build for at least ten minutes with the phone in the pocket and the screen locked part of the time, then pull the record: it should hold the whole walk, say which cues played and which found no engine, show a prepared song at any natural boundary the queue could not follow, and carry one reach notice. Whether the cues were felt is still the hand's to say.

## Where we left off

The transport and Finish pass, deterministic song-change causes, the first directional Auto feedback prototype, analyzer version 5, and the August 19 walk repairs (record, cue delivery, boundary look-ahead, reach line) are merged on `main`, pass the software gate, and are installed on the phone as commit `0aa99a7`; the last two builds have no in-app read-back because the phone was locked at install. Endpoint read-back and listening at 0.85 and 1.15 are still open from the previous candidate and carry over.

The next step is the same walk again on the repair build, so the complete record can say what the August 19 walk could not. After that, the checklist in [PHONE-CHECK-2026-08-19.md](PHONE-CHECK-2026-08-19.md) from step 2 onward: endpoint listening, transport and Finish feel, blinded direction trials, song-change causes, and lock, call, and route recovery. After that check, the next Main Thing is the 20-minute outdoor run.

Historical implementation detail lives in [PROGRESS.md](PROGRESS.md). Product choices live in [DECISIONS.md](DECISIONS.md). Exact checks and proof limits live in [TESTING.md](TESTING.md).
