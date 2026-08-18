# Core reset workplan

The handoff originally authorized only Phase 0. Samay later authorized the track-scoped Manual fix, tempo-wheel close, source fingerprint, cadence timing repair, separate Auto target, focused walking and approximate-match work, and a wider 0.85 through 1.15 playback candidate. All other later work stays queued. Source: `original/pasted-text.txt:732-734,1749-1767`.

## Work item P0-00: Preserve the handoff

- Result: immutable source, checksum, and receipt manifest.
- Source: prior user instruction; `original/pasted-text.txt:10-42`.
- Files: `original/pasted-text.txt`, `MANIFEST.md`.
- Done check: preserved bytes match the attachment.
- Verification: `cmp` and SHA-256.
- Status: complete.

## Work item P0-01: Record the current environment

- Result: current repository, tools, simulator, phone, signing identities, installed app metadata, and working-tree ownership are known.
- Why first: every later claim needs a named build and machine context.
- Source: `original/pasted-text.txt:738-823,1751-1757`.
- Systems: Git, Xcode, XcodeGen, Swift, Simulator, CoreDevice, signing.
- Done check: local and remote SHAs, branch, dirty files, tool versions, active developer directory, device status, signing status, and installed app identity are recorded.
- Verification: direct command read-back.
- Status: complete for the current machine. An exact Samadhi development profile was created, inspected, and used for an in-place phone install. The selected collection stayed byte-for-byte unchanged.

## Work item P0-02: Re-establish the software baseline

- Result: generation, formatter, package tests, app-model tests, UI tests, and a resource-inclusive Simulator build have current results.
- Why here: code analysis should not mistake an already-broken baseline for a handoff regression.
- Source: `original/pasted-text.txt:763-800,1702-1712`.
- Commands: `./Scripts/bootstrap.sh`, formatter lint, `./Scripts/test.sh`.
- Done check: exact counts and failures are captured without overstating platform quality.
- Verification: command exit status and result bundle.
- Status: complete for this slice. The expanded final counts are recorded in `VERIFICATION.md`.

## Work item P0-03: Produce the adversarial review memo

- Result: every H-001 through H-020 ends as Accepted, Accepted with modification, Refuted, or Deferred because evidence is unavailable.
- Why here: this is the required first substantive product deliverable.
- Source: `original/pasted-text.txt:10-42,371-407,738-761,1749-1767`.
- Files: `Docs/CORE-RESET-ADVERSARIAL-REVIEW.md`.
- Systems: domain, motion, audio, import, playback, presentation, diagnostics, tests, docs, evidence.
- Done check: every complaint maps to a current code path, current reproduction, historical evidence, platform limit, or explicit unknown. Proposed later tasks are accepted, modified, deferred, or deleted.
- Verification: source references, code traces, tests, live environment read-back, and explicit proof limits.
- Status: complete for software, Simulator, and one exact-profile phone baseline. Each Debug build writes its own commit, branch state, build date, version, and build number.

## Work item P0-04: Add build identification

- Result: every new diagnostic identifies the exact binary.
- Why after memo: instrumentation shape should follow the reviewed evidence model.
- Source: `original/pasted-text.txt:802-823`.
- Likely files: build settings or generated source, app diagnostics, tests.
- Required fields: git SHA, branch state, build date, app version/build, analyzer version, diagnostic schema, device/OS, service mode, launch arguments.
- Done check: values are build-generated, present in Debug evidence, absent from normal Release UI, and contain no secrets.
- Verification: domain/app-model tests, Simulator diagnostic read-back, signed-build inspection.
- Status: complete. The build now captures a stable source fingerprint before compilation and embeds it in the Debug build record and local diagnostic file. It covers app code, resources, package source, build configuration, and behavior-changing scripts, including modified and untracked inputs.

## Work item P0-05: Explain the complete rhythm-to-music change

- Result: the complete numerical transformation is visible or exportable without changing the normal Release surface.
- Why after build identity: a diagnostic screen tied to an unknown app build can still mislead.
- Source: `original/pasted-text.txt:580-628,857-880`.
- Likely files: music models, adaptation state, reducer, presentation, diagnostics, Debug UI, tests.
- Done check: analyzed source tempo, alternate pulse, confidence, analyzer version, analysis source, relationship, original cadence projection, raw and filtered cadence, settled target, active target, required/commanded/applied rate, latency, effective tempos, residual error, and verification status are distinct.
- Verification: low-tempo fixture, delayed/mismatched read-back fixture, track-change reset fixture, A/B control, Simulator frame.
- Status: complete for deterministic software, Simulator behavior, and one fingerprinted phone workout. The repaired delivery rule acquired 133 SPM from the real delayed phone pattern, and Apple Music reported the exact 1.0390625 command after 0.066 seconds. Broader listening and sustained movement quality remain open.

## Work item P0-06: Run the core baseline matrix

- Result: each reported behavior is classified against a known current build.
- Why after the Debug explanation: reproduction without the values the app saw and changed cannot locate the failing layer.
- Source: `original/pasted-text.txt:825-855`.
- Scenarios: low-tempo projection; Auto to Manual; Manual to Auto; Manual across Skip and natural boundary; both limits; editor exit; stable cadence; spike; sustained change; walking; delayed/rejected rate; route loss; pause/resume.
- Done check: each scenario has observed behavior, expected behavior, code path, screen evidence, and diagnostic evidence.
- Verification: deterministic fixtures first, current iPhone where platform or body evidence is required.
- Status: complete for deterministic software and Simulator behavior. The saved phone delivery pattern now acquires in replay and did acquire during a later physical workout. A second replay covers steady delayed walking near 100 SPM. Old first samples, repeated and backward timestamps, out-of-order callbacks, unexplained gaps, broken movement, and below-range values still fail. The retained workout trace contains one confirmed song change but does not preserve its cause. Haptic quality and sustained outdoor movement feel remain open.

## Work item P0-07: Build the tempo disagreement corpus

- Result: analyzer correctness and ambiguity are measurable on relevant music.
- Why after the Debug explanation: the corpus needs explicit evidence fields and analyzer versioning.
- Source: `original/pasted-text.txt:882-915`.
- Scope: existing 12 public fixtures plus at least 20 representative private tracks; metadata-only committed evidence.
- Done check: Samadhi, development-only Librosa, human tap, published reference when trustworthy, accepted interpretation, and disagreement class exist for each track.
- Verification: corpus replay; no preview audio or restricted dependency enters the app.
- Status: pending.

## Work item P0-08: Build the import failure census

- Result: every source item receives one terminal outcome and resolver changes are evidence-led.
- Why after baseline: current import behavior and metadata coverage must be measured before loosening matching.
- Source: `original/pasted-text.txt:917-959`.
- Scope: coherent playlist, eclectic playlist, larger personal source; compare tracks, entries, and entry items.
- Done check: percentages total 100 percent, 30 resolved identities are manually audited, and high-confidence wrong-version count is zero.
- Verification: privacy-safe census artifact and audit notes.
- Status: pending.

## Work item P0-09: Close Phase 0

- Result: Phase 0 decisions and remaining evidence gaps are canonical.
- Source: `original/pasted-text.txt:738-959,1702-1747`.
- Files: adversarial memo, `VERIFICATION.md`, then milestone updates to canonical docs.
- Done check: every feedback item is reproduced or documented as a non-reproduction; every tempo transformation is numerically explainable; later tasks are accepted, modified, deferred, or deleted.
- Verification: one focused review pass against the handoff and repository.
- Status: pending.

## Queued after Phase 0

- Phase 1: track-scoped Manual ownership, safe Auto acquisition, a separate settled Auto target, the quiet editor close, and the walking and approximate-match contract are complete in software. The candidate supports steady 90 through 210 SPM movement, needs longer evidence for walking, keeps lifting outside Auto, and now spans 0.85 through 1.15 playback. The wider candidate is installed with exact signing and app data preserved. Its in-app identity, endpoint Apple Music read-back, and listening approval remain. Source: `original/pasted-text.txt:961-1163`; `original/addendum-02-workout-feedback.txt`; `original/addendum-04-workout-context-correction.txt`.
- Phase 2: resolver repair, incremental warehouse, deterministic Run Set, optional explicit Apple Music export. Source: `original/pasted-text.txt:1165-1289`.
- Phase 3: first complete the full transport and Finish control pass. Then prototype the directional Auto change and arrival family in `Docs/AUTO-CHANGE-INTERACTION-SPEC.md`. Temporary screen copy is not part of the solution. Setup, summary, and icon craft remain later. Source: `original/pasted-text.txt:1291-1524`; `original/addendum-01-buttons.txt`; `original/addendum-02-workout-feedback.txt`; `original/addendum-03-transition-haptics-priority.txt`.
- Phase 4: complete physical outdoor reliability gate. Source: `original/pasted-text.txt:1526-1566`.
