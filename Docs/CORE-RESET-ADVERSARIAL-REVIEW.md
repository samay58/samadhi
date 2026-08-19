# Core reset adversarial review

## Result

The handoff is directionally right. The core reset should proceed, but not as one large implementation.

Current evidence confirms one remaining presentation problem and two repaired software problems that still need phone proof:

- The prior cadence freshness rule rejected the observed phone delivery pattern before Auto could lock. The saved pattern now acquires in replay.
- Auto sensing and Auto target selection are now separate policies.
- The run surface exposes cadence-like BPM beside musical BPM without a clear hierarchy.

The repository already contains much of the requested truth data, stale-callback protection, typed import handling, and transport authority. Phase 0 should extend those seams instead of rebuilding them.

The follow-up implementation made Manual belong to the confirmed song and added an explicit tempo-wheel close action. A different confirmed song returns Manual to Auto and starts with no inherited Apple Music result. Same-song pause, resume, route loss, recovery, and unconfirmed transport requests keep Manual active.

## Proof labels

- Code-verified: established from current `main` source and tests.
- Software-verified: established by the current formatter, build, or automated gate.
- SDK-verified: established from the installed Xcode 27 SDK interface.
- Device-visible: established by current device discovery or installed-app metadata.
- Historical: established only by committed repository evidence.
- Unverified: requires a current device trace, listening check, body-feel test, or Samay decision.

These labels follow the handoff's validation boundary. Source: `Docs/Handoffs/2026-08-14-master-handoff/original/pasted-text.txt:1568-1599`.

## Current environment

| Item | Result | Proof |
| --- | --- | --- |
| Repository | `/Users/samaydhawan/Projects/active/samadhi` | Direct path read-back |
| Branch | `main` | Git read-back |
| Local HEAD | `0f51c63c7f37164dc9895ffbdd5133576cf7f805` | Git read-back |
| Fresh `origin/main` | Same SHA | `git fetch` and Git read-back |
| Working tree | Clean after the reviewed core-reset consolidation | `git status --short` |
| Xcode | 27.0, build `27A5209h` | Tool read-back |
| XcodeGen | 2.45.4 | Tool read-back |
| Swift | 6.4 | Tool read-back |
| Active developer directory | Command Line Tools | `xcode-select -p`; repository commands require explicit `DEVELOPER_DIR` |
| Simulator | iPhone 17 Pro, iOS 27.0, booted | CoreSimulator read-back |
| Physical device | Samay's iPhone 17 Pro, paired and available | CoreDevice and Xcode destination read-back |
| Installed Samadhi | Version 1.0, build 1 | Device app read-back |
| Baseline source record | Base commit `4f5394f3158dde9ad891b8b772b197c4c26090b2`, tracked files dirty, build time, plus a deterministic source fingerprint | Hidden Debug screen and local diagnostic export |
| Signing identities | Two valid identities | Keychain read-back |
| Fresh phone build | Succeeded | `xcodebuild` for the physical destination |
| Fresh provisioning | Exact `Samadhi Development 2026-08-15`, expires August 15, 2027 | Embedded profile inspection |
| Fresh signed entitlement | Exact application identifier requested by the built app | Code-signature inspection |
| MusicKit signing readiness | Passed | Embedded profile and signature use `ZL5U59XBJ6.com.samaydhawan.Samadhi` |

Exact signing is available. The fingerprinted Auto candidate with fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498` produced the saved workout evidence. The later expanded-rate candidate with fingerprint `fd8120ad2ac14e1090a687438e6564beb65bde0a61d58fab04d4ec7295535684` was inspected and installed in place with the selected collection preserved. It has not yet been opened and read back inside the app.

The selected collection stayed byte-for-byte unchanged across installation.

## Current software gate

Rerun on August 17, 2026 against the source consolidated into current `main`:

- XcodeGen project generation: passed.
- Swift formatter lint: passed.
- Swift package tests: 153 passed.
- App-model tests: 27 passed.
- UI tests: 28 passed.
- Exact-profile physical build and in-place installation: passed.
- Resource-inclusive Release Simulator build: passed.
- Hidden Debug screen absent from Release: passed.

Software health is not the product gate. It proves a stable baseline for Phase 0 work.

The Debug screen was inspected in fresh Simulator frames. It shows the base commit, dirty state, source fingerprint, build time, separate BPM and SPM values, settled Auto target, the current song's full speed-change chain, and distinct waiting, verified, limited, and rejected results. It remains usable at accessibility XXXL with Reduce Motion. The normal Release interface does not contain this screen.

## Architecture judgment

Keep the current architecture. The reducer owns run state. The app shell owns time, tasks, haptics, Core Motion, MusicKit, and persistence. Events and effects carry session, operation, request, track, acquisition, timeout, and selection identities. Current tests show those identities reject stale work.

The reported problems come from product rules and missing Debug evidence, not from the functional-core boundary. Replacing the architecture would increase risk without addressing the complaints.

Source: `Docs/Handoffs/2026-08-14-master-handoff/original/pasted-text.txt:100-124`; code: `Docs/ARCHITECTURE.md`, `Packages/SamadhiKit/Sources/SamadhiDomain/RunReducer.swift`, `App/RunPresentationModel.swift`.

## Current behavior traces

### Auto

```text
CMPedometer currentCadence
  -> CoreMotionCadenceProvider
  -> CadenceFilter
  -> RunEvent.cadenceUpdated
  -> RunReducer
  -> AdaptationPolicy
  -> RunEffect.setPlaybackRate
  -> AppleMusicPlaybackController
  -> MusicKit playbackRate read-back
  -> RunEvent.playbackRateApplied
  -> identified reducer acceptance or rejection
  -> presentation and diagnostics
```

The saved phone trace showed 16 numeric readings. Fourteen were about 2.57 seconds old and failed the old fixed 2.0-second freshness limit. The new rule accepts a delayed reading only after a fresh or untrusted baseline is followed by a strictly advancing Core Motion timestamp within the observed delivery interval. One old sample cannot establish freshness. Repeated, backward, out-of-order, and unexplained-gap samples still fail.

After acquisition, a separate time-based policy owns the settled musical target. It ignores ordinary noise and one spike, holds during short uncertainty, and moves only after sustained agreeing evidence. These defaults pass deterministic replay but are not physically tuned.

Code: `Packages/SamadhiKit/Sources/SamadhiMotion/CadenceFilter.swift:44`, `Packages/SamadhiKit/Sources/SamadhiDomain/AdaptationPolicy.swift:190`, `Packages/SamadhiKit/Sources/SamadhiDomain/RunReducer+Adaptation.swift:275`.

### Manual

```text
wheel drag
  -> local detent preview and haptic
  -> one absolute target on finger-up
  -> RunEvent.rhythmControlTargetCommitted
  -> RhythmControlState becomes Manual
  -> same AdaptationPolicy and rate effect
  -> MusicKit read-back
  -> Applied or Rejected
```

This is a sound implementation seam. Manual now persists only while the player confirms the same song.

Code: `Packages/SamadhiKit/Sources/SamadhiDesign/RhythmControl.swift:218`, `Packages/SamadhiKit/Sources/SamadhiDomain/RhythmControl.swift:44`, `Packages/SamadhiKit/Sources/SamadhiDomain/RunReducer+Adaptation.swift:120`.

### Confirmed track change

```text
player callback
  -> identified playbackTrackChanged event
  -> reducer clears pending rate and selection work
  -> reducer updates current track
  -> reducer returns Manual to Auto for a different confirmed track
  -> reducer starts fresh adaptation with no old reply
```

Manual survives a Previous or Skip request until the player confirms a different song. A same-song confirmation preserves Manual. A different confirmed song returns to Auto, clears the old reply and delay, and rejects late feedback from the prior song.

Code: `Packages/SamadhiKit/Sources/SamadhiDomain/RunReducer.swift:518`, `Packages/SamadhiKit/Sources/SamadhiDomain/RunReducer+Adaptation.swift:244`, `Packages/SamadhiKit/Tests/SamadhiDomainTests/RunReducerTests.swift:626`.

### Tempo display

The dial's large number is `requestedBPM`. In Auto, that is filtered cadence plus a user correction. The smaller Music value is analyzed musical tempo times applied rate. An 84 BPM song using two steps per beat can therefore show a target near 168 and Music near 84.

Both numbers can be mathematically honest. The current labels make their relationship obscure. The handoff's SPM-first model fixes the category error by naming the large number as runner target rhythm, not song tempo.

Code: `Packages/SamadhiKit/Sources/SamadhiDesign/RhythmControl.swift:101`, `App/RunPresentationModel.swift:119`, `App/RunPresentationModel.swift:698`.

### Tempo editor and transport

The editor offers Auto, Manual, and one native close action. Closing restores transport immediately without changing playback, rhythm ownership, or the current song.

Simulator tests cover normal size, accessibility XXXL, and Reduce Motion.

Code: `Packages/SamadhiKit/Sources/SamadhiDesign/RhythmControl.swift:190`, `Packages/SamadhiKit/Sources/SamadhiDomain/RunModels.swift:329`, `Packages/SamadhiKit/Sources/SamadhiDomain/RunReducer.swift:165`.

### Import

Current import:

```text
one MusicLibraryRequest page of up to 100 playlists
  -> hydrate playlist.tracks
  -> three ordered tracks at a time
  -> ISRC, numeric ID, or strict metadata resolution
  -> preview download
  -> local PCM tempo analysis
  -> typed ready or failed state
  -> atomic collection persistence
```

This is a strong base. It is not the requested census. It does not paginate playlists, compare playlist entries, or distinguish every terminal cause. Resolver ambiguity and no match collapse together. Low confidence, ambiguous rhythm, and unsupported cadence projection collapse together.

Code: `App/AppleMusicImportService.swift:88`, `App/AppleMusicCatalogResolver.swift:5`, `Packages/SamadhiKit/Sources/SamadhiDomain/MusicModels.swift:132`.

### Diagnostics and summary

Diagnostics already separate musical pulse, alternate pulse, running pulse, relationship, requested BPM, derived target rate, commanded rate, applied read-back, applied musical tempo, applied running pulse, latency, limit state, and command status.

The diagnostic file and hidden Debug screen now include the base commit, dirty state, source fingerprint, build time, device and operating system, real or simulated services, launch options, analyzer version, analysis confidence, analyzed duration, settled Auto target and status, sensor sample status, and remaining difference from the requested rhythm.

The summary correctly requires verified read-back and at least 80 percent measurement coverage before showing tempo matched. Fixed rhythm remains Not measured. Keep this contract.

Code: `App/RunDiagnosticsStore.swift:4`, `App/RunPresentationModel.swift:663`, `Packages/SamadhiKit/Sources/SamadhiDomain/RunModels.swift:102`.

## Feedback classification

| Feedback | Current judgment | Evidence or next proof |
| --- | --- | --- |
| F-001 core reset | Confirmed priority | Product docs and handoff agree: one physical run is the finish line. |
| F-002 Auto and Manual confusion | Current presentation defect | Code exposes cadence-like request and musical BPM as competing BPM values. Current-device comprehension remains a human gate. |
| F-003 unexplained limits | Current presentation defect with valid underlying policy | Per-song envelope is code-verified. Current copy says only `Limit`. Keep the boundary until listening evidence changes it. |
| F-004 Manual follows song changes | Fixed in software and Simulator | Manual returns to Auto only after the player confirms a different song. Physical song-change proof remains open. |
| F-005 Auto chases motion | Mechanical repair passed; felt behavior still needs work | Raw cadence can no longer command playback before the separate target settles. Walking needs five seconds of steady evidence, and five SPM of remaining error counts as aligned. Physical feel remains open. |
| F-006 Manual is essential | Preserve | Direct manipulation, one final command, limits, haptics, and read-back already exist. Physical fun and feel remain open. |
| F-007 eclectic source hurts mechanic | Plausible, not yet causal proof | One-playlist core must pass before Run Set work. |
| F-008 music warehouse | Technically feasible, deferred | SDK supports pagination. Product need is unproven. |
| F-009 generated run set | Feasible later without an LLM | SDK supports playlist creation. Internal deterministic queue comes first. |
| F-010 too many import failures | Historically credible; cause unknown | A prior 25-track source produced 13 ready. The complete failure census is missing. |
| F-011 Auto lacks understandable proof | Fixed for Debug inspection; product feedback remains open | The hidden screen explains development evidence. Temporary runner-facing text is rejected because the phone is usually not visible. Product feedback must use sparse touch and sound. |
| F-012 completion cue | Accepted later requirement with a stronger design | No cue exists. The later design uses a faster or slower haptic at first verified movement, then an authored sound and settling haptic at final verified arrival. It never follows raw cadence or each ramp step. |
| F-013 editor traps transport | Fixed in software and Simulator | One accessible close action restores playback controls without changing the run. |
| F-014 setup refinement | Potentially stale feedback | Current `main` includes later setup craft. It needs current physical review before another redesign. |
| F-015 transport and finish craft | Complete in software; physical feel open | The three pills became one glass capsule bar with a raised primary region, and Finish became a quiet hold whose fill is clipped by the same capsule. Both reported overflow causes were reproduced on 30 fps video and are gone from the after frames in `Evidence/Simulator/2026-08-18-transport-finish/`. Press feel, haptic character, and daylight legibility remain physical. |
| F-016 summary closure | Existing truthful base, taste unverified | Metric breadth should stay fixed. Visual closure needs a later device review. |
| F-017 authored icon | Deferred taste work | Current icon exists. Recraft intent remains unknown. |
| F-018 portable environment | Partly repaired | MacBook software gate, phone pairing, exact MusicKit provisioning, and in-place install pass. Second-Mac clean-clone proof is absent. |
| F-019 hidden tempo transformation | Fixed for Debug inspection | The complete numerical chain is readable, tied to the exact app build, and covered by low-tempo, result-state, and song-reset fixtures. Runner-facing product copy remains Phase 1 work. |
| F-020 success layers | Accepted validation model | Existing docs already separate tests, Simulator, device, listening, and body feel. Keep the stricter wording. |

Source: `Docs/Handoffs/2026-08-14-master-handoff/original/pasted-text.txt:148-283`.

## Hypothesis verdicts

| ID | Verdict | Reason |
| --- | --- | --- |
| H-001 | Accepted with modification | The fingerprinted candidate produced a real workout trace with real phone motion and Apple Music. Haptic, locked-screen, broader listening, and sustained outdoor proof remain open. |
| H-002 | Accepted with modification | The large runner-facing value should be target SPM. Final copy and hierarchy still require Gate A. |
| H-003 | Accepted | Track-scoped Manual directly matches the explicit user requirement and removes an existing cross-song semantic leak. |
| H-004 | Accepted with modification | Remove Auto correction from the runner-facing model. Retain calibration values only in diagnostics if Phase 0 finds a real need. |
| H-005 | Accepted with modification | Trace replay and the fingerprinted workout now accept the observed delayed pattern safely. Auto has a separate settled target, but Samay found the resulting changes jarring. Physical tuning remains open. |
| H-006 | Accepted as a software candidate; physical verdict deferred | Samay chose 0.85 through 1.15. Deterministic command behavior passes, but only 0.90 versus 1.10 has been heard. Full-song and route evidence is missing. |
| H-007 | Accepted with modification | The software candidate supports steady movement from 90 through 210 SPM and uses longer evidence for walking. The mixed workout cannot label each reading, so the floor and delay still need a clean walking-only phone check. Lifting remains outside Auto. |
| H-008 | Deferred because evidence is unavailable | The 12-track declared-tempo corpus passes, but Samay's representative disagreement corpus does not exist. |
| H-009 | Deferred because evidence is unavailable | Strictness may cause failures, but current outcome classes are too coarse to identify the dominant cause. |
| H-010 | Deferred because evidence is unavailable | The current importer uses `playlist.tracks`. Entry and entry-item coverage has not been compared. |
| H-011 | Refuted | A warehouse is not required before the core loop can succeed. The existing imported playlist already supports a complete run path. |
| H-012 | Deferred because evidence is unavailable | A coherent Run Set is plausible but cannot be credited before the core loop and listening comparison pass. |
| H-013 | Refuted | Random warehouse selection would ignore fit, continuity, confidence, and repeat control. The first planner should be deterministic. |
| H-014 | Accepted with modification | The cue's product role and nonvisual direction are accepted. The exact faster and slower patterns, size bands, sound family, playback mechanism, mix behavior, and phone-lock reliability remain physical decisions. |
| H-015 | Refuted | Passive progress does not need Liquid Glass. Native glass remains reserved for raised interactive controls. |
| H-016 | Deferred because evidence is unavailable | The dictated icon tool is unclear. Ask only at the brand gate. |
| H-017 | Deferred because evidence is unavailable | Current code pulses at applied musical BPM, but it is not stream-phase aligned. Felt honesty has not been compared. |
| H-018 | Deferred because evidence is unavailable | Cadence projection may be more useful, but could imply a false relationship. Compare at the aperture gate. |
| H-019 | Deferred because evidence is unavailable | Preview tempo is the only practical scalar input. Per-track full-edit representativeness is unproven. |
| H-020 | Deferred because evidence is unavailable | Queue logic is identified and tested, but five current physical natural transitions have not run. |

This satisfies the handoff's required terminal status set. Source: `Docs/Handoffs/2026-08-14-master-handoff/original/pasted-text.txt:371-407`.

## Platform claims rechecked against Xcode 27

The installed iOS SDK confirms:

- `MusicPlayer.State.playbackRate` is writable.
- `MusicLibrary` can create a playlist with items and edit a playlist with items.
- `MusicLibraryRequest` supports limit and offset.
- `MusicItemCollection` supports `hasNextBatch` and `nextBatch`.
- Songs and tracks expose preview assets.
- No BPM or tempo property appears in the installed MusicKit song interface.
- `CMPedometerData.currentCadence` and `CMPedometer.isCadenceAvailable()` exist.

These are capability facts, not quality proof. The SDK does not provide a documented musical quality envelope, full-stream PCM, beat grid, or footfall phase.

Source hypothesis: `Docs/Handoffs/2026-08-14-master-handoff/original/pasted-text.txt:285-369`.

## Product decisions to carry forward

- Keep the functional core and identified callback model.
- Keep Apple Music as the one production player.
- Test the 0.85 through 1.15 candidate against the known 0.90 through 1.10 pair. Keep it only if Apple Music reports both endpoints and full-song listening stays clean.
- Make the normal large value target SPM, subject to Gate A wording and layout.
- Keep Manual scoped to one confirmed song. Reset it only on a player-confirmed different song or explicit Return to Auto.
- Preserve Manual through pause, same-track recovery, and unconfirmed transport requests.
- Separate responsive motion observation from calm Auto target commitment.
- Support steady movement from 90 through 210 SPM, but require five seconds before walking can own the music.
- Count a remaining difference of five SPM as approximate alignment. Keep playback inside the 0.85 through 1.15 candidate range.
- Keep the explicit editor close that preserves the current target and restores transport immediately.
- Rebuild Play, Pause, Previous, Next, and Finish as one coherent control system. Fix the Finish border overflow and test shape, clipping, layout, pressed response, visual hierarchy, accessibility, haptics, and physical feel together.
- Keep source tempo, cadence projection, target, rate command, read-back, effective result, and error as separate truths.
- Treat the build record and complete Debug explanation as Phase 0 tools, not product expansion.
- Keep the authored Auto completion cue as a later required event. Its trigger must be reducer-owned and read-back verified.
- Keep warehouse, Run Set, export, broad visual craft, and icon work behind the one-playlist core gate.

## Proposed work that should change

- Do not start with a broad new `TempoEvidence` domain abstraction. First extend diagnostics with the missing fields. Promote a model only when the corpus or product behavior needs it.
- Do not treat signing or binary identity as blockers. Both now pass for the current phone build.
- Do not call all unresolved analysis `rhythmUnclear` in the census. Preserve low confidence, ambiguity, and unsupported cadence projection separately before changing user copy.
- Do not call the settled Auto constants physically tuned. They are software defaults until the fingerprinted phone build produces a real trace and Samay judges the feel.
- Do not redesign setup from the verbal complaint alone. The complaint may predate the current setup-craft commit.
- Do not install a wildcard-signed build for MusicKit testing.

## Phase 0 implementation order

1. Build record and Debug tests: complete for base commit, dirty flag, build time, and deterministic source fingerprint.
2. Complete numerical Debug explanation: complete for software and Simulator.
3. Deterministic baseline fixtures: complete.
4. Renew or obtain an exact App ID development profile, then install a known build without deleting app data: complete.
5. Run the current-device baseline matrix and save privacy-safe evidence: partial. The fingerprinted workout confirmed repaired acquisition and one exact Apple Music reply. It also exposed a possible walking-range gap, poor matching, and jarring unexplained transitions. The mixed lifting period prevents a precise duration judgment. Known-cause song boundaries, haptics, and sustained outdoor running remain open.
6. Build the representative tempo disagreement corpus.
7. Build the import failure census, including playlist entry comparison and 30 identity audits.
8. Reconcile canonical docs with verified current facts.

## Phase 0 completion boundary

Phase 0 is not complete yet. It closes only when:

- the current physical build is attributable to an exact source state, including dirty changes;
- every F-001 through F-020 item is reproduced or documented as a non-reproduction;
- the complete tempo transformation is numerically inspectable;
- the representative tempo corpus classifies disagreement;
- the import census totals 100 percent and audits identity;
- later work is accepted, modified, deferred, or deleted from verified evidence.

Track-scoped Manual, safe cadence handling, the separate Auto target, walking support, approximate matching, the quiet tempo-wheel close, the transport and Finish pass, recorded song-change causes, and the first directional Auto feedback prototype are complete in software. The exact-profile workout closed the immediate fingerprint and repaired-acquisition gate. The expanded 0.85 through 1.15 candidate is installed and awaits endpoint read-back and listening. The next Main Thing is the phone check in `Docs/PHONE-CHECK-2026-08-19.md`, and after it the 20-minute outdoor run. Lifting-specific adaptation stays out. Warehouse, Run Set generation, setup, summary, and icon work remain later.
