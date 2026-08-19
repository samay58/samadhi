# Progress

## 2026-07-15. Foundation

- Created iOS 26 app, local Swift package, XcodeGen project, tests, previews, and evidence structure
- Established pure reducer and simulated cadence and beat timing
- Proved full interaction and recovery flow in Simulator

## 2026-07-15. Design refinement

- Replaced square artwork with full-screen native fluid field
- Removed passive white cards
- Enlarged tempo aperture and linked outer ring to song progress
- Kept one motion owner and reduced field update cadence
- Verified large Dynamic Type, Reduce Motion, contrast, and missing artwork

## 2026-07-15. Identity

- Renamed product, target, scheme, package, tests, bundle, docs, repository, and local handoff to Samadhi
- Installed refined app icon
- Added Midjourney repository cover with “music in stride” outside ribbon loop
- Pushed tested prototype to GitHub main

## 2026-07-15. Cleanup

- Removed empty diagnostics module
- Split design and domain monoliths into focused types
- Isolated async task lifecycle
- Configured track count from active collection
- Added track wraparound test
- Added reproducible Swift formatter gate
- Consolidated docs around product, status, plan, architecture, proof, and progress
- Removed stale evidence, rejected exports, completed prompts, and superseded handoff
- Passed 15 package tests, 2 app-model tests, and 4 UI tests after cleanup

## 2026-07-15. Code navigation

- Added sparse plain-English guidance at the state, effect, task, accessibility, motion, and screen-routing seams
- Recorded the comment standard in repository instructions so later work stays readable without becoming noisy
- Re-ran formatter, 15 package tests, 2 app-model tests, and 4 UI tests

## 2026-07-15. Milestone 2 specification

- Specified playlist import, real cadence, tempo analysis, adaptive playback, background continuity, recovery, and physical proof
- Chose import before generation and one production player after an Apple Music feasibility gate
- Corrected the measurement boundary from implied footfall phase to honest tempo matching
- Updated active product, plan, architecture, decisions, status, and repository guide

## 2026-07-15. Milestone 2 safe groundwork

- Inspected the actual Xcode 27 SDK, signing state, connected-device list, and project capabilities
- Found no connected physical iPhone and no configured Apple development team, so the Apple Music gate remains open
- Added source-neutral music, tempo, cadence, progress, adaptation, and honest measurement models
- Added deterministic adaptation tests for normalization, bounds, ramping, deadband, confidence loss, incompatible tracks, and match timing
- Added a cadence-provider boundary, deterministic filter, Core Motion adapter, and motion tests
- Renamed the summary measurement to tempo matched and made fixed rhythm report Not measured
- Added music and motion permission text and verified background audio configuration
- Added the source-controlled `Samadhi MusicKit Gate` scheme and debug harness with JSON evidence export
- Passed Simulator and unsigned generic iPhone builds; recorded the exact physical and signing blocker
- Passed formatter, 29 package tests, 2 app-model tests, and 4 UI tests on the final tree

## 2026-07-15. Physical MusicKit gate opened

- Registered the explicit `com.samaydhawan.Samadhi` App ID and received user confirmation that its MusicKit App Service is enabled
- Saved Apple team `ZL5U59XBJ6` in `project.yml` and regenerated the Xcode project
- Confirmed signed generic and physical iPhone builds with the Apple Development certificate
- Confirmed Samay's physical iPhone 17 Pro on iOS 27.0 with Developer Mode enabled
- Installed and launched the `Samadhi MusicKit Gate` harness on the physical phone
- Left the source decision open pending authorization, playlist, decoded-preview, playback, listening, background, interruption, and route evidence

## 2026-07-15. Physical MusicKit traces

- Saved five JSON traces from the iPhone with checksums and a durable evidence analysis
- Passed contextual Music authorization, 40-playlist loading, real playback, live 0.94, 1.00, and 1.06 rate writes, pause, and resume
- Observed 0 of 10 direct-library preview coverage across every tested sample
- Added one focused ISRC-based catalog-resolution check because the installed SDK supports catalog lookup and catalog songs may carry previews absent from library tracks
- Built, signed, installed, and launched the retry harness on the same physical iPhone
- Found no ISRC on 40 sampled tracks and added the SDK's equivalent-ID lookup as the final documented catalog path
- Pulled the live trace directly from the phone and matched it byte-for-byte to the user export
- Recorded 40 `.developerTokenRequestFailed` results, leaving catalog preview feasibility honestly blocked rather than passed or failed

## 2026-07-15. Music source resolution

- At that checkpoint, verified Apple Music automatic-token configuration requirements and the meaning of `developerTokenRequestFailed`
- At that checkpoint, found only the Xcode-managed wildcard `ZL5U59XBJ6.*`; the exact Samadhi profile was installed the following day
- Limited remediation to one clean build signed with a fresh exact-App-ID development profile
- Rejected embedded private keys, committed tokens, and a Samadhi token backend
- Evaluated Spotify's current iOS SDK, player surface, development-mode rules, and Developer Policy
- Rejected Spotify as an adaptive player because it cannot provide the required app-owned, analyzable, rate-controlled audio path
- Specified token, tempo-source, listening, background, recovery, and local-file fallback gates in `MUSIC-SOURCE-RESOLUTION-SPEC.md`

## 2026-07-16. Apple token and preview gates

- Installed and verified the exact `Samadhi Development` profile and signed identifier
- Passed automatic token generation with repeated direct catalog responses
- Added a focused launch-argument token probe to the debug-only harness
- Rejected nonnumeric library IDs as equivalent-ID inputs and added strict title, artist, album, and duration catalog resolution
- Downloaded remote catalog previews to temporary app storage before local decoding
- Passed strict catalog identity and decoded PCM coverage at 10 of 10 City Pocket tracks
- Recorded a clean built-in-speaker listening result with no major pitch change or unpleasant artifacts at the safe-rate endpoints
- Saved the user export and byte-matched device trace under `Evidence/Device/`
- Passed the full serial test gate, rebuilt with the exact profile, and installed the final harness build on the physical iPhone
- Left headphone listening, background, track change, controlled interruption, and route loss honestly open

## 2026-07-16. Production player selected

- Reached Beoplay Eleven through Bluetooth A2DP and applied 0.94, 1.00, and 1.06 during real playback
- Stopped the repetitive manual trace loop after Samay explicitly deferred the remaining drills
- Selected Apple Music as the one production source while keeping long-form reliability checks open
- Added a source-neutral player contract, deterministic player, Apple Music adapter, and identified progress and recovery events
- Added a focused Apple Music core-loop scheme around one real catalog track
- Preserved the normal deterministic app flow until playlist import is ready
- Passed formatting, 32 package tests, 2 app-model tests, and 4 UI tests on the implementation tree

## 2026-07-16. Tempo-analysis seam

- Added one local audio-file analysis interface for Apple Music previews and future imported files
- Moved PCM decoding off the main actor and reduced multichannel audio to mono
- Added a versioned onset and autocorrelation estimator
- Added generated 120, 150, 168, and 190 BPM fixtures plus silence and irregular-onset rejection
- Connected the MusicKit harness to record estimated BPM, confidence, and analysis version
- Kept real-music accuracy and the twelve-excerpt corpus explicitly open
- Passed formatting, 37 package tests, 2 app-model tests, 4 UI tests, and the exact-profile physical iPhone build

## 2026-07-16. Real-preview tempo validation

- Built an opt-in 12-track Apple preview corpus using catalog titles that declare tempos from 130 through 180 BPM
- Found that analyzer version 1 passed 11 of 12 but confidently labelled one 180 BPM mix as 60 BPM
- Replaced frame-energy onset detection with Accelerate spectral flux and fractional-lag autocorrelation
- Added a public-seam regression for the triple-meter failure and conservative rejection when the correct tempo family lacks support
- Passed 12 of 12 real previews within 2 percent of the published tempo or its half or double
- Selected catalog track `1066177773` as the verified 170 BPM core-loop fixture
- Kept provider-hosted audio temporary and stored only the corpus manifest, JSON result, checksum, and analysis
- Passed formatting, 38 package tests, 2 app-model tests, 4 UI tests, and the exact-profile physical iPhone build

## 2026-07-16. Body-to-music core loop

- Connected the verified 170 BPM Apple Music fixture to Core Motion cadence in the focused core-loop scheme
- Kept normal runs and previews on deterministic simulation
- Continued cadence sensing after first lock so stable changes and confidence loss remain observable
- Made the reducer own adaptation state and emit bounded rate effects through `MusicPlaybackProviding`
- Added session, operation, rate-request, and track identity to applied-rate feedback
- Connected tempo-matched measurement to the player-reported applied rate
- Added deterministic coverage for stable cadence, rate feedback, confidence loss, stale callbacks, provider failure, and replacement sessions
- Passed formatting, 43 package tests, 2 app-model tests, 4 UI tests, an unsigned iPhone build, and the exact-profile physical build
- Installed the body-to-music-capable app build on Samay's iPhone; focused scheme launch remained blocked because the phone was locked, and direct icon launch remains the normal simulation

## 2026-07-16. Physical cadence seam

- Launched the focused configuration with its required device argument
- Observed changing Core Motion cadence during a 29-second physical walk and recorded a 142 SPM average
- Confirmed the 0 percent tempo-matched summary was honest because 142 SPM is outside the original 170.25 BPM fixture's safe rate range
- Replaced the focused fixture with validated catalog track `1434921088`, estimated at 139.5 BPM, so the next short walk can exercise automatic rate response without weakening safety limits

## 2026-07-16. Objective rate diagnostics

- Recorded no perceptible speed change during the 139.5 BPM follow-up
- Found that the Apple Music adapter immediately echoed its commanded rate as applied instead of reading MusicKit state back
- Changed applied-rate feedback to carry MusicKit's observed playback rate with the original request and track identities
- Added a focused-only panel showing cadence, target rate, applied rate, and pending feedback
- Selected validated catalog track `1558215042`, estimated at 149.75 BPM, for a clearer bounded ramp around the observed 142 SPM cadence
- Added a deterministic regression covering the expected 1.00, 0.98, 0.96, and target-rate sequence
- Passed 44 package tests, 2 app-model tests, 4 UI tests, formatter lint, documentation links, and the exact-profile iPhone build
- Left physical installation open because the iPhone became unavailable to Xcode

## 2026-07-16. Automatic rate response

- Installed and launched the corrected build after the iPhone reconnected
- Completed a 59-second focused run with a 155 SPM average, one song, and 98 percent tempo matched
- Confirmed the result depends on MusicKit read-back; a fixed 1.00 rate on the 149.75 BPM fixture cannot satisfy the three-SPM match tolerance at the observed cadence
- Saved the user-supplied completed-run frame with a checksum and confirmed direct device capture is available for future live checks
- Closed the automatic rate-response gate

## 2026-07-16. Imported collection

- Added native Apple Music playlist choice, strict catalog resolution, and sequential local preview analysis
- Preserved source order and made pending, ready, unreadable, and unavailable states explicit
- Added versioned tempo caching and atomic selected-collection persistence
- Ignored stale import callbacks and preserved the prior durable selection until replacement completed
- Filtered the production queue to ready tracks while keeping failures visible during setup
- Connected restored imported music to real Apple Music playback and Core Motion cadence in the normal app
- Added deterministic empty, loading, analyzing, partial, authorization-failure, and import-failure states
- Added two reviewed Simulator frames for the empty and partial states
- Passed formatter lint, 48 package tests, 7 app-model tests, and 8 UI tests
- Built with the exact development profile, installed the normal test build, and launched it on Samay's iPhone
- Left one real playlist, three ready tracks, relaunch restore, and multi-track playback open for physical proof

## 2026-07-20. Physical import evidence and run diagnostics

- Pulled the Xcode-installed app container directly from Samay's connected iPhone
- Verified `Strut Frequency -- July 2026` persisted with 25 tracks: 13 ready, 8 unreadable, and 4 unavailable
- Passed the physical three-ready-track import threshold without asking Samay to repeat analysis
- Kept raw personal library metadata out of the repository and saved counts plus checksum as durable evidence
- Found relaunch blocked only because the phone was locked
- Added debug-only latest-run diagnostics for real progress, cadence, target and applied rates, track changes, recovery events, and summary
- Passed formatter lint, a Simulator build, 48 package tests, 9 app-model tests, and 8 UI tests
- Built and installed the diagnostics-capable app with the exact profile while preserving the selected playlist byte-for-byte
- Reached the honest device blocker: iOS denied foreground launch because the phone was locked

## 2026-07-20. In-run BPM control

- Added source-neutral Auto fine-tune and Manual BPM state with explicit reset and per-run defaults
- Routed every adjustment through the reducer, bounded adaptation policy, identified player effect, and MusicKit read-back seam
- Kept Manual useful before cadence lock without inventing cadence or a measured summary
- Added honest safe-limit feedback and persisted control intent, derived rate, observed rate, and limit state in latest-run diagnostics
- Turned the existing tempo aperture into a progressive, one-handed control with horizontal detents, large slower and faster targets, restrained haptics, and separate Auto and Manual ownership
- Added VoiceOver adjustment, useful labels and values, Dynamic Type behavior, increased contrast, and Reduce Motion support
- Reviewed final iPhone 17 Pro Simulator frames for Auto fine-tune, Manual safety limit, and accessibility-size text; the wider main-screen system did not need redesign
- Passed formatter lint, 60 package tests, 9 app-model tests, 9 UI tests, the normal Simulator build, and an exact-profile signed iPhone build
- Initially found the paired physical iPhone unavailable to Xcode, so no MusicKit or listening claim was made
- Reconnected later, then built from clean commit `50de75b`, installed the exact-profile app, launched it, and confirmed the Samadhi process was running

## 2026-07-20. Current main phone update

- Built current `main` from a clean detached worktree with the exact development profile
- Installed and launched the physical build on Samay's iPhone
- Verified the selected playlist survived byte-for-byte and restored to the normal ready screen with 13 of 25 tracks ready
- Pulled schema-version-2 diagnostics showing real production-player progress from 0 through 6 seconds
- Re-ran the focused BPM interaction UI test on the booted iPhone 17 Pro Simulator
- Left cadence-driven BPM response, a natural track transition, listening, background, and recovery honestly open

## 2026-07-21. Felt-synchronization research

- Researched Weav's adaptive-arrangement system, published running entrainment work, public MusicKit limits, and djay Pro's separation of BPM, beat sync, key lock, track compatibility, and transitions
- Confirmed that arbitrary Apple Music masters cannot reproduce Weav's broad range through playback rate alone
- Defined a pass-or-pivot MusicKit perceptibility gate and an app-owned audio fallback
- Made coarse compatible-track selection plus fine rate correction the production mechanic
- Added a source-neutral track-fit planner with deterministic half-time, full-time, double-time, quality-envelope, source-order, and retention tests
- Added a debug-only blinded 0.92 versus 1.08 comparison with recorded answers, rate read-back, and optional wider endpoints
- Saved the sourced mechanics and evidence thresholds in `ADAPTIVE-AUDIO-PLAYBOOK.md`
- Passed formatter lint, 67 package tests, 9 app-model tests, and 9 UI tests on the resulting tree
- Consolidated the findings into one prioritized execution spec with explicit pass, pivot, evidence, craft, and milestone-completion gates

## 2026-07-21. Perceptibility gate setup

- Reconnected to the paired iPhone 17 Pro over the local network and verified iOS 27.0 with Developer Mode enabled
- Confirmed the exact `Samadhi Development` profile remains installed and expires on 2026-07-23 UTC
- Caught automatic signing selecting the wildcard profile and rejected that build before installation
- Rebuilt the MusicKit harness with the exact profile, verified its embedded application identifier, installed it, and launched it
- Captured the live harness on the Beoplay Eleven Bluetooth A2DP route
- Reached the honest human blocker: the blinded faster-or-slower and artifact judgments still need Samay's ears
- Pulled the device trace directly and matched it against the user export at the shared observation point
- Recorded that 0.90 versus 1.10 was clearly audible on `LITE SPOTS` through Beoplay Eleven, with approximately 95 percent user confidence
- Kept the normal-run quality envelope at 0.94 through 1.06 because the wider endpoints have not passed full-song artifact listening

## 2026-07-21. Production track fit and click wheel

- Connected `TrackMatchPlanner` to adaptive run start using 168 BPM only as an initial prior
- Made real player callbacks authoritative for song identity, index, and count
- Added a five-second stable-mismatch hold and identified preparation of one better-fitting next song
- Kept the current song playing until explicit Skip or its natural boundary
- Turned the tempo aperture into a rotary BPM click wheel with angular one-BPM detents, soft takeover, restrained haptics, VoiceOver adjustment, and a temporary perimeter marker
- Removed separate plus and minus controls after visual review
- Saved the refined iPhone 17 Pro Simulator frame as `Evidence/Simulator/2026-07-21-rotary-bpm-click-wheel.png`
- Expanded the package suite to 74 tests and kept 9 app-model and 9 UI tests
- Passed formatter lint, the full serial gate, and an exact-profile signed iPhone build
- Left installation honest and open because the paired iPhone was unavailable over the network

## 2026-07-21. Simulator demo and rotary coherence

- Added two local placeholder playlists for normal Debug Simulator launches while leaving physical iPhone and Release composition unchanged
- Kept stable regression music separate from the varied demo collection after the full gate exposed a golden-flow ordering regression
- Added model and UI proof that the normal app starts, reaches cadence lock, and can replace the local collection without Apple Music
- Anchored wheel geometry to finger-down, preserved angle continuity across wraparound, and kept center-origin gestures inert
- Fixed an automatic-range defect that moved the limit inward after each detent and made a requested plus-eight turn stop at plus four
- Emitted one reducer action and selection haptic per crossed BPM detent, used a distinct boundary warning, and reused prepared haptic generators
- Verified clockwise 168 to 176, counterclockwise 176 to 165, center protection, Manual ownership, and Auto reset to 168 in the real Simulator UI
- Saved a compact interaction recording and a normal-launch frame under `Evidence/Simulator/`
- Expanded the automated gate to 80 package tests, 11 app-model tests, and 10 UI tests

## 2026-07-21. Forty-BPM wheel and tactile grammar

- Replaced the inherited minus-eight through plus-eight Auto correction with a 40-BPM window around measured cadence
- Kept targets inside the app's accepted 120 through 210 running range and left the per-song 0.94 through 1.06 quality envelope unchanged
- Mapped one complete wheel revolution to 40 one-BPM detents
- Added a restrained visible detent ring with one landmark every five BPM
- Replaced generic selection feedback on supported iPhones with low-sharpness Core Haptics transients, fuller five-BPM landmarks, and a soft Auto landing
- Queued rapid detents 28 milliseconds apart so a quick turn still feels stepped instead of collapsing into one buzz
- Kept system selection feedback as the fallback and delayed haptic-engine startup until the control opens
- Added deterministic range, running-bound, tactile-event, and full-revolution tests
- Saved the inspected iPhone 17 Pro frame as `Evidence/Simulator/2026-07-21-forty-bpm-click-wheel.png`
- Expanded the package suite to 83 tests while retaining 11 app-model and 10 UI tests
- Replaced the visible tuning sentence with three resting grip notches in the wheel rim
- Added one clockwise-and-back teaching movement that retires after first use while keeping Reduce Motion static
- Added the single word `Turn` inside the aperture after the purely visual cue proved too ambiguous
- Saved the inspected resting frame as `Evidence/Simulator/2026-07-21-tempo-affordance.png`

## 2026-07-22. Restored iPhone install

- Repaired wireless pairing after the iPhone restore and confirmed Developer Mode remained enabled
- Built commit `c8e195e` from a clean detached worktree with the exact `Samadhi Development` profile
- Verified the embedded application identifier, installed the build over the local network, and launched Samadhi
- Confirmed the live process and captured the normal `Choose music` setup screen directly from the device
- Recorded that the restore cleared the prior local playlist selection without claiming click-wheel feel or run behavior

## 2026-07-22. First normal field-run failure

- Pulled the completed run and imported-collection records directly from the restored iPhone
- Reproduced the core complaint from persisted evidence: 497 wheel adjustments and a 59-BPM requested span yielded only a 0.056 applied-rate span and finished at 1.00
- Found that incompatible manual targets silently return playback toward 1.00 while the interface continues showing the requested BPM
- Found that the 99 percent summary used 140 of 141 eligible automatic seconds while 99 manual seconds were unmeasured
- Confirmed the selected 18-track playlist contained 11 ready tracks, 5 tempo-analysis failures, and 2 unavailable tracks
- Located the hard five-row UI truncation, sequential import pipeline, collapsed failure reasons, deliberately weak detents, and directionless haptic event
- Reordered the plan around deterministic replay, command truth, felt response, import comprehension and speed, and directional tactile proof

## 2026-07-22. Field-run remediation

- Added a privacy-safe deterministic replay of the broad Manual turn and misleading summary from the first field run
- Made requested BPM, achievable BPM, commanded rate, MusicKit read-back, latency, and command status separate truths
- Changed rapid detents to ramp from the latest pending command and kept applied state blocked on player read-back
- Rejected unreachable detents at the last truthful target and committed an immediately compatible track for direct wheel intent
- Reapplied the current Auto or Manual target after the player confirmed a track change
- Required 80 percent verified measurement coverage before showing tempo matched and recorded Automatic versus Manual seconds
- Preserved every imported track from the first progress frame, added typed failure reasons, and exposed complete results behind one native `All tracks` sheet
- Added retry after relaunch, ordered three-track import batches, and private stage timing diagnostics
- Strengthened ordinary detents and preserved clockwise versus counterclockwise direction through Core Haptics and system fallbacks
- Saved and checked the complete import disclosure frame on iPhone 17 Pro Simulator
- Passed formatter lint, 92 package tests, 14 app-model tests, and 10 UI tests
- Built with the exact `Samadhi Development` profile, verified the embedded application identifier, and installed the remediation build on Samay's connected iPhone
- Left audible response, haptic feel, and real import timing open because they require a short physical perception check

## 2026-07-22. Exact BPM and fresh Auto repair

- Reproduced the moving Manual target, stale cadence lock, half-time relabeling, narrow rate envelope, and slow matched ramp in deterministic tests
- Changed wheel detents to local visual and haptic previews, with one absolute Manual BPM committed at finger-up
- Made Manual commit its compatible target rate immediately and made Auto move at 0.02 rate units per second
- Expanded production playback to the physically audible 0.90 through 1.10 range
- Used `CMPedometerData.endDate` to reject samples more than two seconds old and made three stale, missing, or invalid samples return Auto to acquisition
- Removed half-time and double-time relabeling from track planning, adaptation, applied BPM, and summary measurement
- Added tempo estimator version 3 and automatic reimport of persisted version-2 analysis
- Passed 11 of 12 real Apple previews against the exact declared running pulse; the remaining preview was rejected
- Added UI proof that a completed wheel turn reaches matching simulated player read-back
- Fixed a serial UI failure that exposed the wheel timeout hiding the control during an active turn
- Passed formatter lint, 97 package tests, 15 app-model tests, and 10 UI tests
- Rebuilt with the exact `Samadhi Development` profile, verified the embedded application identifier, and installed the final repair on Samay's connected iPhone

## Checkpoint after the 2026-07-22 repair

Milestones 0 and 1 are complete. Milestone 2 is still open. The next checkpoint is one short physical proof on the new build: let the playlist reanalyze once, confirm the ready count, make several large wheel changes without an unexpected song change, then use Skip and one natural boundary to prove the only allowed transition paths. Pull diagnostics immediately afterward. No visual expansion outranks that result.

## 2026-07-22. Tempo coverage and transport repair

- Reproduced the hidden transition path where a direct wheel target marked a selection immediate and preparation completion emitted Skip
- Removed immediate-selection state and made Manual and Auto preparation coalesce without changing transport
- Kept unreachable requests while moving the current song to its nearest truthful rate; requested BPM, achievable Music BPM, and player read-back remain separate
- Added deterministic coverage for one large target, rapid targets, stable Auto mismatch, stale preparation, explicit Skip, player-confirmed natural transition, and nearest-boundary truth
- Pulled the current selected collection and import diagnostics into temporary storage without committing track metadata
- Found 11 prior ready analyses, 10 version-3 ready tracks, six rhythm-unclear tracks, and two catalog-unavailable tracks in the current 18-track collection
- Expanded estimator version 4 to preserve the measured 60 through 210 BPM musical pulse and record an independently supported stride pulse separately
- Replayed all 16 preview-available private tracks: 14 are ready under version 4, four version-3 rejections recover, no version-3 ready track is lost, and two remain ambiguous
- Passed all 12 public tempo-declared previews within 2 percent while keeping the prior 89.5-versus-180 regression, silence, irregular rhythm, and triple-meter ambiguity closed
- Bumped persisted tempo and run-diagnostic semantics to version 4 so older selections reanalyze once
- Passed formatter lint, 102 package tests, 15 app-model tests, and 10 UI tests in the final serial gate
- Built the repair with the exact `Samadhi Development` profile and verified the embedded application identifier; the paired iPhone was unavailable, so installation remains open

## 2026-07-23. Response latency and release gate

- Launched the normal app on iPhone 17 Simulator and reviewed the ready and active-run screens at runtime
- Re-ran the focused rotary UI flow; four strong clockwise turns reached the truthful simulated player boundary within two seconds without changing the song
- Confirmed Manual commits already send one immediate absolute rate command at finger-up
- Reduced reliable Auto target recomputation from two seconds to one after the cadence filter and 2 SPM deadband
- Added deterministic proof that a fresh 10 percent Auto change reaches the full proven rate envelope within five seconds
- Passed formatter lint, 103 package tests, 15 app-model tests, and 10 UI tests in the final serial gate
- Rejected an automatically signed physical build because Xcode selected a wildcard application identifier
- Renewed the exact `Samadhi Development` profile through 2026-07-30 UTC
- Rebuilt pushed commit `66e0616` from a clean detached worktree and verified the exact embedded application identifier and signature
- Installed the verified build without uninstalling the app; the selected-collection checksum stayed byte-for-byte identical
- Left foreground launch honest and open because the phone was locked

## 2026-07-23. Field startup, Auto, and control repair

- Pulled the current container and confirmed 18 selected tracks: 14 ready under estimator version 4, two rhythm unclear, and two catalog unavailable
- Proved LITE SPOTS was ready and appeared to skip only because startup selected against a hardcoded 168 SPM prior; Gorilla fit that invented target more closely
- Replaced cadence-guess startup with the first ready track in imported source order
- Added explicit one-step-per-beat and supported two-steps-per-beat relationships without relabelling measured musical BPM
- Measured representative private cadence compatibility at 13 of 56 exact matrix cells and 16 of 56 with explicit relationships plus a three-SPM truthful boundary
- Recorded that the improvement is not broad enough to close the range problem; wider MusicKit rate or a different source mechanic still needs evidence
- Replaced callback-count tracking with explicit acquisition, tracking, and reacquisition behavior based on sample timing
- Made three agreeing fresh samples authoritative, rejected a stale 180 SPM prior, required corroboration for a large change, and tracked a sustained 150 to 175 SPM step to at least 169 SPM by the third changed observation
- Preserved raw cadence, `CMPedometerData.endDate`, callback interval, filter state, target, command, MusicKit read-back, track identity, and transition reason in bounded schema-version-5 diagnostics during unfinished runs
- Required every player-confirmed track change to be labelled Previous, Skip, natural boundary, or recovery
- Slowed the rotary control from 40 to 30 BPM per revolution and added reverse hysteresis while preserving wraparound, multiple revolutions, center protection, directional haptics, and one Manual commit at finger-up
- Passed formatter lint, 112 package tests, iPhone and Simulator package compilation, and iPhone and Simulator app-model typechecking
- Left the implementation uncommitted because CoreSimulator service access is refused from the current tool process; the resource app build, serial UI suite, exact-profile build, installation, and current physical timing trace remain required

## Checkpoint after the 2026-07-23 candidate

This checkpoint recorded a passing local candidate before its exact-profile build and installation. The next intended check was one song covering source-order startup, both Manual boundaries, immediate reverse, return to Auto with a cadence change, and a quick audible and tactile judgment.

## 2026-07-24. Honest Manual wheel boundary

- Derived the Manual integer BPM range from the current cadence projection and proven 0.90 through 1.10 player envelope
- Clamped local preview, final Manual commit, reducer state, and accessibility adjustment to the same range
- Stopped the number, visual marker, detent haptics, and final command at each boundary
- Added one restrained terminal haptic, discarded repeated outward overshoot, and preserved immediate reverse response
- Kept the current song fixed throughout wheel movement and retained explicit Skip or natural boundary as the only forward transport authority
- Replaced the fixture-specific UI assertion with a flow that discovers the real song boundary, pushes beyond it twice, reverses, and verifies track retention
- Passed formatter lint, 116 package tests, a resource-inclusive Simulator build, 16 app-model tests, and 10 serial UI tests

## 2026-07-25. Field repair installation

- Pushed commit `42f4dd5` to `main`
- Rebuilt that commit from a clean detached worktree with the exact `Samadhi Development` profile
- Verified the embedded application identifier and code signature
- Installed over the existing app without uninstalling or replacing its container
- Confirmed the selected-collection checksum remained byte-for-byte identical
- Attempted foreground launch but left it open because the phone was locked

## 2026-07-27. Continuous music setup

- Rebuilt first-run music setup around one stable playlist identity from selection through analysis, readiness, and failure
- Reduced the empty state to `Music in stride` and one direct action
- Replaced the generic playlist card with a native warm sheet, open typography, quiet separators, 40-playlist scrolling, and an accessible current-selection state
- Kept exact analysis progress on the primary surface while moving complete typed track results into one optional sheet
- Made partial readiness immediately legible and removed the extra ready-state marketing sentence and technical rows
- Added typed same-playlist retry, choose-another, empty-playlist, unavailable-playlist, library, and authorization recovery
- Preserved import cancellation, stale-operation protection, atomic persistence, ready-only start truth, and partial-collection start
- Reviewed fresh iPhone 17 Pro Simulator frames for empty, picker, loading, analysis, partial and complete readiness, results, failure, accessibility XXXL, and Reduce Motion
- Expanded the gate to 116 package tests, 20 app-model tests, and 15 UI tests

## 2026-07-27. Setup redesign installation

- Pushed setup commit `cd07fd4` to `main`
- Rebuilt the exact commit with the `Samadhi Development` profile and verified the embedded application identifier and code signature
- Installed over the existing iPhone app without uninstalling or replacing its data container
- Confirmed the selected-collection checksum remained byte-for-byte identical
- Launched Samadhi and confirmed its process was running on the physical iPhone

## 2026-07-27. Setup craft refinement

- Distilled Bump's continuity and causal response, Flighty's obviousness, Things' object transformation, Crouton's reduction, and Apple's accessibility guidance into one quiet playlist instrument
- Kept playlist identity mounted while status and actions hand off in stable regions
- Added immediate picker-row response, semantic current selection, compact native picker sizing, and deterministic empty, selected-loading, long-name, and large-library fixtures
- Replaced generic progress with an exact model-derived rail and split ready truth from skipped-result disclosure
- Reordered result details around recovery, with failed reasons first, temporary retry beside its section, and ready tracks last
- Added one causal selection confirmation and one first-valid-readiness confirmation without replay on restoration
- Reflowed accessibility sizes into a top-led document layout and replaced positional transitions with immediate state truth under Reduce Motion
- Corrected two first-pass defects after video review: skipped-disclosure contrast and old/new content overlap during readiness
- Passed formatter lint, 118 package tests, 25 app-model tests, 21 serial UI tests, and two visual iteration passes across 17 final Simulator frames

## 2026-07-27. Setup craft installation

- Pushed setup-craft commit `0a59b64` to `main`
- Rebuilt the exact commit with the `Samadhi Development` profile and verified its embedded application identifier and strict code signature
- Installed over the existing iPhone app without uninstalling or replacing its data container
- Confirmed the selected-collection checksum remained byte-for-byte identical
- Attempted foreground launch repeatedly but left it open because the phone was locked

## 2026-08-14. MacBook continuation gate

- Cloned `main` into `Projects/active/samadhi` and added the `/Users/samaydhawan/samadhi` convenience link
- Installed one iOS 27 runtime and retained one iPhone 17 Pro Simulator only
- Passed the local `Scripts/test.sh` gate with 118 Swift package tests and 46 serial Simulator tests
- Confirmed an Apple Development identity is available locally
- Kept physical-device work open because the iPhone is unavailable to this MacBook
- Added the MacBook continuation, storage, signing, and pairing guide, then aligned the active status, plan, testing, and device-runbook surfaces with historical profile evidence

## 2026-08-14. Core reset software baseline

- Added build-generated commit, branch state, build date, app version, and build number to Debug evidence
- Extended the existing run diagnostic file to version 6 with analyzer details, song pulse, step relationship, current Auto-target truth, resulting speeds, and remaining difference
- Added one hidden Debug screen that separates musical BPM from step rhythm in SPM and shows the complete Apple Music request and reply
- Cleared prior-song read-back and result values on every confirmed song change, then required a fresh identified reply for the new song
- Added deterministic coverage for the current behavior matrix, including low-tempo two-step music, both direction changes, a false spike, song limits, the tempo-wheel return trap, delayed and rejected replies, route loss, pause, and song changes during Manual
- Inspected seven fresh iPhone 17 Pro Simulator frames covering low-tempo math, waiting, verified, limited, rejected, song reset, accessibility XXXL, and Reduce Motion
- Passed formatter lint, 121 package tests, 27 app-model tests, 25 serial UI tests, and a resource-inclusive Release Simulator build
- Built successfully for the paired iPhone, found only a wildcard profile, and did not install it or change app data

## 2026-08-15. Exact phone baseline and track-scoped Manual

- Created and downloaded `Samadhi Development 2026-08-15` for the exact Samadhi application identifier
- Inspected the embedded profile and app signature, then installed over the existing phone app without uninstalling
- Confirmed the selected collection checksum stayed byte-for-byte unchanged
- Launched the baseline build and saved its base commit, dirty state, build time, and phone environment
- Captured one short real-phone run with raw Core Motion cadence and identified Apple Music replies
- Recorded 16 numeric cadence readings from 151.56 to 158.10 SPM; 14 exceeded the 2.0-second freshness limit at about 2.57 seconds old, so only two were accepted and Auto could not lock
- Recorded Apple Music replies in about 0.04 to 0.07 seconds for Manual and Auto commands
- Made Manual persist through same-song pause, resume, route loss, recovery, and unconfirmed transport requests
- Made Manual return to Auto only after the player confirms a different song, with no inherited result or late old-song verification
- Added one accessible tempo-wheel close action that restores playback controls without changing rhythm or playback
- Inspected fresh Simulator frames for Manual before and Auto after a confirmed song change, close restoration, accessibility XXXL, and Reduce Motion
- Passed bootstrap, formatter lint, 124 package tests, 27 app-model tests, 27 serial UI tests, and a resource-inclusive Release Simulator build
- Rebuilt and installed the final Manual/close candidate in place; the phone locked before an in-app read-back

## 2026-08-17. Continuation audit

- Rechecked local and fetched remote `main` at `4f5394f3158dde9ad891b8b772b197c4c26090b2`
- Confirmed the phone is paired and still reports Samadhi 1.0 build 1
- Re-read the saved phone trace and found the Auto acquisition blocker: 14 of 16 numeric cadence readings were about 2.57 seconds old and failed the 2.0-second freshness limit
- Corrected build claims: the screen records base commit, dirty state, and build time, but not the exact dirty source changes
- Reran bootstrap, formatter lint, 124 package tests, 27 app-model tests, 27 serial UI tests, and a resource-inclusive Release Simulator build

## 2026-08-17. Trustworthy Auto software slice

- Added a pre-compilation source fingerprint covering behavior-changing app inputs, including modified and untracked files
- Replayed the saved phone cadence shape and accepted delayed readings only when Core Motion time moves forward coherently
- Preserved rejection of old, repeated, backward, out-of-order, unexplained-gap, missing, and out-of-range readings
- Added a separate time-based Auto target that holds through ordinary noise and one spike, then moves after sustained evidence
- Replaced the glass close bubble with a small flat mark outside the dial while retaining a 44-point touch target
- Inspected normal, accessibility XXXL with Reduce Motion, and Increased Contrast Simulator frames
- Passed bootstrap, formatter lint, 136 package tests, 27 app-model tests, 28 serial UI tests, and resource-inclusive Debug and Release Simulator builds
- Built with the exact Samadhi profile, verified fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498`, and installed in place
- Confirmed the selected collection stayed byte-for-byte unchanged; the phone locked before the in-app fingerprint read-back

## 2026-08-17. Fingerprinted workout and Auto interaction decision

- Pulled the completed workout diagnostic from the physical phone and matched its source fingerprint to the exact-profile candidate
- Confirmed the timing repair on real motion: four supported delayed readings acquired 133 SPM
- Confirmed one exact Apple Music response: 1.0390625 requested and reported after 0.066 seconds
- Recorded that 57 of 61 retained numeric readings were below the current 120 SPM contract without assigning each reading to walking, jogging, or lifting
- Preserved Samay's raw workout and interaction feedback as two immutable handoff addenda with checksums
- Recorded Samay's judgment that Auto was perceptible but its transitions felt jarring and unexplained
- Rejected temporary screen copy as the solution because the phone is normally not visible
- Defined a later two-part nonvisual interaction: a distinct faster or slower haptic at first verified movement, then one authored sound and settling haptic at verified arrival
- Kept that interaction behind the walking, approximate-match, and transport and Finish work
- Corrected the workout interpretation after Samay clarified that substantial lifting occurred during the 30-minute period
- Removed the unsupported claim that the summary undercounted a known amount; kept walking-range expansion open and lifting-specific adaptation out

## 2026-08-17. Walking and approximate alignment

- Measured the mixed workout without claiming which exact readings came from walking or lifting
- Chose a conservative 90 SPM floor; values from 80 through 89 remain outside Auto
- Required five seconds of steady evidence for walking while keeping the faster running acquisition path
- Prevented missing or disagreeing rep-like movement from accumulating a walking target
- Found and fixed a deeper separation bug: raw cadence could command playback before the settled Auto target existed
- Kept the Apple Music playback range at 0.90 through 1.10
- Expanded approximate alignment from three to five SPM; six SPM still fails
- Measured privacy-safe coverage across 15 ready private tracks without storing titles or identifiers
- Renamed Debug output from running pulse to step rhythm and advanced the diagnostic file to version 9

## 2026-08-17. Expanded playback candidate

- Widened the shared Apple Music playback candidate from 0.90 through 1.10 to 0.85 through 1.15 at Samay's direction
- Kept Auto changes limited to 0.02 rate units per second, which reaches either endpoint from normal speed in at most eight seconds
- Applied the same bounds to Auto, Manual, track selection, diagnostics, and the final Apple Music command
- Added Debug controls that compare the known 0.90 and 1.10 pair with the new 0.85 and 1.15 endpoints
- Added deterministic endpoint, ramp, Manual-boundary, track-fit, command-clamp, and five-SPM tolerance checks
- Fixed floating-point rounding that could reject a result exactly five SPM from target
- Passed bootstrap, formatter lint, 153 package tests, 27 app-model tests, 28 serial interface tests, source-fingerprint tests, and resource-inclusive Debug and Release Simulator builds
- Confirmed the hidden Debug screen remains absent from Release
- Built with the exact Samadhi profile and verified source fingerprint `fd8120ad2ac14e1090a687438e6564beb65bde0a61d58fab04d4ec7295535684`
- Installed over the existing phone app without uninstalling and preserved the selected collection byte-for-byte
- Kept endpoint Apple Music read-back, sound quality, and long-form reliability open because the phone locked before launch

## 2026-08-17. Core reset consolidation

- Rewrote the public README and current status around the code and evidence that exist today
- Removed one redundant handoff rewrite and one completed continuation prompt while preserving every original handoff file and checksum
- Kept the raw phone diagnostic and personal lock-screen capture local and ignored in this public repository
- Corrected stale evidence links and marked old playback limits as historical measurements
- Confirmed that this repository has one worktree, with no stale worktrees to merge or remove
- Passed bootstrap, formatter lint, 153 package tests, 27 app-model tests, 28 serial interface tests, and resource-inclusive Debug and Release Simulator builds
- Confirmed that the hidden developer screen is absent from the Release app

## 2026-08-18. Transport, causes, and Auto feedback candidate

- Replaced the three floating transport pills with one continuous glass capsule bar carrying Previous, Pause or Resume, and Next
- Chose the raised primary disc over hairline dividers because the disc names the primary action without adding two lines, keeps the bar one object, and gives the paused state somewhere to live
- Reproduced the Finish overflow on 30 fps video before the change and found the first cause: a resting 136 by 48 point Finish pill and a 190 by 54 point hold pill crossfading in the same slot, with both borders and both labels visible for about eight frames
- Found the second cause: the hold progress fill was a background capsule drawn behind the glass shape, so it neither clipped to the pill nor followed the pressed scale and showed a second edge offset below and left
- Found a third defect on video during the work: SwiftUI crossfaded the words `Finish` and `Hold to finish` even inside one view
- Made Finish and the hold one button whose word and width change in a single frame, with the fill drawn behind the label and clipped by the same capsule before any glass or stroke
- Shared `FinishHold.durationSeconds` between reducer scheduling, the long-press minimum, and the fill animation
- Kept the determinate fill sweeping under Reduce Motion and turned off only the press compression
- Added one selection tick for an accepted Previous or Next tap and a soft impact when Finish arms
- Added `finishHoldPressing` so `Keep holding to finish` appears only while the hold is actually pressing
- Moved the Auto feedback decision into the reducer as one identified transaction with a committed origin, a verified start, and a verified arrival
- Limited each transaction to at most one start and one arrival, and blocked cues for raw or filtered cadence, an unsettled candidate, intermediate ramp replies, pending, mismatched, rejected, and stale replies, a reaffirmed target, a Previous or Next tap, and an old song
- Made a new qualifying target replace the transaction in flight silently, and made manual takeover, a lost Auto target, route loss, interruption, playback failure, and finish all stop it without replay on recovery
- Added `externalUnknown` and a pure attribution rule: a claimed Previous or Next inside five seconds, otherwise a natural end only when the previous song was within 10 seconds of its duration, otherwise an outside change
- Recorded the cause on every confirmed song change and showed it in the hidden Debug screen as `Last song change`
- Recorded the same-song callback as its own diagnostic entry while the reducer keeps ignoring it
- Added scripted simulated player events for a natural boundary, an external boundary, an interruption, an interruption end, and a same-song callback, each behind its own launch flag
- Scheduled the scripted interruption end after recovery starts, because entering recovery cancels every task
- Advanced the run diagnostic file to version 10 with the Auto cue transaction, phase, direction, size, change in SPM, and limit flag, and added no song or playlist name
- Added `AutoFeedbackService`: one lazy Core Haptics engine with audio allowed, stopped and reset handlers, dropped cached players and re-registered audio on reset, and sound still playing through a local player when the device has no haptic hardware
- Built three prototype families, pulse, swell, and step, as 24 AHAP files: six start patterns per family across two directions and three size bands, plus one arrival pattern per direction, with start spans from 0.160 to 0.240 seconds
- Scaled size by peak intensity only, at 0.45, 0.65, and 0.95, so the event order and the learned direction never change
- Generated six arrival sounds with the Python standard library at 48 kHz, mono, 16-bit, 0.310 to 0.375 seconds, each peaking at exactly -9.00 dBFS with RMS from -17.3 to -21.0 dBFS
- Recorded the parameters and SHA-256 of every sound in `Evidence/Audio/2026-08-18-auto-feedback-prototypes/sound-manifest.json`
- Added a Debug-only audition screen with family, direction, size, sound path, both toggles, and a 10-trial blinded mode with a visible seed and a copyable score
- Confirmed the audition screen is absent from Release by reading `Samadhi.debug.dylib`, because the Debug `Samadhi.app/Samadhi` is a launcher stub that reports zero matches for everything
- Inspected 39 Simulator images covering five environments, including a 54-frame hold contact sheet, and wrote both evidence READMEs without song titles, playlist names, or account details
- Passed formatter lint, 179 package tests, 39 app-model tests, 32 serial interface tests, source-fingerprint tests, and resource-inclusive Debug and Release Simulator builds
- Made no phone build and installed nothing, so no source fingerprint exists for this candidate
- Recovered from the MacBook data volume reaching 100 percent by deleting XCTestDevices clones and two stale DerivedData folders, which left 29 GiB free

## 2026-08-19. Phone install of the candidate

- Verified `main` and `origin/main` at `67adf80`, a clean tree, one worktree, and no leftover packet branches before building
- Built the `Samadhi` scheme for the paired iPhone with exact profile `Samadhi Development 2026-08-15`, UUID `1b613344-c5cd-4802-a31f-9ff5088c1802`, and confirmed `ZL5U59XBJ6.com.samaydhawan.Samadhi` in the embedded profile and the signature entitlements
- Confirmed the built Info.plist fingerprint `8df37f8dca11dfa0ad38346b2ea2339a5d76c9a10c4a539b471d8a1ea7df02e6` equals `Scripts/source-fingerprint.sh` on the same checkout
- Installed in place over Samadhi 1.0 (1) without uninstalling; the selected collection stayed byte-identical at SHA-256 `51b4096c...`, a value the app itself had rewritten on August 18 after the previous install
- Launched the app on the unlocked phone, opened the hidden Debug screen with `--core-diagnostics`, captured it with `devicectl`, and read the same fingerprint in the app
- Built the `Samadhi Feedback Audition` scheme for the phone from the same bundle and did not install it separately
- Recorded the install in `Evidence/Device/2026-08-19-phone-install/` with the Debug screenshot and no song or playlist names

## 2026-08-19. Catalog ties stop dropping songs

- Read the pulled collection file from the phone: 9 of 17 songs in the selected playlist were not ready, 5 as `catalogMatchUnavailable` and 4 as `rhythmUnclear`
- Traced every `catalogMatchUnavailable` song to a library item with no ISRC, a non-numeric library identifier, and a strict metadata search that returned the explicit and clean edits as an exact tie, which the resolver rejected as ambiguous
- Added a catalog lookup by the `catalogId` carried inside the library item's encoded play parameters before the metadata search
- Moved the tie decision into `CatalogMatchSelection`, a pure rule: same content rating as the library track wins, explicit wins when the library rating is unknown, otherwise closest duration then identifier
- Left `rhythmUnclear` alone, because those songs resolved and the analyzer judged the preview itself
- Added five app-model tests for the rule; the count is now 44
- Not yet on the phone. The selected playlist must be chosen again in the app after the next install so the unmatched songs resolve again

## Current checkpoint

The transport and Finish pass, deterministic song-change causes, and the first directional Auto feedback prototype are merged on `main`, pass the software gate, and are installed on the phone with the in-app fingerprint confirmed. Endpoint read-back and listening at 0.85 and 1.15 carry over from the previous candidate, and tactile feel, sound quality, locked-screen delivery, and Apple Music coexistence have no result at all. The next step is the ordered checklist in [PHONE-CHECK-2026-08-19.md](PHONE-CHECK-2026-08-19.md) from step 2 onward. After it, the next Main Thing is the 20-minute outdoor run.
