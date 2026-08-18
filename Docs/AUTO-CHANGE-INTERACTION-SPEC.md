# Auto change interaction

## Status

This is the accepted design direction, not the current Main Thing. It should be built only after the core matching and walking-range decisions are settled and the transport and Finish craft pass is complete.

The exact patterns, sound files, and intensity values are not approved yet. They require physical comparison on the iPhone while moving and listening to music.

## What the workout exposed

The August 17 workout proved that Auto can sense a supported cadence, settle on a target, and receive a matching Apple Music speed reply. Samay felt the music changing. He did not understand the change as a deliberate Samadhi action.

That is an interaction failure, not only a tuning problem. The music changes without a clear beginning, direction, or arrival. A later difference in song speed tells the runner that something happened, but it does not make the moment feel intentional.

The workout mixed brisk incline walking, a short light jog, and substantial lifting. The current product rejects values below 120 steps per minute. The trace cannot tell which activity produced each low reading. Expanding Samadhi into rhythmic walking is a sound idea. Adapting music to lifting is not needed now because lifting has no continuous step rhythm for Auto to follow.

The retained diagnostic shows one confirmed song change. It does not say whether that boundary was natural or followed a user command. Current code may prepare a better next song, but it does not let Auto interrupt the current song. Do not describe this run as proof that Auto cut a song short.

## Why screen copy is wrong

The runner is usually not looking at the phone. A sentence on the run screen would arrive through the wrong sense, add visual clutter, and still fail when the phone is locked or in a pocket.

The normal run screen should not explain an Auto change with temporary text. Development diagnostics should keep the detailed numbers. The product should make the change understandable through touch and sound.

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

The current run haptic shell is not ready for this job:

- it starts the custom engine only when the tempo wheel opens;
- its engine is set to ignore audio events;
- it has no stop handler;
- its reset handler restarts the engine but does not recreate cached players or audio resources;
- Apple Music speed replies currently emit no Auto transition haptic.

The later implementation needs one app-shell service that can start lazily, recover from interruptions, recreate registered resources, and fall back safely. The reducer must own the one-time trigger and all song and request identities. SwiftUI must not decide when an Auto cue is valid.

Apple documents that the haptic engine can stop after an audio interruption or app suspension. Samadhi uses background audio, but that does not prove custom haptics survive phone lock in this app. The phone-lock case is a required test, not an assumption.

References:

- [Apple Human Interface Guidelines: Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
- [Apple: Practice audio haptic design](https://developer.apple.com/videos/play/wwdc2021/10278/)
- [Apple: Preparing your app to play haptics](https://developer.apple.com/documentation/corehaptics/preparing-your-app-to-play-haptics)
- [Apple: Playing a custom haptic pattern from a file](https://developer.apple.com/documentation/corehaptics/playing-a-custom-haptic-pattern-from-a-file)

## Prototype and selection

Create three polished families, not a large pile of weak options. Each family includes faster, slower, and three size levels plus its paired arrival sound.

The sound may come from a commissioned sound designer, original recording or synthesis, a licensed library asset that is substantially shaped for Samadhi, or offline generation used as sketch material. A generated first pass is not a finished asset. Preserve the source, rights, raw file, processing notes, and checksum for every finalist.

The preferred final path is a small paid commission from an interaction sound designer using this brief and the physical prototype. ElevenLabs is useful for exploring material and vocabulary, not as the automatic source of the shipped sound.

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

Do not build this next.

First settle the core evidence exposed by the workout: how far into brisk walking Samadhi should reach and what approximate alignment should count as good. Do not tune Auto for lifting. Then complete the transport and Finish craft pass. Build this directional Auto feedback before setup, summary, icon, warehouse, or playlist-generation expansion.
