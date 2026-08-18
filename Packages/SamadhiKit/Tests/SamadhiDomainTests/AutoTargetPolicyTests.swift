import Testing

@testable import SamadhiDomain

@Test func autoTargetAcquiresFromSteadyCadence() {
    let policy = AutoTargetPolicy()
    var state = AutoTargetState.initial

    state = policy.update(state: state, cadenceSPM: 160, cadenceReliable: true, deltaSeconds: 1)
    state = policy.update(state: state, cadenceSPM: 161, cadenceReliable: true, deltaSeconds: 1)
    state = policy.update(state: state, cadenceSPM: 159, cadenceReliable: true, deltaSeconds: 1)

    #expect(state.settledTargetSPM == 160)
    #expect(state.status == .settled)
}

@Test func autoTargetIgnoresOrdinaryNoiseAndOneSpike() {
    let policy = AutoTargetPolicy()
    var state = settledAutoTarget(160, policy: policy)

    for value in [162.0, 158, 161, 159, 164] {
        state = policy.update(state: state, cadenceSPM: value, cadenceReliable: true, deltaSeconds: 1)
    }
    #expect(state.settledTargetSPM == 160)

    state = policy.update(state: state, cadenceSPM: 181, cadenceReliable: true, deltaSeconds: 1)
    state = policy.update(state: state, cadenceSPM: 160, cadenceReliable: true, deltaSeconds: 1)

    #expect(state.settledTargetSPM == 160)
    #expect(state.status == .settled)
}

@Test func autoTargetAdoptsSustainedFasterAndSlowerRhythms() {
    let policy = AutoTargetPolicy()
    var state = settledAutoTarget(160, policy: policy)

    for _ in 0..<8 {
        state = policy.update(state: state, cadenceSPM: 160, cadenceReliable: true, deltaSeconds: 1)
    }
    for _ in 0..<6 {
        state = policy.update(state: state, cadenceSPM: 171, cadenceReliable: true, deltaSeconds: 1)
    }
    #expect(state.settledTargetSPM == 171)

    for _ in 0..<8 {
        state = policy.update(state: state, cadenceSPM: 171, cadenceReliable: true, deltaSeconds: 1)
    }
    for _ in 0..<6 {
        state = policy.update(state: state, cadenceSPM: 153, cadenceReliable: true, deltaSeconds: 1)
    }
    #expect(state.settledTargetSPM == 153)
}

@Test func autoTargetUsesElapsedTimeInsteadOfCallbackCount() {
    let policy = AutoTargetPolicy()
    var state = settledAutoTarget(160, policy: policy)

    state = policy.update(state: state, cadenceSPM: 160, cadenceReliable: true, deltaSeconds: 8)
    state = policy.update(state: state, cadenceSPM: 170, cadenceReliable: true, deltaSeconds: 2.56)
    #expect(state.status == .considering)
    state = policy.update(state: state, cadenceSPM: 171, cadenceReliable: true, deltaSeconds: 2.56)
    #expect(state.status == .considering)
    state = policy.update(state: state, cadenceSPM: 170, cadenceReliable: true, deltaSeconds: 2.56)

    #expect(state.settledTargetSPM == 171)
    #expect(state.status == .settled)
}

@Test func autoTargetHoldsBriefUncertaintyThenRequiresReacquisition() {
    let policy = AutoTargetPolicy()
    var state = settledAutoTarget(160, policy: policy)

    state = policy.update(state: state, cadenceSPM: nil, cadenceReliable: false, deltaSeconds: 5)
    #expect(state.settledTargetSPM == 160)
    #expect(state.status == .holding)

    state = policy.update(state: state, cadenceSPM: nil, cadenceReliable: false, deltaSeconds: 7)
    #expect(state.settledTargetSPM == nil)
    #expect(state.status == .acquiring)
}

@Test func steadyBriskWalkingBecomesAnAutomaticTargetAfterLongerEvidence() {
    let policy = AutoTargetPolicy()
    var state = AutoTargetState.initial

    state = policy.update(state: state, cadenceSPM: 100, cadenceReliable: true, deltaSeconds: 1)
    #expect(state.settledTargetSPM == nil)

    for _ in 0..<4 {
        state = policy.update(state: state, cadenceSPM: 100, cadenceReliable: true, deltaSeconds: 1)
    }

    #expect(state.settledTargetSPM == 100)
    #expect(state.status == .settled)
}

@Test func cadenceBelowPurposefulWalkingCannotBecomeAnAutomaticTarget() {
    let policy = AutoTargetPolicy()
    var state = AutoTargetState.initial

    state = policy.update(state: state, cadenceSPM: 89, cadenceReliable: true, deltaSeconds: 10)

    #expect(state.settledTargetSPM == nil)
    #expect(state.status == .acquiring)
}

@Test func brokenRepLikeMotionCannotAccumulateAWalkingTarget() {
    let policy = AutoTargetPolicy()
    var state = AutoTargetState.initial

    for cadence in [96.0, nil, 103, nil, 94, nil, 101] {
        state = policy.update(
            state: state,
            cadenceSPM: cadence,
            cadenceReliable: cadence != nil,
            deltaSeconds: 1
        )
    }

    #expect(state.settledTargetSPM == nil)
    #expect(state.status == .acquiring)
}

@Test(arguments: [90.0, 100, 110])
func walkingTargetsRequireFiveSecondsOfSteadyEvidence(_ cadence: Double) {
    let policy = AutoTargetPolicy()
    var state = AutoTargetState.initial

    for _ in 0..<4 {
        state = policy.update(
            state: state,
            cadenceSPM: cadence,
            cadenceReliable: true,
            deltaSeconds: 1
        )
    }
    #expect(state.settledTargetSPM == nil)

    state = policy.update(
        state: state,
        cadenceSPM: cadence,
        cadenceReliable: true,
        deltaSeconds: 1
    )
    #expect(state.settledTargetSPM == cadence)
}

@Test(arguments: [120.0, 130, 140, 160])
func runningTargetsCanSettleAfterTheSensorLocks(_ cadence: Double) {
    let policy = AutoTargetPolicy()
    let state = policy.update(
        state: .initial,
        cadenceSPM: cadence,
        cadenceReliable: true,
        deltaSeconds: 1
    )

    #expect(state.settledTargetSPM == cadence)
}

@Test func sustainedWalkToJogAndJogToWalkEachCommitOnce() {
    let policy = AutoTargetPolicy()
    var state = AutoTargetState.initial

    for _ in 0..<5 {
        state = policy.update(state: state, cadenceSPM: 100, cadenceReliable: true, deltaSeconds: 1)
    }
    for _ in 0..<8 {
        state = policy.update(state: state, cadenceSPM: 100, cadenceReliable: true, deltaSeconds: 1)
    }
    for _ in 0..<6 {
        state = policy.update(state: state, cadenceSPM: 130, cadenceReliable: true, deltaSeconds: 1)
    }
    #expect(state.settledTargetSPM == 130)

    for _ in 0..<8 {
        state = policy.update(state: state, cadenceSPM: 130, cadenceReliable: true, deltaSeconds: 1)
    }
    for _ in 0..<6 {
        state = policy.update(state: state, cadenceSPM: 100, cadenceReliable: true, deltaSeconds: 1)
    }
    #expect(state.settledTargetSPM == 100)
}

private func settledAutoTarget(_ target: Double, policy: AutoTargetPolicy) -> AutoTargetState {
    var state = AutoTargetState.initial
    for _ in 0..<3 {
        state = policy.update(
            state: state,
            cadenceSPM: target,
            cadenceReliable: true,
            deltaSeconds: 1
        )
    }
    return state
}
