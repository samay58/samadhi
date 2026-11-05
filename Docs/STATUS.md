# Current status

Last checked: 2026-11-05.

The app is one good walk short of knowing whether its August repairs and the November design work hold up. The phone has version 1.3, build 8, recorded in `Evidence/Device/2026-11-05-install-1.3/`. It shows the name Slipstream, which the product now uses, while the code and bundle keep the name Samadhi. Its signing profile expires on 2026-11-09 at 9:18 PM Eastern, and the app will not open after that until a fresh one is installed over it.

The November sweep fixed recovery dead ends and several timing bugs, and the design refresh changed setup and the run screens, including a Liquid Glass tempo wheel drawn as a speaker. All of that is installed, and none of it has been walked or run on. The next step is one walk. The November 5 color pass and the rename are on the phone too, and neither has been walked or run on. An unfinished 10-minute run from October 26 was pulled from the phone and has not been read yet.

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
| Tempo wheel | The wheel is a speaker driver under a clear glass lens. The cone and center cap push forward at the music's current tempo while the surround stays still. The pulse is not lined up with the song's individual beats, because analysis measures tempo and not beat positions. The center cap turns lime once the tempo has matched. It has a quiet close action with its own 44-point target | Interface tests and inspected Simulator frames |
| Color and appearance | The palette is Phoenix Workbench lime and lilac on paper or near-black. Setup, recovery, and the summary follow the system appearance, and the run screens are always dark. The product is now Slipstream, and `Scripts/render-icon.py` draws its icon, a lilac sphere on lime lines, which Samay approved on his phone. Lime in sun is unjudged | `PaletteContrastTests`, direct drawing of 16 screens in both appearances, and real Simulator frames in `Evidence/Simulator/2026-11-05-color-refresh/` |
| Transport and Finish | Previous, Pause or Resume, and Next are three interactive Liquid Glass circles, the primary larger and tinted. Finish is a quiet button below them that arms a hold drawn inside its own capsule | Serial interface tests, including two that fail if Pause or Finish moves when it changes state, and the sheets in `Evidence/Simulator/2026-11-05-color-refresh/`. Feel on the phone is open |
| Reading a playlist | Each song read draws one contour line shaped by its measured tempo and plucks the progress string. The field's color comes up with the count of songs read, and the song, tempo, and count pass in one centered stack | Unit tests for the map and the warmth, interface tests, and inspected frames and video from the Simulator. An invented playlist was read one song at a time, so real import pacing and frame rate on a phone are open |
| Auto feedback | The reducer owns one directional transaction per meaningful Auto change. Three prototype haptic families, six arrival sounds, and a hidden audition screen exist. Every cue reports what became of it | Domain, app-model, and asset tests. Nothing about feel or sound is physically proved |
| Song crossfade | Songs change through Apple Music's built-in crossfade, set to four seconds. It softens the break without aligning beats | Compiles against the SDK. No software test can hear it, and it has not been heard on a phone |
| Song boundaries | In the last 45 seconds of a song the reducer judges the queued next song against the settled target and prepares one better fit when it cannot follow | Reducer tests. Not yet seen at a real boundary on the phone |
| Reach | When fewer than a quarter of the ready songs can reach the settled target for twenty seconds, the run screen says so once per run per direction | Reducer tests and direct drawing in every environment |
| Recovery | Each audio recovery names its cause: headphones, an interruption, or Apple Music failing. Only the matching event clears it, and every recovery can end the run | Reducer tests, an interface test, and an inspected Simulator frame. Not yet seen on the phone |
| Run record | Each run is one file that only grows, holding every input, every state change, pedometer steps, distance, and pace, and the phone's conditions. The phone keeps the newest 60 and `phone.sh pull` keeps every run on the Mac with a ledger across runs. `RunReplay` puts any recorded run through today's logic | Store, replay, and long-run tests, and a recorded Simulator run that replayed with no differences. No walk has been recorded in this form yet |
| Song-change cause | Every confirmed song change records natural end, outside change, or explicit Previous or Next | Attribution tests and the Debug row `Last song change` |
| Release isolation | Neither the hidden Debug screen nor the audition screen ships in Release | Release binary strings and symbol counts |

## What the phone has proved

The August 17 workout came from an exact-profile build with a matching source fingerprint. Delayed cadence readings acquired 133 SPM, and Apple Music reported the requested 1.0390625 after 0.066 seconds. Samay felt Auto changing the music, and the changes felt jarring and unexplained. The workout mixed walking, light jogging, and lifting, so it does not tune walking.

The August 19 brisk walk ran for 441 seconds at an average of 113 SPM on the analyzer version 5 build. Auto settled once and wrote 0.90. A natural boundary landed on a 163.75 BPM song the walk could not reach. Only 7 of 41 ready songs can reach a walking cadence inside the rate window, so Auto held the floor for most of the walk. Samay felt perhaps one haptic and could not tell when a change happened. The analysis is in `Evidence/Device/2026-08-19-walk-easy-miles/`.

That walk exposed four software gaps: a lossy record, no proof that cues played, no look-ahead at song boundaries, and nothing said about a playlist out of reach. All four were repaired in commit `0aa99a7`. See `Evidence/Device/2026-08-19-walk-repair-install/`.

## Current software gate

Run `./Scripts/gate.sh`. The result of the latest run is recorded in [TESTING.md](TESTING.md).

## Still open

All of these need a body, an ear, or real Apple Music. [PHONE-CHECK.md](PHONE-CHECK.md) orders them.

- Walk Easy Miles on this build for at least ten minutes, pocketed, partly locked, then pull and read the record.
- Hear 0.85 and 1.15 through headphones for a full musical section, and read back what Apple Music reports.
- Judge transport and Finish by hand.
- Run the blinded faster and slower trials for all three haptic families on both sound paths.
- Judge the glass and the speaker's beat pump on a real screen, and measure frame rate there, because the Simulator only approximates glass and its drawing costs differ from a phone's.
- Hear the crossfade at a natural song change, and confirm `Last song change` after a natural end and after an explicit Next.
- Check screen lock, an interruption, and route recovery.
- Run a clean walking-only check. The 90 SPM floor and five-second delay are software choices, not tuned constants.
- Complete one 20-minute outdoor run.

Implementation history lives in [PROGRESS.md](PROGRESS.md). Product choices live in [DECISIONS.md](DECISIONS.md). Exact checks and proof limits live in [TESTING.md](TESTING.md).
