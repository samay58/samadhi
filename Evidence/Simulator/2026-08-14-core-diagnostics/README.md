# Core diagnostics Simulator evidence

## Build tested

- Git commit: `4f5394f3158dde9ad891b8b772b197c4c26090b2`
- Branch: `main`
- Tracked files changed when built: yes
- App: 1.0, build 1
- Tempo analyzer: version 4
- Diagnostic file: version 6
- Simulator: iPhone 17 Pro, iOS 27.0
- Music and motion: deterministic Simulator services

The app wrote the commit, branch state, build date, app version, and build number into the built app. The Debug screen read those values from that built app. They were not typed into the fixture.

## Current behavior

| Case | Current result | Direct check |
| --- | --- | --- |
| Low-tempo song | An 84 BPM song supports a 168 SPM running pulse through two steps per beat. The screen keeps BPM and SPM separate. | `aSlowBeatCanSupportTwoStepsWithoutBecomingFalseMusicalTempo`, `diagnosticViewKeepsSongBeatsAndRunnerStepsSeparate`, `testDiagnosticsKeepSongBeatsAndRunnerStepsSeparate` |
| Auto to Manual | Manual takes ownership and keeps an absolute requested rhythm. | `manualControlAdjustsMusicBeforeCadenceLocks`, `testTempoControlRevealsAndSwitchesOwnership` |
| Manual to Auto | Reset returns to neutral Auto. | `resetReturnsFineTuneToNeutralAutomaticMode`, `testTempoControlRevealsAndSwitchesOwnership` |
| Manual then Skip | Skip requests a player change. The current song does not change until the player confirms it. Manual still owns the request. | `explicitSkipIsTheOnlyImmediateCommitForAPreparedBetterFit` |
| Manual then natural song change | Manual survives and is recomputed for the confirmed new song. This is the current behavior that the next product change must reverse. | `manualOwnershipSurvivesPauseResumeAndRecomputesForTheNextTrack` |
| Song change read-back | The new song clears the old Apple Music result and requests a fresh read-back. Late feedback for the old song is ignored. | `confirmedTrackChangeRequiresFreshReadbackForTheNewSong`, `testTrackResetShowsNoOldAppleMusicReadback` |
| Lower and upper song limits | Manual stops at the current song's reachable edge. Auto reports the nearest reachable result when cadence is outside that edge. | `manualAdjustmentStopsAtTheCurrentSongsTruthfulBoundary`, `directRhythmChangeStopsAtTheCurrentTrackEnvelope`, `automaticCadenceKeepsTheFirstTrackAtItsTruthfulBoundary` |
| Tempo wheel return | A background tap does not close the open wheel or restore playback controls. This reproduces the reported trap. | `surfaceTapCannotReplaceAnOpenRhythmControl`, `testTempoControlRevealsAndSwitchesOwnership` |
| Steady running rhythm | Three agreeing fresh readings acquire cadence. | `threeStableObservationsAcquireCadence` |
| One false spike | One large reading does not move a locked rhythm. | `oneLargeSpikeDoesNotMoveATrackedCadence` |
| Sustained faster rhythm | The filter follows most of a sustained increase within three seconds. | `sustainedCadenceChangeTracksMostOfTheStepWithinThreeSeconds` |
| Sustained slower rhythm | The filter follows most of a sustained decrease within three seconds. | `sustainedSlowerCadenceTracksMostOfTheStepWithinThreeSeconds` |
| Walking rhythm | A single 90 SPM reading does not move a running lock. A separate policy fixture records the current safe walking ramp. | `impossibleValuesAndSingleSpikeDoNotMoveTheLock`, `walkingFixtureCreatesClearSafeRamp` |
| Delayed Apple Music reply | The command stays waiting. A matching reply records the 1.75-second delay. | `appliedRateFeedbackRequiresCurrentSessionRequestAndTrack` |
| Wrong Apple Music reply | A mismatched rate becomes rejected and keeps the reply delay. | `mismatchedRateReadbackRejectsTheCommandAndRecordsLatency` |
| Route loss during Manual | Playback pauses. Manual survives route recovery and the explicit resume. | `manualSurvivesRouteLossAndExplicitRecovery` |
| Pause and resume during Manual | Manual survives. Cadence is reacquired before Auto can use a fresh reading. | `manualOwnershipSurvivesPauseResumeAndRecomputesForTheNextTrack` |

## Frames

- `low-tempo.png`: 84 BPM music, two steps per beat, and 168 SPM shown separately.
- `waiting.png`: no Apple Music reply or derived result is shown.
- `verified.png`: sent rate, reported rate, delay, resulting speeds, and remaining difference are visible.
- `limited.png`: the song limit has its own text and color.
- `rejected.png`: a rejected Apple Music result has its own text and color.
- `track-reset.png`: a confirmed new song has no inherited Apple Music reply.
- `accessibility-reduce-motion.png`: the screen remains scrollable and readable at the largest tested text size with Reduce Motion on.

These frames prove the Debug screen and deterministic app behavior in Simulator. They do not prove physical cadence, Apple Music playback, listening quality, haptics, or running feel.

## Phone signing

The paired iPhone has Samadhi 1.0 build 1 installed, but that app does not identify its source commit. A fresh build succeeded for the phone. Its profile was `iOS Team Provisioning Profile: *` with `ZL5U59XBJ6.*`, so it was not installed.
