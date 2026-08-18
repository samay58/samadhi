# Core reset map

## Intended result

Samadhi should make one real run feel better. It should find a stable relationship between movement and music, tell the truth about what happened, allow a temporary current-song Manual intervention, then get out of the way. The reset is done only after the 20-minute physical run gate passes. Source: `original/pasted-text.txt:45-80,1526-1566,1832-1841`.

## Authority boundary

The handoff is authoritative about Samay's experience, dissatisfaction, priorities, and desired outcome. Its technical remedies remain hypotheses. Current source, current build, tests, platform interfaces, device traces, listening, body feel, and Samay's judgment decide implementation. The first substantive deliverable is an adversarial review, not a behavior diff. Source: `original/pasted-text.txt:10-42`.

## Product promise and non-negotiables

- Preserve the minimal body-aware music-player scope. Source: `original/pasted-text.txt:45-80,1663-1688`.
- Establish build and tempo truth before visual work. Source: `original/pasted-text.txt:63-79,732-959`.
- Keep the functional-core, main-actor-shell architecture unless a concrete failure disproves it. Source: `original/pasted-text.txt:100-124`.
- Keep source musical tempo, cadence projection, observed cadence, requested target, commanded rate, applied read-back, and effective result separate. Source: `original/pasted-text.txt:266-282,409-468,580-628`.
- Treat MusicKit read-back as applied truth. Do not claim beat phase, cadence quality, audio quality, or polish without matching evidence. Source: `original/pasted-text.txt:272-282,309-325,1568-1599`.
- Manual is a temporary current-song override. Confirmed Previous, Skip, or natural boundary returns the new track to Auto. Source: `original/pasted-text.txt:172-176,490-507,566-578`.
- Auto should use responsive sensing and a separate calm target-selection policy. Source: `original/pasted-text.txt:178-182,439-449,469-488`.
- The authored Auto completion cue is required later, but only after a meaningful target change receives verified MusicKit read-back. Source: `original/pasted-text.txt:220-226,1291-1394`.
- Auto changes must be understandable without looking at the phone. Temporary screen copy is rejected. The accepted direction is a distinct faster or slower haptic when verified movement begins, followed by a quiet authored arrival after final Apple Music read-back. Coarse strength may express size, but physical testing must approve the patterns. Source: `original/addendum-02-workout-feedback.txt`; `original/addendum-03-transition-haptics-priority.txt`; `Docs/AUTO-CHANGE-INTERACTION-SPEC.md`.
- Play, pause, previous, next, and Finish must become exceptional buttons in appearance and behavior. Haptics are only one part. Fix the Finish border overflow, then judge shape, clipping, layout, pressed response, grouping, accessibility, and physical feel as one control system. Source: `original/addendum-01-buttons.txt`.
- Do not use a warehouse, Run Set, or visual redesign to hide a broken core loop. Source: `original/pasted-text.txt:644-665,1165-1289`.

## Baseline repository facts

Checked on August 14, 2026.

- Local `main` and freshly fetched `origin/main` both point to `4f5394f3158dde9ad891b8b772b197c4c26090b2`.
- The worktree already contained user-owned documentation edits before this handoff. They remain untouched.
- Xcode 27.0 build `27A5209h`, XcodeGen 2.45.4, Swift 6.4, and one booted iPhone 17 Pro Simulator are available.
- The machine-wide developer directory points at Command Line Tools. Repository commands work when `DEVELOPER_DIR` points at `/Applications/Xcode-beta.app/Contents/Developer`.
- Samay's iPhone 17 Pro is currently paired and available. This supersedes the uncommitted MacBook note saying it is unavailable.
- The phone contained Samadhi version 1.0 build 1. The source commit of that installed binary could not be identified at that time.
- Two valid signing identities exist. Exact App ID provisioning still requires proof from a newly signed build's embedded profile.
- Project generation and formatter lint pass. The current full serial software gate is being rerun for this review.

Current updates on August 16, 2026:

- Freshly fetched `origin/main` and local `main` still point to `4f5394f3158dde9ad891b8b772b197c4c26090b2`.
- The worktree contains 21 modified tracked files plus new diagnostics, evidence, handoff files, and build tooling. These changes are not committed.
- The paired iPhone is available and still reports Samadhi version 1.0 build 1.
- Exact Samadhi signing passed. One baseline build was opened and recorded. The saved installation record says the final Manual/close candidate was inspected and installed in place, but it was not opened because the phone locked. Live device read-back exposes only version 1.0 build 1.
- The build screen records the base commit, dirty flag, and build time. It does not hash dirty source changes, so it cannot reconstruct the exact source tree.
- The full candidate gate passed 124 package tests, 27 app-model tests, 27 serial interface tests, formatter lint, and a Release Simulator build.
- The phone trace exposed a new blocker: 14 of 16 numeric cadence readings were about 2.57 seconds old and failed the fixed 2.0-second freshness check.

Current updates on August 17, 2026:

- Freshly fetched `origin/main` and local `main` still point to `4f5394f3158dde9ad891b8b772b197c4c26090b2`. The user-owned dirty tree was preserved through the reset and consolidated into one reviewed release commit.
- Every new build carries a stable fingerprint for the exact behavior-changing source, resources, configuration, and build scripts used. Modified and untracked inputs are covered. Documentation, evidence, app data, diagnostics, credentials, and signing files are excluded.
- The saved delayed phone pattern now acquires in deterministic replay. Old first samples, repeats, backward timestamps, out-of-order callbacks, unexplained gaps, missing values, and values outside 90 through 210 SPM still fail.
- Auto now keeps the responsive sensor estimate separate from a settled musical target. Ordinary noise and one spike do not move the target. Sustained faster or slower evidence does.
- The close action is a small flat mark outside the dial with a separate 44-point touch target. Normal, accessibility XXXL, Reduce Motion, and Increased Contrast frames were inspected.
- The latest expanded-rate gate passed 153 package tests, 27 app-model tests, 28 serial interface tests, formatter lint, source-fingerprint tests, and resource-inclusive Debug and Release Simulator builds. The hidden Debug screen is absent from Release.
- Exact Samadhi signing passed. Fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498` was verified in the built app, then installed in place. The selected collection stayed byte-for-byte unchanged. The phone locked before the fingerprint could be read from inside the app.
- Samay later opened that fingerprinted build and used it during a workout. The pulled file confirmed the fingerprint, real phone motion, real Apple Music, safe acquisition at 133 SPM, and an exact 1.0390625 Apple Music read-back after 0.066 seconds.
- The retained trace contains 61 numeric cadence readings. Fifty-seven were below the current 120 SPM running range. The workout mixed brisk walking, light jogging, and substantial lifting, so those readings cannot all be assigned to walking. Walking-range expansion and approximate alignment remain core product questions. Lifting-specific adaptation is not needed now. Source: `original/addendum-04-workout-context-correction.txt`.
- Samay felt Auto working, but the transitions felt jarring and unexplained. This accepts the need for nonvisual directional feedback while leaving its exact haptic and sound family unproved.
- Samay chose a 0.85 through 1.15 playback candidate. One shared limit now controls Auto, Manual, track fit, diagnostics, and the final player command. The exact-signed build is installed with app data preserved. Apple Music endpoint read-back and listening remain open.

## Conflicts found on August 14

- Resolved: Manual survived a confirmed track change. It now returns to Auto only after the player confirms a different song. Same-song recovery preserves Manual.
- Auto still exposes a user-facing correction from minus 20 through plus 20 BPM. Code: `Packages/SamadhiKit/Sources/SamadhiDomain/RhythmControl.swift:44`.
- Resolved on August 17: Auto target selection is now a separate time-based policy. The responsive filtered cadence remains available without making the musical target chase ordinary noise.
- Resolved on August 17: the observed 2.57-second delivery pattern acquires when Core Motion time advances coherently. Deterministic replay and the fingerprinted workout both confirm it.
- The primary dial says BPM and shows the cadence-like request. Its subordinate Music value is calculated from analyzed musical BPM times applied rate. Low-tempo tracks therefore expose two defensible but unexplained numbers. Code: `Packages/SamadhiKit/Sources/SamadhiDesign/RhythmControl.swift:101`, `App/RunPresentationModel.swift:119`, `App/RunPresentationModel.swift:698`.
- Resolved: the tempo editor now has an accessible close action that restores transport without changing playback or rhythm ownership.
- The aperture uses a locally generated periodic phase at the displayed applied musical BPM. It is not aligned to the streamed song's audible phase. Code: `Packages/SamadhiKit/Sources/SamadhiDesign/TempoAperture.swift:35`.
- Import loads at most 100 playlists in one request, hydrates only `playlist.tracks`, and does not paginate. Code: `App/AppleMusicImportService.swift:88`.
- Import outcomes are typed, but several Phase 0 census distinctions are collapsed. Resolver ambiguity and no catalog match both become `catalogMatchUnavailable`; low confidence, ambiguous rhythm, and no supported cadence projection become `rhythmUnclear`. Code: `App/AppleMusicImportService.swift:190`, `Packages/SamadhiKit/Sources/SamadhiDomain/MusicModels.swift:132`.
- Resolved: diagnostics record the base commit, dirty state, source fingerprint, build time, device, operating system, analyzer version, analysis confidence, launch mode, and complete speed-change chain. The fingerprint covers modified and untracked behavior-changing inputs without exposing their contents.

## Platform findings rechecked locally

- The installed MusicKit interface exposes writable `MusicPlayer.State.playbackRate`.
- It exposes playlist creation and editing with items.
- `MusicLibraryRequest` exposes limit and offset. `MusicItemCollection` exposes next-batch APIs.
- Preview assets are exposed. No BPM or tempo field appears in the installed MusicKit song interface.
- Core Motion exposes live `currentCadence` and `isCadenceAvailable`.

These checks support the handoff's capability claims but do not prove runtime quality. Source hypotheses: `original/pasted-text.txt:285-369`.

## Affected systems

| System | Phase 0 question | Later dependency |
| --- | --- | --- |
| Build and signing | Which source produced each run? Can this Mac sign the exact App ID? | Every physical claim |
| Domain ownership | What owns Auto, Manual, and track-scoped state? | Mental model, transitions, summary |
| Motion | What is observed versus what Auto commits? | Calm Auto |
| Tempo analysis | Is source rhythm accurate and honestly classified? | Track fit, limits, Run Set |
| Playback | Did MusicKit apply the intended rate? | Truth UI, completion cue, summary |
| Import | Where does each source item fail? | Warehouse and music coverage |
| Presentation | Which one number belongs on the run surface? | Core UX and accessibility |
| Diagnostics | Can every claim be traced to its source state, build time, and active identities? | All review and release evidence |
| Physical quality | Is the change audible, clean, tactile, and useful while moving? | Release gate |

Source: `original/pasted-text.txt:409-730,732-1566`.

## Dependency order

1. Record the environment and identify the source used for each build.
2. Complete the adversarial review and baseline test matrix.
3. Expose the complete rhythm-to-music calculation without changing Release behavior.
4. Build the tempo disagreement corpus and import failure census.
5. Decide the ownership and settled-target model.
6. Implement the smallest coherent core-model repair.
7. Prove the rate envelope, walking decision, and aperture meaning.
8. Improve identity resolution only from census evidence.
9. Build a warehouse and deterministic Run Set only if the one-playlist core succeeds.
10. Rebuild transport and Finish as one coherent control system.
11. Prototype the verified directional Auto feedback after core matching behavior is settled.
12. Pass the complete outdoor reliability gate.

Ordering reason: later work depends on earlier truth. Source: `original/pasted-text.txt:732-1566,1690-1700`.

## Risks and assumptions

- The older baseline run is tied to a base commit, dirty flag, and build time, but its exact dirty source cannot be reconstructed because that build predates source fingerprinting. Every newer build records a deterministic source fingerprint. Source concern: `original/pasted-text.txt:140-146`.
- Preview tempo may not represent a full streamed edit. Scalar tempo never proves phase. Source: `original/pasted-text.txt:309-325,395-406`.
- The inner 0.90 through 1.10 pair is backed by one-track perceptibility, not broad artifact evidence. The 0.85 through 1.15 candidate has software and installation proof but no endpoint listening result. Source: `original/pasted-text.txt:315-319,1089-1130`.
- The proposed Auto thresholds are search ranges, not accepted constants. Source: `original/pasted-text.txt:988-1023`.
- Device availability, exact signing, dirty-source fingerprinting, repaired acquisition, and one listening judgment are no longer blockers. Haptic quality, locked-screen cue delivery, walking behavior, and sustained outdoor feel remain open.
- The handoff contains a much larger program than one implementation session. Completion must remain packet-based, with evidence at each boundary.

## Human decisions reserved for Samay

Mental model, rhythm-and-music legibility, rate envelope, Auto feel, completion cue, Run Set coherence, supporting visual craft, and icon selection. Source: `original/pasted-text.txt:1601-1661`.

## Blocking questions

None. The next physical gate is the installed 0.85 and 1.15 endpoint comparison plus a clean walking check. If it passes, the next Main Thing is the transport and Finish craft pass. Directional Auto feedback remains specified but later. Lifting-specific adaptation stays out.
