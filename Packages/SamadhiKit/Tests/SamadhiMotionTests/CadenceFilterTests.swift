import SamadhiDomain
import Testing

@testable import SamadhiMotion

@Test func fiveStableObservationsAcquireCadence() {
    var filter = CadenceFilter()
    let values = [168.0, 169, 167, 168, 168]
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

@Test func resumedAcquisitionUsesThreeStableObservations() {
    var filter = CadenceFilter(priorSPM: 170)
    var result = filter.ingest(CadenceObservation(stepsPerMinute: 172, elapsedSeconds: 0))
    #expect(result == .acquiring)
    result = filter.ingest(CadenceObservation(stepsPerMinute: 171, elapsedSeconds: 1))
    #expect(result == .acquiring)
    result = filter.ingest(CadenceObservation(stepsPerMinute: 172, elapsedSeconds: 2))

    #expect(result == .locked(stepsPerMinute: 170.4))
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
