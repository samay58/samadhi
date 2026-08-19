# Auto change interaction

## Status

The software half of this design exists as of 2026-08-18. The reducer owns one directional transaction per meaningful Auto change, `AutoFeedbackService` owns the Core Haptics engine in the app shell, three prototype haptic families with paired arrival sounds are packaged, and a hidden Debug audition screen plays them by hand. The transport and Finish pass that used to block this work is complete in software.

The exact patterns, sound files, and intensity bands are not approved. Nothing here has been felt or heard on a phone. They stay prototypes until the physical comparison on the iPhone while moving and listening to music.

## What the workout exposed

The August 17 workout proved that Auto can sense a supported cadence, settle on a target, and receive a matching Apple Music speed reply. Samay felt the music changing. He did not understand the change as a deliberate Samadhi action.

That is an interaction failure, not only a tuning problem. The music changes without a clear beginning, direction, or arrival. A later difference in song speed tells the runner that something happened, but it does not make the moment feel intentional.

The workout mixed brisk incline walking, a short light jog, and substantial lifting. At the time the product rejected values below 120 steps per minute. The trace cannot tell which activity produced each low reading. Expanding Samadhi into rhythmic walking is a sound idea. Adapting music to lifting is not needed now because lifting has no continuous step rhythm for Auto to follow.

The retained diagnostic shows one confirmed song change. It does not say whether that boundary was natural or followed a user command. Current code may prepare a better next song, but it does not let Auto interrupt the current song. Do not describe this run as proof that Auto cut a song short.

## Why screen copy is wrong

The runner is usually not looking at the phone. A sentence on the run screen would arrive through the wrong sense, add visual clutter, and still fail when the phone is locked or in a pocket.

The normal run screen should not explain an Auto change with temporary text. Development diagnostics should keep the detailed numbers. The product should make the change understandable through touch and sound.

One line is allowed, and it is not about an Auto change. When most of the ready collection cannot reach the settled target inside the rate window for twenty seconds, the run screen says so once per run per direction, in plain words ("Most of this playlist is faster than you're moving."), and takes it down on its own. That names the collection, not a change, and it answers the August 19 walk, where Auto held 0.85 for most of seven minutes with nothing said.

## Interaction decision

Treat one meaningful Auto change as one identified transaction with a start, direction, size, and verified arrival.

### Change begins

After the first Apple Music reply confirms that the music has started moving toward the newly committed target, play one short directional haptic.

- Faster uses a rising tactile shape: a light pulse followed by a firmer pulse.
- Slower uses a falling tactile shape: a firmer pulse followed by a softer, slightly longer release.
- Direction comes from timing and shape, not strength alone.
- Size uses no more than three coarse strength levels. The pulse order stays unchanged so the learned meaning stays stable.
- The size level reflects the reachable change in running pulse calculated from analyzed song tempo and Apple Music's reported speed, not a noisy sensor reading or an unreachable request.

The first prototype bands are 6 through 9, 10 through 15, and 16 or more steps per minute. These are starting points only. The current Auto policy already ignores changes below 6 steps per minute. Physical testing may move the boundaries.

The August 19 walk put a question on the bands before any comparison has run. At walking cadence on a 120 BPM song, a 5 percent speed change is 6 steps per minute: the smallest band, so the weakest cue, and the change hardest to hear in the music. The one Auto change the record shows on a fitting song (Numb, 0.95 to 0.90) was exactly that case, and Samay could not tell whether anything had happened. The first question for the physical comparison is therefore whether the smallest change needs the strongest start cue, not the weakest, because it is the one the music itself will not announce. The audition screen already separates size from direction, so the A/B is a small-band cue played at the medium intensity against the same change; no extra control is needed for it.

### Change arrives

After Apple Music reports the final intended speed for the current song and request, play one quiet authored sound paired with a soft terminal haptic.

Use a two-member sound family. Faster and slower share the same material and restraint, but their short tonal or textural movement points in opposite directions. This gives headphones and touch the same meaning without copying a stock notification sound.

Do not play the arrival for:

- a raw or filtered cadence update;
- a possible target that Auto is still considering;
- each intermediate speed step;
- a pending, mismatched, rejected, or stale Apple Music reply;
- a repeated target;
- a user-requested Skip or Previous by itself.

A truthful song limit may receive the arrival only when the app intentionally chose that nearest reachable result and Apple Music verified it. A rejection gets no success sound.

### Song boundaries

Record why a song changed before adding feedback to the boundary.

Since 2026-08-19 the reducer also looks ahead. Inside the last 45 seconds of a song it judges the queued next song against the settled Auto target; if that song cannot reach the target inside the rate window and something in the ready collection can, one better fit is prepared for the boundary, and a plan that still fits is kept rather than traded for a marginally better one. This is the same prepared-song path the boundary already had; it only starts earlier and judges the next song rather than the current one.

- A user-requested Skip or Previous already has a direct cause. Do not cover it with an Auto story.
- A natural boundary that uses a previously prepared better-fitting song may use the Auto arrival after the new song and its speed are confirmed.
- A late reply from the old song must never trigger either part of the new song's feedback.

## Why this shape is stronger

A completion sound alone comes too late to explain a multi-second speed ramp. A haptic at the first verified movement says that Samadhi has begun acting. The authored arrival says the change completed. Both events remain tied to something Apple Music actually did.

Haptics alone are not enough. The phone may be loose in a pocket, held differently, or unable to play a custom pattern. Apple also treats haptics as optional feedback. The paired sound carries the same direction through headphones. The haptic carries it when the sound is hard to hear.

This feedback cannot repair an overactive Auto policy. Auto must still favor a broad, stable match over small corrections. If target commits happen too often, fix the target policy rather than muting or weakening the cues.

## Core Haptics findings

Core Haptics is the right prototype tool because it can combine transient and continuous events, control intensity and sharpness, and schedule custom audio with haptics in one pattern. Apple recommends clear cause, harmony across senses, short patterns for discrete events, restrained use, and an option to disable haptics.

AHAP files are the best working format for the directional family. They keep timing and parameter choices inspectable, versioned, and easy to compare with Quick Look. Programmatic patterns remain appropriate for the live wheel detents.

The wheel detent shell was not enough for this job, so `AutoFeedbackService` was added beside it:

- it starts one engine lazily on the first cue, not when the tempo wheel opens;
- its engine allows audio events, so a Core Haptics pattern can carry the arrival sound;
- it keeps both a stopped handler and a reset handler, and turns automatic shutdown off;
- its reset handler restarts the engine, drops cached players, and registers the audio resources again;
- an identified Apple Music reply now reaches it as a reducer effect and plays the matching cue.

The reducer owns the one-time trigger and all song and request identities. SwiftUI never decides when an Auto cue is valid. The service is idempotent for each transaction and moment, cancels one transaction or every pending cue on demand, and stays silent on hardware without haptics while the sound still plays through a local audio player.

### Delivery record

Sending a cue is not playing one. The August 19 walk sent five start cues and three arrivals and could not say whether a single one reached the hand. Since 2026-08-19 every cue the service handles reports one outcome back to the shell with its transaction identifier, moment, family, and sound path:

- played through the engine: the haptic engine accepted the pattern and started it, with the arrival sound inside the pattern or through the local player as noted;
- played local sound only: no engine, so the arrival sound went through the local player and no haptic happened;
- engine unavailable: no haptic hardware, an engine that would not start, or a pattern the engine refused to start, with the reason;
- pattern missing: the asset did not resolve or did not parse;
- cancelled before play: an arrival still held behind its own start when a rule ended the transaction.

The engine reports its own lifecycle the same way: created, started, start failed, stopped with Apple's reason, reset, unsupported. Debug builds write every one of these into the run record as `autoFeedbackDelivery` and `hapticEngine` entries and show the last three cue outcomes on the hidden Debug screen. "Played" still says nothing about whether a pocket could feel it; that remains a physical judgment.

Apple documents that the haptic engine can stop after an audio interruption or app suspension. Samadhi uses background audio, but that does not prove custom haptics survive phone lock in this app. The phone-lock case is a required test, not an assumption.

References:

- [Apple Human Interface Guidelines: Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
- [Apple: Practice audio haptic design](https://developer.apple.com/videos/play/wwdc2021/10278/)
- [Apple: Preparing your app to play haptics](https://developer.apple.com/documentation/corehaptics/preparing-your-app-to-play-haptics)
- [Apple: Playing a custom haptic pattern from a file](https://developer.apple.com/documentation/corehaptics/playing-a-custom-haptic-pattern-from-a-file)

## Prototype and selection

Create three coherent families, not a large pile of weak options. Each family includes faster, slower, and three size levels plus its paired arrival sound.

The sound may come from a commissioned sound designer, original recording or synthesis, a licensed library asset that is substantially shaped for Samadhi, or offline generation used as sketch material. A generated first pass is not a finished asset. Preserve the source, rights, raw file, processing notes, and checksum for every finalist.

The preferred final path is a small paid commission from an interaction sound designer using this brief and the physical prototype. ElevenLabs is useful for exploring material and vocabulary, not as the automatic source of the shipped sound.

### What exists in software

Three families are packaged under `Resources/AutoFeedback/<family>/`. `pulse` is two transients: a light anchor then a firmer, sharper pulse for faster, and a firm anchor then a softer, longer release for slower. `swell` is one continuous event whose intensity and sharpness climb for faster and fall for slower. `step` is three transients with tightening gaps and rising weight for faster, widening gaps and falling weight for slower. Each family carries both directions across three size bands, plus one soft terminal arrival pattern per direction, which is 24 AHAP files in total. Size scales peak intensity only, at 0.45, 0.65, and 0.95, and never reorders events. Start spans run from 0.160 to 0.240 seconds.

The six arrival sounds are 48 kHz, mono, 16-bit, from 0.310 to 0.375 seconds. Each peaks at exactly -9.00 dBFS with RMS from -17.3 to -21.0 dBFS, so none of them clips. Parameters and SHA-256 for every file live in `Evidence/Audio/2026-08-18-auto-feedback-prototypes/sound-manifest.json`.

Both sound paths are built and selectable at runtime: Core Haptics audio, where the sound is registered as an audio resource and played inside the pattern, and a local audio player holding a preloaded file. The phone comparison picks one.

The audition screen is Debug only. It reaches the app through the `--feedback-audition` launch argument and the `Samadhi Feedback Audition` scheme. It offers family, direction, size, sound path, and separate sound and haptic toggles; buttons to play the start, the arrival, or both; and a 10-trial blinded mode with a visible seed and a copyable summary line carrying family, sound path, seed, and score. Release contains none of its strings or symbols.

Test both Core Haptics custom audio and a small local audio player alongside real Apple Music. Choose from physical results. The implementation must not pause, duck, restart, or reroute the music, and the first cue must not arrive late.

## Physical acceptance

Use the paired iPhone in the normal pocket position with the screen on, screen locked, iPhone speaker, and primary Bluetooth headphones.

Pass only when:

- Samay identifies faster versus slower without looking in at least 8 of 10 blinded trials;
- the three size levels read as increasing strength without changing the learned direction;
- one meaningful change produces one beginning and one arrival, with no extra events during the ramp;
- twenty mixed changes do not feel annoying or alarming;
- the sound remains audible but secondary across at least five representative songs;
- music never ducks, pauses, gaps, or changes route;
- interruption and engine recovery do not replay an old cue;
- the experience remains understandable with either sound or haptics disabled;
- Samay chooses the final family on the physical phone.

No Simulator result can approve tactile quality, pocket recognition, sound quality, or Apple Music coexistence.

## Priority

The transport and Finish pass is complete in software, and so is the first prototype of this feature. The next step is the physical comparison in the Physical acceptance section above, run from the checklist in [PHONE-CHECK-2026-08-19.md](PHONE-CHECK-2026-08-19.md).

Nothing in the prototype set becomes a product asset before that comparison chooses a family, a size scale, and a sound path. Setup, summary, icon, warehouse, and playlist-generation expansion all stay behind it.
