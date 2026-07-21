# Felt synchronization playbook

Samadhi succeeds only when a runner can feel music and stride become one system. A changing BPM label or a correct playback-rate write is not enough. The product must create an audible change, a bodily lock, and evidence that those two experiences agree.

## Product position

Treat synchronization as three related mechanics:

- **Track fit** chooses a recording whose native pulse or half/double interpretation sits near the requested cadence. D-Jogger changed songs when a target stayed outside its empirically acceptable stretch range, and Spotify Running selected music by detected cadence rather than stretching every song. Sources: [D-Jogger implementation](https://backoffice.biblio.ugent.be/download/8551818/8551819), [Spotify Running](https://techcrunch.com/2015/05/20/spotify-for-runners/).
- **Tempo match** applies a bounded rate correction so the effective musical tempo approaches cadence. Small 1 to 3 percent changes can influence running even when listeners do not consciously notice them. Source: [Music tempo and running cadence study](https://pmc.ncbi.nlm.nih.gov/articles/PMC4526248/).
- **Beat lock** aligns musical beat position with footfall timing. D-Jogger found that continuous tempo matching alone produced limited phase synchronization, while beat-phase correction produced much stronger synchronization. Sources: [D-Jogger phase study](https://pubmed.ncbi.nlm.nih.gov/25489742/), [continuous relative-phase study](https://pmc.ncbi.nlm.nih.gov/articles/PMC6283599/).

The current milestone must prove a felt tempo match and establish whether public MusicKit can support beat lock. Do not call frequency matching beat sync. djay uses separate terms for BPM Sync and BPM + Beat Sync for this reason. Source: [djay sync modes](https://help.algoriddim.com/user-manual/djay-ios/dj-tools/beatgrids-bpm-sync/sync).

## What Weav actually built

Weav's broad range was a content system, not one aggressive time-stretch setting.

- First-party and contemporary coverage describe a 100 to 240 BPM range in the original product, with a later company announcement claiming 60 to 240 BPM. Sources: [Weav producer explainer](https://medium.com/@weavmusic/what-adaptive-music-means-for-artists-and-producers-758334126943), [TechCrunch](https://techcrunch.com/2017/08/02/google-maps-cofounder-lars-rasmussen-wants-to-make-running-fun-through-music/), [2020 announcement](https://www.businesswire.com/news/home/20200630005225/en/Weav-Music-Launches-First-Personalized-Audio-Workouts-for-Runners).
- Artists delivered multiple stems or arrangements assigned to tempo bands. Within a band, Weav could stretch with pitch control. At a boundary, it could swap arrangements at a beat or bar and crossfade the components. Sources: [Weav producer explainer](https://medium.com/@weavmusic/what-adaptive-music-means-for-artists-and-producers-758334126943), [Weav patent](https://patents.google.com/patent/US11373630B2/en).
- Tempo-dependent orchestration let percussion, bass, synths, vocals, or other layers enter, leave, or change arrangement. The audible transformation came from composition as well as speed. Source: [Weav patent](https://patents.google.com/patent/US11373630B2/en).
- Weav licensed and approved adaptive versions rather than accepting arbitrary user masters. By 2020 it reported roughly 500 adaptive tracks and commissioned originals designed for multiple tempos. Source: [Runner's World interview](https://www.runnersworld.com/runners-stories/a32257227/running-app-weav-improves-cadence-stride/).
- Wide range did not make every song musically convincing. Weav acknowledged that genres have natural BPM regions, and reviewers heard some tracks become rushed or awkward. Sources: [Weav on adaptive music](https://medium.com/@weavmusic/whats-so-adaptive-about-our-music-bc9190772890), [runner review](https://www.speiser.com/weav).

The conclusion is firm: arbitrary Apple Music masters cannot reproduce Weav's 100 to 240 BPM behavior through playback rate alone. A truly Weav-like range is a future catalog, production, and rights strategy.

## What makes a change perceptible

Perceptibility and entrainment are different goals.

- Tempo-discrimination estimates vary with stimulus and method, from roughly 2 to 3 percent for simple sequences to approximately 6 to 9 percent in forced-choice comparisons. A deliberate faster-versus-slower proof should therefore use at least a 5 to 8 percent separation. Sources: [tempo discrimination review](https://pmc.ncbi.nlm.nih.gov/articles/PMC8525396/), [tempo discrimination study archive](https://web-archive.southampton.ac.uk/cogprints.org/644/1/tempo.htm).
- Small 1 to 3 percent changes can steer cadence without announcing themselves. That is useful for settled Auto behavior, but it is a poor demonstration of whether the player works. Source: [running entrainment study](https://pmc.ncbi.nlm.nih.gov/articles/PMC4526248/).
- Explicitly asking runners to match the beat increased the share who entrained from 33.33 percent to 57.58 percent in one study. One calm instruction can materially change the experience. Source: [instruction and running entrainment study](https://pmc.ncbi.nlm.nih.gov/articles/PMC8048782/).
- Music with a prominent, stable beat and a one-beat-per-step interpretation works better than rhythmically ambiguous material. Source: [music and metronome pacing study](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0070758).

Use two different motion profiles:

- **Audition** makes the mechanism obvious. It moves between clearly separated targets quickly enough to compare, then returns to neutral.
- **Run** preserves immersion. It ignores noise, follows genuine cadence changes, and avoids repeated audible corrections.

D-Jogger's sudden 3 percent phase corrections synchronized well but sounded mechanical and sometimes overcorrected. Its later continuously coupled approach felt smoother and synchronized more strongly. Source: [D-Jogger implementation](https://backoffice.biblio.ugent.be/download/8551818/8551819).

## djay Pro as the manipulation benchmark

djay demonstrates what polished control looks like, but it does not prove that an ordinary MusicKit app receives the same audio access.

- djay exposes key lock so tempo can move without pitch following it, and offers configurable tempo ranges from conservative settings to ±75 percent. Sources: [djay key lock](https://help.algoriddim.com/user-manual/djay-ios/dj-tools/key-lock), [djay tempo settings](https://help.algoriddim.com/user-manual/djay-ios/settings/general).
- Neural Mix Pro advertises pitch-stable time stretching up to ±75 percent for app-owned or locally processed material. That is a specialized engine and should be treated as a quality benchmark, not a safe Samadhi production range. Source: [Neural Mix Pro](https://www.algoriddim.com/news/364-algoriddim-introduces-ai-music-player-editor-on-neural-mix-pro).
- djay treats BPM as editable analysis, with half/double correction, tap tempo, exact entry, straight beat grids, dynamic beat grids, and downbeat anchors. A scalar BPM is not a complete synchronization model. Sources: [djay BPM editing](https://help.algoriddim.com/user-manual/djay-pro-windows/dj-tools/beatgrids-bpm-sync/adjusting-bpm), [djay beat grids](https://help.algoriddim.com/user-manual/djay-pro-windows/dj-tools/beatgrids-bpm-sync/beatgrids).
- djay's soft-takeover pattern transfers control without an abrupt jump. Samadhi should seed Manual from the currently applied musical target and let the user take ownership continuously. Source: [djay sync controls](https://help.algoriddim.com/user-manual/djay-ios/dj-tools/beatgrids-bpm-sync/sync).
- Automix selects compatible songs, aligns an incoming track, and blends tempo at a transition instead of forcing every song continuously. Source: [djay Automix](https://help.algoriddim.com/user-manual/djay-pro-mac/mixing-basics/using-automix).
- djay's Apple Music integration still disables Neural Mix and mix recording for streamed Apple Music tracks. Even a partner DJ product operates under material streaming restrictions. Source: [djay streaming services](https://help.algoriddim.com/user-manual/djay-ios/music-library/streaming-services).

The relevant lesson is not to copy a DJ interface. Build a restrained consumer interaction on top of the same principles: good analysis, compatible material, soft ownership transfer, and a clearly declared processing envelope.

## Public MusicKit boundary

Public MusicKit gives Samadhi a useful but narrow control surface.

- `ApplicationMusicPlayer` exposes queue, playback time, transitions, state, and writable playback rate. Apple does not publish a supported rate range, pitch-quality guarantee, beat grid, phase-control primitive, DSP graph, or PCM callback on this surface. Sources: [ApplicationMusicPlayer](https://developer.apple.com/documentation/musickit/applicationmusicplayer), [playbackRate](https://developer.apple.com/documentation/musickit/musicplayer/state-swift.class/playbackrate).
- Apple Music metadata does not document BPM, downbeat, beat grid, or phase offset. Samadhi must continue local analysis and cannot assume that a preview's phase maps to the full streamed song. Sources: [Apple Music song attributes](https://developer.apple.com/documentation/applemusicapi/songs/attributes-data.dictionary), [PreviewAsset](https://developer.apple.com/documentation/musickit/previewasset).
- Public `Song` and `PreviewAsset` surfaces expose streamed playback identity and preview assets, but no full-track file URL or PCM callback. Samadhi therefore cannot route subscription playback through `AVAudioEngine` or a chosen time-pitch algorithm using these public surfaces. This is an inference from the documented API boundary. Sources: [MusicKit Song](https://developer.apple.com/documentation/musickit/song), [PreviewAsset](https://developer.apple.com/documentation/musickit/previewasset).
- Apple's own AutoMix performs beat matching and time stretching internally, but that first-party feature does not expose those controls through public MusicKit. Source: [Apple services announcement](https://www.apple.com/newsroom/2025/06/apple-services-deliver-powerful-features-and-intelligent-updates-to-users-this-fall/).

Any wider MusicKit rate remains an empirical device capability. Test it. Do not infer quality or stability from a successful property write.

## Current Samadhi gap

The code already explains why the current experience can feel inert.

- When a requested BPM falls outside 0.94 through 1.06, `AdaptationPolicy` records `At limit` but calls `musicSteady`, which eases the command toward 1.00. The user can request a dramatic change and hear the original speed. Source: [AdaptationPolicy.swift](../Packages/SamadhiKit/Sources/SamadhiDomain/AdaptationPolicy.swift).
- The production queue retains imported order. It does not choose the ready track whose normalized tempo is closest to current cadence. Sources: [RunReducer.swift](../Packages/SamadhiKit/Sources/SamadhiDomain/RunReducer.swift), [AppleMusicPlaybackController.swift](../App/AppleMusicPlaybackController.swift).
- The current metric compares effective tempo with cadence. It does not observe footfall phase. Source: [AdaptationPolicy.swift](../Packages/SamadhiKit/Sources/SamadhiDomain/AdaptationPolicy.swift).

This is a mechanics problem before it is a visual-design problem. Do not polish the current matched state until the audio behavior passes the felt test.

## Recommended Apple Music mechanic

Use a two-layer match:

1. **Coarse match by song.** Normalize each ready track into plausible half, full, or double-time pulse families. Rank tracks by the absolute logarithmic distance between requested BPM and native pulse. Prefer strong-beat tracks and keep the current track when it remains inside a hysteresis band. D-Jogger used the same broad pattern of bounded stretching plus closer-tempo selection. Source: [D-Jogger implementation](https://backoffice.biblio.ugent.be/download/8551818/8551819).
2. **Fine match by rate.** Apply pitch-stable playback rate only inside a physically proven quality envelope. Start by testing 0.92 through 1.08, then 0.90 through 1.10 if the first range is clean. D-Jogger found roughly ±10 percent acceptable for its own phase-vocoder implementation, but that result is engine-specific. Source: [D-Jogger implementation](https://backoffice.biblio.ugent.be/download/8551818/8551819).
3. **Transition musically.** Reorder or select the next compatible song at a natural boundary. Do not jump tracks for every cadence fluctuation. djay applies tempo alignment around selected transition regions and holds a common BPM when songs are already close. Source: [djay Automix](https://help.algoriddim.com/user-manual/djay-pro-mac/mixing-basics/using-automix).
4. **Preserve truthful control.** If the current track cannot reach the target, hold the nearest proven boundary only during an explicit audition, or label the current song steady while preparing a compatible next track. Do not show `At limit` while silently returning to 1.00.

Auto and Manual remain distinct:

- **Auto follows.** It starts from reliable cadence, settles inside the entrainment basin, and stays calm.
- **Manual leads.** It lets the runner choose a training cadence, auditions an unmistakable change, then supports one-BPM trim. Weav and RockMyRun both treated detected and fixed tempo as first-class modes. Sources: [Weav review](https://www.runnersworld.com/runners-stories/a32257227/running-app-weav-improves-cadence-stride/), [RockMyRun myBeat](https://rockmyrun.com/myBeat.php).

## Perceptibility gate

Do not continue broad product work until this gate passes.

### MusicKit A/B

- Use five analyzed tracks with prominent, stable beats.
- For each track, compare 0.92, 1.00, and 1.08. Try 0.90 and 1.10 only after the first set is artifact-free.
- Record the request, MusicKit read-back, route, clicks, gaps, vocal smearing, pitch movement, warble, and whether Samay identifies faster versus slower without seeing the setting.
- Pass perceptibility when Samay identifies direction in at least four of five blinded comparisons and describes the largest clean pair as obvious rather than subtle.
- Pass quality only when every production endpoint is usable for a full song on the supported Bluetooth route.

The 5 to 8 percent comparison is grounded in published tempo-discrimination ranges. Sources: [tempo discrimination review](https://pmc.ncbi.nlm.nih.gov/articles/PMC8525396/), [tempo discrimination study archive](https://web-archive.southampton.ac.uk/cogprints.org/644/1/tempo.htm).

### Track-fit proof

- Given one stable cadence, show that the planner selects the closest ready tempo family.
- Given a cadence change that makes the current song incompatible for at least five seconds, prepare a compatible next song without oscillating between candidates. D-Jogger used a five-second outside-range trigger before selecting a closer song. Source: [D-Jogger implementation](https://backoffice.biblio.ugent.be/download/8551818/8551819).
- Verify requested BPM, selected pulse family, derived rate, MusicKit read-back, and effective BPM agree.
- Keep playlist order only as a tie-breaker. Product usefulness outranks strict source order.

### Felt-lock proof

- Compare no instruction with one calm cue: “Let your steps settle onto the beat.” Explicit instruction materially increased entrainment in published running research. Source: [instruction and running entrainment study](https://pmc.ncbi.nlm.nih.gov/articles/PMC8048782/).
- Measure step-to-beat phase before making a beat-lock claim. End-to-end latency includes sensing, filtering, control, player response, audio buffering, Bluetooth, and perception. D-Jogger calibrated roughly 100 ms in its hardware path and reported approximately 13 ms mean placement after compensation; Samadhi needs its own measurement. Source: [D-Jogger implementation](https://backoffice.biblio.ugent.be/download/8551818/8551819).
- If public MusicKit cannot supply a trustworthy beat grid and phase-control path, retain “Tempo matched” as honest language and treat true felt lock as a source-level blocker.

## Pivot path if MusicKit fails

App-owned audio unlocks the missing controls.

- `AVAudioUnitTimePitch` changes rate independently of pitch over a documented 1/32 to 32 range, with overlap available to trade more processing for fewer artifacts. Practical music quality still needs a narrow device bake-off. Sources: [TimePitch rate](https://developer.apple.com/documentation/avfaudio/avaudiounittimepitch/rate), [TimePitch overlap](https://developer.apple.com/documentation/avfaudio/avaudiounittimepitch/overlap).
- `AVAudioPlayerNode` can schedule buffers and segments at sample or host times. Two nodes feeding a mixer provide the basis for preroll, beat-aligned starts, crossfades, and gapless transitions. Source: [AVAudioPlayerNode](https://developer.apple.com/documentation/avfaudio/avaudioplayernode).
- `AVPlayer` with the spectral time-pitch algorithm is a smaller first spike for app-owned files, and host-time rate control can align playback with an external clock. Sources: [spectral time pitch](https://developer.apple.com/documentation/avfoundation/avaudiotimepitchalgorithm/spectral), [host-time rate control](https://developer.apple.com/documentation/avfoundation/avplayer/setrate%28_%3Atime%3Aathosttime%3A%29).
- Third-party engines remain fallback options. Superpowered exposes dedicated music time stretching and formant correction; Rubber Band supports real-time use but requires a commercial license for a closed-source App Store product. Sources: [Superpowered time stretching](https://docs.superpowered.com/reference/latest/time-stretching/), [Rubber Band licensing](https://github.com/breakfastquay/rubberband).

The pivot order is:

1. Public MusicKit with compatible-track selection and a physically proven wider correction envelope.
2. App-owned DRM-free files with Apple spectral processing and phase-aware scheduling.
3. A small commissioned or licensed adaptive catalog if Weav-scale range remains the product requirement.
4. An Apple DJ partnership only if Apple documents a path available to Samadhi. djay's public Apple Music integration does not establish such a path for ordinary MusicKit apps. Sources: [djay Apple Music announcement](https://www.algoriddim.com/news/449-apple-music-integration-is-here-), [djay streaming restrictions](https://help.algoriddim.com/user-manual/djay-ios/music-library/streaming-services).

## Stop rule

Reject the middle path: do not polish a ±6 percent tempo-only system and market it as synchronization. Pass the perceptibility gate, add track-aware matching, and investigate phase. If public MusicKit cannot produce a bodily, repeatable result, reopen the source decision immediately.

---

## Sources

- https://developer.apple.com/documentation/musickit/applicationmusicplayer
- https://developer.apple.com/documentation/musickit/musicplayer/state-swift.class/playbackrate
- https://developer.apple.com/documentation/applemusicapi/songs/attributes-data.dictionary
- https://developer.apple.com/documentation/musickit/previewasset
- https://developer.apple.com/documentation/musickit/song
- https://developer.apple.com/documentation/avfaudio/avaudiounittimepitch/rate
- https://developer.apple.com/documentation/avfaudio/avaudiounittimepitch/overlap
- https://developer.apple.com/documentation/avfaudio/avaudioplayernode
- https://developer.apple.com/documentation/avfoundation/avaudiotimepitchalgorithm/spectral
- https://developer.apple.com/documentation/avfoundation/avplayer/setrate%28_%3Atime%3Aathosttime%3A%29
- https://www.apple.com/newsroom/2025/06/apple-services-deliver-powerful-features-and-intelligent-updates-to-users-this-fall/
- https://medium.com/@weavmusic/what-adaptive-music-means-for-artists-and-producers-758334126943
- https://medium.com/@weavmusic/whats-so-adaptive-about-our-music-bc9190772890
- https://patents.google.com/patent/US11373630B2/en
- https://techcrunch.com/2017/08/02/google-maps-cofounder-lars-rasmussen-wants-to-make-running-fun-through-music/
- https://www.runnersworld.com/runners-stories/a32257227/running-app-weav-improves-cadence-stride/
- https://www.speiser.com/weav
- https://www.businesswire.com/news/home/20200630005225/en/Weav-Music-Launches-First-Personalized-Audio-Workouts-for-Runners
- https://pmc.ncbi.nlm.nih.gov/articles/PMC4526248/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC8525396/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC8048782/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC6283599/
- https://pubmed.ncbi.nlm.nih.gov/25489742/
- https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0070758
- https://backoffice.biblio.ugent.be/download/8551818/8551819
- https://web-archive.southampton.ac.uk/cogprints.org/644/1/tempo.htm
- https://help.algoriddim.com/user-manual/djay-ios/dj-tools/beatgrids-bpm-sync/sync
- https://help.algoriddim.com/user-manual/djay-ios/dj-tools/key-lock
- https://help.algoriddim.com/user-manual/djay-ios/settings/general
- https://help.algoriddim.com/user-manual/djay-pro-windows/dj-tools/beatgrids-bpm-sync/adjusting-bpm
- https://help.algoriddim.com/user-manual/djay-pro-windows/dj-tools/beatgrids-bpm-sync/beatgrids
- https://help.algoriddim.com/user-manual/djay-pro-mac/mixing-basics/using-automix
- https://help.algoriddim.com/user-manual/djay-ios/music-library/streaming-services
- https://www.algoriddim.com/news/364-algoriddim-introduces-ai-music-player-editor-on-neural-mix-pro
- https://www.algoriddim.com/news/449-apple-music-integration-is-here-
- https://rockmyrun.com/myBeat.php
- https://techcrunch.com/2015/05/20/spotify-for-runners/
- https://docs.superpowered.com/reference/latest/time-stretching/
- https://github.com/breakfastquay/rubberband

---

*Captured: 2026-07-21*
