# Walk with Easy Miles, 2026-08-19

Real phone, real Apple Music, build `294981e` (source fingerprint `55438218…`, analyzer version 5). Collection `Easy Miles`, 41 of 48 ready. File pulled from the app container at 14:57 local; `run-analysis.json` is the parsed summary; the raw `latest-run-diagnostics.json` sits beside it locally and is ignored by git like every other raw run file. Samay's report, in his words: haptics came maybe once the entire session; one song was fine-tuned about six times in a row and the next one barely moved; registering that a change has happened is hard when he cannot be sure one did.

## What the record shows

- 441 active seconds, 420 automatic, 21 manual, 6 songs. Average cadence 113 steps per minute, visible range 108 to 115. This was a brisk walk, not a jog.
- Tempo matched 67 percent of the time. Only 7 of the 41 ready songs can reach 108 steps per minute inside the 0.85 to 1.15 rate window (Bermuda, Booty La La, Black Classical Music, Inner Light, Baby, Cola, Numb). Easy Miles was built for light jogging; at walking cadence most of it is physically out of reach and Auto pins the rate at 0.85 and reports `atLimit`.
- The timeline holds 512 entries. The first 205 active seconds, one whole song, and any Auto changes inside them fell off the front of the buffer. The visible window starts 103 seconds into Numb, and the summary's song count of 6 leaves room for exactly one song before it. That song was collection index 0, and Numb is index 39 while the song after Numb was index 1: the only queue that produces that order is a better-fit Numb prepared during the first song and slotted in after it, with the queue then resuming from index 1. The "six times in a row" song is not in the record.
- Visible Auto behaviour: Numb held 0.95 for at least 67 seconds, cadence dropped 114 to 108, target settled at 108 after a 5 second `considering` window, one rate write to 0.90. That was the only Auto-initiated change in the visible window.
- Natural boundary at 402 seconds moved from Numb to Nightrider (163.75 BPM). At 109 steps per minute that song needs 0.67; it was pinned at 0.85 and limited from its first second. No better next song was prepared because the app only plans a transition while the current song is at its limit, and Numb was not.
- Samay skipped to WEIGHT OFF (159.75, also limited), skipped to Bermuda (120.25, fits at 0.87), then Previous back to WEIGHT OFF. From 414 to 442 seconds he tapped Manual and Auto nine times and turned the wheel three times (159, 150, 154). The 15 rate writes on WEIGHT OFF are those actions plus Auto ramping back to 0.85 after each Auto tap. Each Manual tap restarted from the current rate, not from his last turned target.
- Route lost at 506 seconds, restored at 1426, resume, pause, finish. Nothing after the route loss is a run.

## Feedback cues the reducer emitted

| Transaction | Song | Direction, size | Started | Arrived | Cancelled by |
| --- | --- | --- | --- | --- | --- |
| 3 | Numb | slower, small (6 SPM) | 336.0 | 336.0 | |
| 4 | Nightrider | slower, small, limited | 402.3 | 402.5 | |
| 5 | Bermuda | faster, small | 411.5 | | Previous at 412.5 |
| 6 | WEIGHT OFF | slower, large, limited | 421.2 | | Manual tap at 422.4 |
| 7 | WEIGHT OFF | slower, medium, limited | 429.0 | | Manual tap at 431.4 |
| 8 | WEIGHT OFF | slower, large, limited | 442.2 | 446.0 | |

Five start cues and three arrivals were sent to the feedback service in the visible window. Transactions 3 and 4 started and arrived within 0.4 seconds, so each would be felt as one event. The file does not say whether any cue physically played: the service does not report engine state, a failed start, or a fallback to the local sound player into the diagnostics. Whether the haptic engine was running, which route the arrival sound took, and whether the screen was on are unknown.

## Gaps this run exposes

1. The diagnostics buffer evicts the oldest entries regardless of kind. Per-second ticks should go first; song changes, rate writes, mode changes, and feedback cues should survive a whole run. (Repaired the same day: schema 11 keeps the story of the run and drops ticks first.)
2. A cue has no delivery record. The service must log played, engine unavailable, start failed, or fallback sound, with the transaction identifier. (Repaired the same day: every handled cue now writes an `autoFeedbackDelivery` entry and the engine writes `hapticEngine` entries.)
3. Natural boundaries have no look-ahead. When the next queued song cannot reach the settled target, a fitting song should be prepared before the boundary, not five seconds after the music has already pinned at the limit. (Repaired the same day: inside the last 45 seconds of a song the reducer judges the queued song against the settled target and prepares one fit if it cannot follow.)
4. At walking cadence with a jogging playlist, most songs are out of reach. Samadhi should say so once, plainly, rather than holding 0.85 and reporting `atLimit` second after second. (Repaired the same day: one line, once per run per direction, after twenty held seconds with fewer than a quarter of the ready songs reachable.)
5. A 5 percent change on a 120 BPM song is 6 BPM. It is the smallest band, so it gets the weakest cue. Whether small changes need the strongest cue, not the weakest, is a design question for the physical comparison.
6. Manual restarts from the current rate instead of the last turned target. Whether that is wanted is his call.

No claim is made here about feel, sound, ducking, route, or lock screen.
