# Phone check for August 19

Short, ordered, and explicit. Everything below is a body, ear, Bluetooth, lock-screen, or real Apple Music judgment that software cannot make. Each block names what to do, what counts, and where to write the result. Nothing here needs debugging; if a step fails, record it and move on.

Before starting: build the exact-profile candidate from the current `main`, confirm the embedded profile identifier is `ZL5U59XBJ6.com.samaydhawan.Samadhi`, install in place, and confirm the selected collection checksum is unchanged. Do not uninstall the app.

## 1. Launch and fingerprint (2 minutes)

- Open Samadhi, start a short run, open the hidden Debug screen, and read the source fingerprint. It must match the fingerprint of the signed build you inspected before installing. No fingerprint is recorded for this candidate yet, so write down the one you read.
- Result: match or mismatch. If mismatch, stop and rebuild.

## 2. Endpoint listening (10 minutes, headphones)

- Use the Debug endpoint controls on one song with a clear beat: play 0.90 and 1.10 first (the known pair), then 0.85 and 1.15, each for a full musical section.
- Record Apple Music read-back for 0.85 and 1.15 from the Debug screen (requested versus reported).
- Judge each endpoint: clean, slightly rough, or unusable. Say which song.
- Result goes to `Evidence/Device/2026-08-19-phone-check/README.md`.

## 3. Transport and Finish feel (5 minutes)

- With controls visible: press Pause, Resume, Previous, Next several times. Each Previous or Next should tick once; the song change follows only when Apple Music confirms it.
- Tap Finish, release early twice, then hold to completion once. The fill must never show outside the pill; early release must snap the fill back; completion must feel like one event.
- Repeat with the phone in the pocket position for Finish only (no accidental finish while walking for one minute with the screen on).
- Result: three words each (Pause, Resume, Previous, Next, Finish arm, hold, cancel, complete): good, off, or broken, plus one line if off.

## 4. Blinded faster or slower trials (10 minutes)

- Run the `Samadhi Feedback Audition` scheme from Xcode on the phone. Keep the Music app playing a real song in the background so ducking or gaps are audible.
- For each family (pulse, swell, step): run the 10-trial blinded mode with the phone in the pocket and headphones on. Tap Play cue, leave the phone in the pocket while it plays, and take it out only to answer. Do the set once on the `Core Haptics audio` path and once on the `Local audio player` path. Locked-screen delivery is step 6, not this one.
- Record family, sound path, seed, and score. Pass is 8 of 10 or better.
- Then play small, medium, and large for one direction in a row and say whether size reads as increasing strength without changing the felt direction.
- Note whether the music ducked, paused, gapped, or changed route at any cue.

## 5. Song boundary with a known cause (5 minutes)

- Start a normal run and let one song play out naturally. After the change, open the Debug screen and read `Last song change`. It should read `Natural end of the song`. Then use Next once and confirm it reads `Next requested here`.
- If either one reads `Changed outside Samadhi`, write down what happened just before the change.
- Result: both causes correct, or which one was wrong.

## 6. Lock screen, interruption, route (10 minutes)

- Lock the phone for two minutes during a run with Auto active. Music must continue; after the phone is opened again, the Debug screen must not show a stale or replayed Auto cue.
- Take or simulate a call, then end it. Samadhi should show the recovery screen and require an explicit resume; Manual (if set) must survive on the same song.
- Disconnect the headphones, reconnect, resume. Same expectations. Record whether the audio route came back cleanly.

## 7. Save

- Pull `latest-run-diagnostics.json` from the app container (see `Docs/DEVICE_RUNBOOK.md`) and copy it, plus notes, into `Evidence/Device/2026-08-19-phone-check/`.
- Write three lines at the top of that README: fingerprint, endpoint verdict, blinded score per family.

Nothing in this checklist should take more than about 45 minutes. If it does, stop and record where time went.
