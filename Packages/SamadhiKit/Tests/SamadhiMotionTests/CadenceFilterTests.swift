import SamadhiDomain
import Testing

@testable import SamadhiMotion

@Test func threeStableObservationsAcquireCadence() {
    var filter = CadenceFilter()
    let values = [168.0, 169, 167]
    var result = CadenceEstimate.acquiring

    for (index, value) in values.enumerated() {
        result = filter.ingest(
            CadenceObservation(stepsPerMinute: value, elapsedSeconds: Double(index))
        )
    }

    #expect(result == .locked(stepsPerMinute: 168))
}

@Test func impossibleValuesAndSingleSpikeDoNotMoveTheLock() {
    var filter = CadenceFilter()
    for value in [168.0, 168, 169, 167, 168] {
        _ = filter.ingest(CadenceObservation(stepsPerMinute: value, elapsedSeconds: 0))
    }

    let walking = filter.ingest(CadenceObservation(stepsPerMinute: 90, elapsedSeconds: 1))
    let spike = filter.ingest(CadenceObservation(stepsPerMinute: 205, elapsedSeconds: 2))

    #expect(walking == .locked(stepsPerMinute: 168))
    #expect(spike == .locked(stepsPerMinute: 168))
}

@Test func resumedAcquisitionUsesThreeFreshStableObservations() {
    var filter = CadenceFilter(isResuming: true)
    var result = filter.ingest(CadenceObservation(stepsPerMinute: 172, elapsedSeconds: 0))
    #expect(result == .acquiring)
    result = filter.ingest(CadenceObservation(stepsPerMinute: 171, elapsedSeconds: 1))
    #expect(result == .acquiring)
    result = filter.ingest(CadenceObservation(stepsPerMinute: 172, elapsedSeconds: 2))

    #expect(result == .locked(stepsPerMinute: 172))
}

@Test func stalePriorCadenceCannotOverrideFreshRunningSamples() {
    var filter = CadenceFilter(isResuming: true)

    _ = filter.ingest(CadenceObservation(stepsPerMinute: 150, elapsedSeconds: 0))
    _ = filter.ingest(CadenceObservation(stepsPerMinute: 151, elapsedSeconds: 1))
    let result = filter.ingest(
        CadenceObservation(stepsPerMinute: 150, elapsedSeconds: 2)
    )

    #expect(result == .locked(stepsPerMinute: 150))
}

@Test func sustainedMissingCadenceReturnsToAcquiring() {
    var filter = CadenceFilter()
    for value in [168.0, 168, 168, 168, 168] {
        _ = filter.ingest(CadenceObservation(stepsPerMinute: value, elapsedSeconds: 0))
    }

    _ = filter.ingest(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 1))
    _ = filter.ingest(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 2))
    let result = filter.ingest(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 3))

    #expect(result == .acquiring)
}

@Test func sustainedOutOfRangeCadenceReturnsToAcquiring() {
    var filter = CadenceFilter()
    for value in [168.0, 168, 168, 168, 168] {
        _ = filter.ingest(CadenceObservation(stepsPerMinute: value, elapsedSeconds: 0))
    }

    _ = filter.ingest(CadenceObservation(stepsPerMinute: 0, elapsedSeconds: 1))
    _ = filter.ingest(CadenceObservation(stepsPerMinute: 0, elapsedSeconds: 2))
    let result = filter.ingest(CadenceObservation(stepsPerMinute: 0, elapsedSeconds: 3))

    #expect(result == .acquiring)
}

@Test func staleCadenceSamplesCannotAcquire() {
    var filter = CadenceFilter()
    var result = CadenceEstimate.acquiring

    for index in 0..<5 {
        result = filter.ingest(
            CadenceObservation(
                stepsPerMinute: 180,
                elapsedSeconds: Double(index),
                sampleAgeSeconds: 5
            )
        )
    }

    #expect(result == .acquiring)
}

@Test func sustainedCadenceChangeTracksMostOfTheStepWithinThreeSeconds() {
    var filter = CadenceFilter()
    for index in 0..<5 {
        _ = filter.ingest(
            CadenceObservation(stepsPerMinute: 150, elapsedSeconds: Double(index))
        )
    }

    let first = filter.ingest(
        CadenceObservation(stepsPerMinute: 175, elapsedSeconds: 5)
    )
    let second = filter.ingest(
        CadenceObservation(stepsPerMinute: 175, elapsedSeconds: 6)
    )
    let third = filter.ingest(
        CadenceObservation(stepsPerMinute: 175, elapsedSeconds: 7)
    )

    #expect(first == .locked(stepsPerMinute: 150))
    guard case let .locked(secondSPM) = second,
        case let .locked(thirdSPM) = third
    else {
        Issue.record("Expected tracking estimates")
        return
    }
    #expect(secondSPM >= 162)
    #expect(thirdSPM >= 169)
    #expect(filter.state == .tracking)
}

@Test func oneLargeSpikeDoesNotMoveATrackedCadence() {
    var filter = CadenceFilter()
    for index in 0..<5 {
        _ = filter.ingest(
            CadenceObservation(stepsPerMinute: 160, elapsedSeconds: Double(index))
        )
    }

    let spike = filter.ingest(
        CadenceObservation(stepsPerMinute: 190, elapsedSeconds: 5)
    )
    let recovered = filter.ingest(
        CadenceObservation(stepsPerMinute: 160, elapsedSeconds: 6)
    )

    #expect(spike == .locked(stepsPerMinute: 160))
    #expect(recovered == .locked(stepsPerMinute: 160))
}

@Test func irregularCallbackIntervalsProduceTimeBasedResponse() {
    var filter = CadenceFilter()
    for index in 0..<5 {
        _ = filter.ingest(
            CadenceObservation(stepsPerMinute: 150, elapsedSeconds: Double(index))
        )
    }

    _ = filter.ingest(
        CadenceObservation(stepsPerMinute: 175, elapsedSeconds: 4.4)
    )
    let tracked = filter.ingest(
        CadenceObservation(stepsPerMinute: 175, elapsedSeconds: 6.2)
    )

    guard case let .locked(spm) = tracked else {
        Issue.record("Expected a tracking estimate")
        return
    }
    #expect(spm >= 168)
}
