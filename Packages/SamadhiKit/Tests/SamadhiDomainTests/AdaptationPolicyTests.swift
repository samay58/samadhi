import Testing

@testable import SamadhiDomain

private let policy = AdaptationPolicy()

@Test func halfAndDoubleTempoCandidatesCanMatchRunningCadence() {
    let halfTime = policy.update(
        state: .initial,
        input: input(cadence: 170, tempo: 85)
    )
    let doubleTime = policy.update(
        state: .initial,
        input: input(cadence: 170, tempo: 340)
    )

    #expect(halfTime.targetRate == 1)
    #expect(doubleTime.targetRate == 1)
    #expect(halfTime.isTrackCompatible)
    #expect(doubleTime.isTrackCompatible)
}

@Test func unsafeRateLeavesMusicSteady() {
    let decision = policy.update(
        state: .initial,
        input: input(cadence: 180, tempo: 160)
    )

    #expect(!decision.isTrackCompatible)
    #expect(decision.commandedRate == 1)
    #expect(decision.status == .musicSteady)
    #expect(decision.isAtLimit)
}

@Test func initialAndOngoingRateChangesUseDifferentRampLimits() {
    let initial = policy.update(
        state: .initial,
        input: input(cadence: 171, tempo: 165, appliedRate: 1, deltaSeconds: 1)
    )

    var lockedState = initial.nextState
    lockedState.hasMatched = true
    let ongoing = policy.update(
        state: lockedState,
        input: input(cadence: 171, tempo: 165, appliedRate: 1, deltaSeconds: 1)
    )

    #expect(initial.commandedRate == 1.02)
    #expect(ongoing.commandedRate == 1.005)
}

@Test func walkingFixtureCreatesClearSafeRamp() {
    let target = 142.0 / 149.75
    let first = policy.update(
        state: .initial,
        input: input(cadence: 142, tempo: 149.75, appliedRate: 1, deltaSeconds: 1)
    )
    let second = policy.update(
        state: first.nextState,
        input: input(cadence: 142, tempo: 149.75, appliedRate: first.commandedRate, deltaSeconds: 1)
    )
    let third = policy.update(
        state: second.nextState,
        input: input(cadence: 142, tempo: 149.75, appliedRate: second.commandedRate, deltaSeconds: 1)
    )

    #expect(first.isTrackCompatible)
    #expect(abs((first.targetRate ?? 0) - target) < 0.000_1)
    #expect(abs(first.commandedRate - 0.98) < 0.000_1)
    #expect(abs(second.commandedRate - 0.96) < 0.000_1)
    #expect(abs(third.commandedRate - target) < 0.000_1)
}

@Test func deadbandAndUpdateIntervalKeepTheCurrentTarget() {
    var state = AdaptationState.initial
    state.targetRate = 1.02
    state.baseTempoBPM = 165
    state.lastReliableCadenceSPM = 170
    state.requestedBPM = 170
    state.secondsSinceTargetUpdate = 0

    let insideDeadband = policy.update(
        state: state,
        input: input(cadence: 171, tempo: 165, appliedRate: 1.02, deltaSeconds: 2)
    )
    let beforeInterval = policy.update(
        state: state,
        input: input(cadence: 174, tempo: 165, appliedRate: 1.02, deltaSeconds: 1)
    )

    #expect(insideDeadband.targetRate == 1.02)
    #expect(beforeInterval.targetRate == 1.02)
}

@Test func aNewTrackRecomputesTargetEvenWhenCadenceIsSteady() {
    let firstTrack = policy.update(
        state: .initial,
        input: input(cadence: 170, tempo: 170)
    )
    let nextTrack = policy.update(
        state: firstTrack.nextState,
        input: input(cadence: 170, tempo: 165)
    )

    #expect(nextTrack.targetRate == 170.0 / 165.0)
}

@Test func confidenceLossHoldsThenEasesToNormal() {
    var state = AdaptationState.initial
    state.targetRate = 1.04
    state.lastReliableCadenceSPM = 172

    let held = policy.update(
        state: state,
        input: input(cadence: nil, tempo: 165, appliedRate: 1.04, reliable: false, deltaSeconds: 6)
    )
    let easing = policy.update(
        state: held.nextState,
        input: input(cadence: nil, tempo: 165, appliedRate: 1.04, reliable: false, deltaSeconds: 2)
    )
    let normal = policy.update(
        state: easing.nextState,
        input: input(cadence: nil, tempo: 165, appliedRate: easing.commandedRate, reliable: false, deltaSeconds: 2)
    )

    #expect(held.commandedRate == 1.04)
    #expect(easing.commandedRate == 1.02)
    #expect(normal.commandedRate == 1)
    #expect(normal.status == .acquiring)
    #expect(normal.nextState.targetRate == nil)
    #expect(!normal.nextState.hasMatched)
}

@Test func automaticCorrectionChangesTheMusicalRequestWithoutChangingCadenceTruth() {
    let control = RhythmControlState(
        mode: .automatic,
        automaticCorrectionBPM: 2
    )
    let decision = policy.update(
        state: .initial,
        input: input(cadence: 168, tempo: 170, rhythmControl: control)
    )

    #expect(decision.requestedBPM == 170)
    #expect(decision.targetRate == 1)
    #expect(decision.nextState.lastReliableCadenceSPM == 168)
}

@Test func manualTargetCanDriveMusicWithoutInventingCadence() {
    let control = RhythmControlState(mode: .manual, manualTargetBPM: 168)
    let decision = policy.update(
        state: .initial,
        input: input(
            cadence: nil,
            tempo: 160,
            reliable: false,
            rhythmControl: control,
            forceTargetUpdate: true
        )
    )

    #expect(decision.requestedBPM == 168)
    #expect(decision.targetRate == 1.05)
    #expect(decision.commandedRate == 1.02)
    #expect(decision.nextState.lastReliableCadenceSPM == nil)
}

@Test func unreachableManualTargetReportsTheDerivedRateAndLimit() {
    let control = RhythmControlState(mode: .manual, manualTargetBPM: 200)
    let decision = policy.update(
        state: .initial,
        input: input(
            cadence: 168,
            tempo: 170,
            rhythmControl: control,
            forceTargetUpdate: true
        )
    )

    #expect(decision.targetRate == nil)
    #expect(decision.derivedTargetRate == 200.0 / 170.0)
    #expect(decision.isAtLimit)
    #expect(decision.commandedRate == 1)
}

@Test func rhythmControlClampsBothModesAndResetReturnsToNeutralAuto() {
    var control = RhythmControlState.initial

    _ = control.adjust(by: 99)
    #expect(control.automaticCorrectionBPM == 20)
    _ = control.adjust(by: -99)
    #expect(control.automaticCorrectionBPM == -20)

    control.useManual(seedBPM: 250)
    #expect(control.mode == .manual)
    #expect(control.manualTargetBPM == 210)
    _ = control.adjust(by: -99)
    #expect(control.manualTargetBPM == 120)

    control.resetToAutomatic()
    #expect(control.mode == .automatic)
    #expect(control.automaticCorrectionBPM == 0)
}

@Test func automaticTargetKeepsItsFortyBPMWindowInsideRunningBounds() {
    let faster = RhythmControlState(automaticCorrectionBPM: 20)
    let slower = RhythmControlState(automaticCorrectionBPM: -20)

    #expect(faster.requestedBPM(cadenceSPM: 205) == 210)
    #expect(slower.requestedBPM(cadenceSPM: 125) == 120)
}

@Test func matchRequiresOneSecondInsideAppliedRateTolerance() {
    let first = policy.update(
        state: .initial,
        input: input(cadence: 170, tempo: 170, appliedRate: 1, deltaSeconds: 0.5)
    )
    let second = policy.update(
        state: first.nextState,
        input: input(cadence: 170, tempo: 170, appliedRate: 1, deltaSeconds: 0.5)
    )

    #expect(first.status == .adjusting)
    #expect(second.status == .matched)
}

@Test func honestTempoMeasurementRequiresAllInputsAndUsesEffectiveTempo() {
    let matched = TempoMatchEvaluator.measure(
        referenceBPM: 170,
        referenceReliable: true,
        baseTempoBPM: 85,
        appliedRate: 1,
        playbackActive: true
    )
    let unavailable = TempoMatchEvaluator.measure(
        referenceBPM: 170,
        referenceReliable: true,
        baseTempoBPM: 85,
        appliedRate: nil,
        playbackActive: true
    )

    #expect(matched == true)
    #expect(unavailable == nil)
}

@Test func manualTempoMeasurementRequiresVerifiedReadback() {
    let verified = TempoMatchEvaluator.measure(
        referenceBPM: 160,
        referenceReliable: true,
        baseTempoBPM: 80,
        appliedRate: 1,
        playbackActive: true,
        commandVerified: true
    )
    let pending = TempoMatchEvaluator.measure(
        referenceBPM: 160,
        referenceReliable: true,
        baseTempoBPM: 80,
        appliedRate: 1,
        playbackActive: true,
        commandVerified: false
    )

    #expect(verified == true)
    #expect(pending == nil)
}

private func input(
    cadence: Double?,
    tempo: Double,
    appliedRate: Double = 1,
    reliable: Bool = true,
    deltaSeconds: Double = 1,
    rhythmControl: RhythmControlState = .initial,
    forceTargetUpdate: Bool = false
) -> AdaptationInput {
    AdaptationInput(
        cadenceSPM: cadence,
        cadenceReliable: reliable,
        baseTempoBPM: tempo,
        analysisConfidence: 0.9,
        appliedRate: appliedRate,
        deltaSeconds: deltaSeconds,
        rhythmControl: rhythmControl,
        forceTargetUpdate: forceTargetUpdate
    )
}
