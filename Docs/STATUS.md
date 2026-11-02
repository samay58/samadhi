# Current status

Last checked: 2026-11-02.

The app is one good walk short of knowing whether its August repairs work. The phone has the repair build, original commit `0aa99a7`. No walk on that build is recorded here, and the phone may hold a later run that has not been pulled.

The repository is now ahead of the phone. The November sweep fixed recovery dead ends and several timing bugs in software, and none of that has been installed or tried on a phone. The next step is one install, then one walk.

## Product state

| Area | Current truth | Proof |
| --- | --- | --- |
| Music source | Apple Music is the only production player | Authorization, catalog access, preview decoding, playback, and rate writes passed on iPhone |
| Music import | One playlist can be selected, analyzed locally, restored, retried, and filtered to ready tracks. Library songs resolve through their own catalog identifier first. An explicit versus clean tie picks the edit in the playlist | Automated tests, Simulator frames, and an earlier phone import. The tie fix is not yet proved on the phone |
| Tempo analysis | Version 5 keeps musical BPM separate from the step relationship and judges a tempo with its half or double, so swung and dotted grooves keep their true beat | 12 of 12 public preview references, deterministic tests, and a 138-song read of the phone's cache |
| Motion | Steady readings from 90 through 210 SPM are accepted. Walking needs five seconds of evidence | Saved phone replay, stale-data rejection tests, and one attributed workout |
| Auto | A responsive sensor estimate feeds a separate calm musical target | Noise, spike, faster, slower, missing-input, and walking tests |
| Manual | Manual stays with the confirmed song and returns to Auto after a different song is confirmed | Reducer, app-model, and interface tests |
| Playback range | The software candidate is 0.85 through 1.15. Only 0.90 and 1.10 have been heard | Shared limits and endpoint tests. Listening at the endpoints is open |
| Tempo wheel | The wheel has a quiet close action with its own 44-point target | Interface tests and inspected Simulator frames |
| Transport and Finish | Previous, Pause or Resume, and Next are three interactive Liquid Glass circles, the primary larger and tinted. Finish is a quiet button below them that arms a hold drawn inside its own capsule | Serial interface tests and frames in `Evidence/Simulator/2026-08-19-transport-glass/`. Feel on the phone is open |
| Auto feedback | The reducer owns one directional transaction per meaningful Auto change. Three prototype haptic families, six arrival sounds, and a hidden audition screen exist. Every cue reports what became of it | Domain, app-model, and asset tests. Nothing about feel or sound is physically proved |
| Song crossfade | Songs change through Apple Music's built-in crossfade, set to four seconds. It softens the break without aligning beats | Compiles against the SDK. No software test can hear it, and it has not been heard on a phone |
| Song boundaries | In the last 45 seconds of a song the reducer judges the queued next song against the settled target and prepares one better fit when it cannot follow | Reducer tests. Not yet seen at a real boundary on the phone |
| Reach | When fewer than a quarter of the ready songs can reach the settled target for twenty seconds, the run screen says so once per run per direction | Reducer tests and frames in `Evidence/Simulator/2026-08-19-out-of-reach/` |
| Recovery | Each audio recovery names its cause: headphones, an interruption, or Apple Music failing. Only the matching event clears it, and every recovery can end the run | Reducer tests, an interface test, and an inspected Simulator frame. Not yet seen on the phone |
| Run record | 2,048 entries. Per-second ticks are evicted first, so the story of the run survives. Schema 11 adds cue delivery, engine, next-song plan, and reach entries | Eviction and delivery tests. Under 3 MB for an hour |
| Song-change cause | Every confirmed song change records natural end, outside change, or explicit Previous or Next | Attribution tests and the Debug row `Last song change` |
| Release isolation | Neither the hidden Debug screen nor the audition screen ships in Release | Release binary strings and symbol counts |

## What the phone has proved

The August 17 workout came from an exact-profile build with a matching source fingerprint. Delayed cadence readings acquired 133 SPM, and Apple Music reported the requested 1.0390625 after 0.066 seconds. Samay felt Auto changing the music, and the changes felt jarring and unexplained. The workout mixed walking, light jogging, and lifting, so it does not tune walking.

The August 19 brisk walk ran for 441 seconds at an average of 113 SPM on the analyzer version 5 build. Auto settled once and wrote 0.90. A natural boundary landed on a 163.75 BPM song the walk could not reach. Only 7 of 41 ready songs can reach a walking cadence inside the rate window, so Auto held the floor for most of the walk. Samay felt perhaps one haptic and could not tell when a change happened. The analysis is in `Evidence/Device/2026-08-19-walk-easy-miles/`.

That walk exposed four software gaps: a lossy record, no proof that cues played, no look-ahead at song boundaries, and nothing said about a playlist out of reach. All four are repaired in commit `0aa99a7`, which is installed on the phone. See `Evidence/Device/2026-08-19-walk-repair-install/`.

## Current software gate

Run `./Scripts/gate.sh`. The result of the latest run is recorded in [TESTING.md](TESTING.md).

## Still open

All of these need a body, an ear, or real Apple Music. [PHONE-CHECK.md](PHONE-CHECK.md) orders them.

- Walk Easy Miles on the repair build for at least ten minutes, pocketed, partly locked, then pull and read the record.
- Hear 0.85 and 1.15 through headphones for a full musical section, and read back what Apple Music reports.
- Judge transport and Finish by hand.
- Run the blinded faster and slower trials for all three haptic families on both sound paths.
- Hear the crossfade at a natural song change, and confirm `Last song change` after a natural end and after an explicit Next.
- Check screen lock, an interruption, and route recovery.
- Run a clean walking-only check. The 90 SPM floor and five-second delay are software choices, not tuned constants.
- Complete one 20-minute outdoor run.

Implementation history lives in [PROGRESS.md](PROGRESS.md). Product choices live in [DECISIONS.md](DECISIONS.md). Exact checks and proof limits live in [TESTING.md](TESTING.md).
