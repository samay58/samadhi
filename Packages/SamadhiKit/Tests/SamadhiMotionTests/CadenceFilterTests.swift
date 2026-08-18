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

@Test func threeStableBriskWalkingObservationsAcquireCadence() {
    var filter = CadenceFilter()
    var result = CadenceEstimate.acquiring

    for (index, value) in [90.0, 91, 90].enumerated() {
        result = filter.ingest(
            CadenceObservation(stepsPerMinute: value, elapsedSeconds: Double(index))
        )
    }

    #expect(result == .locked(stepsPerMinute: 90))
}

@Test func cadenceBelowPurposefulWalkingDoesNotAcquire() {
    var filter = CadenceFilter()
    var result = CadenceEstimate.acquiring

    for (index, value) in [89.0, 89, 89].enumerated() {
        result = filter.ingest(
            CadenceObservation(stepsPerMinute: value, elapsedSeconds: Double(index))
        )
    }

    #expect(result == .acquiring)
    #expect(filter.lastSampleDisposition == .outsideSupportedRange)
}

@Test func missingReadingsBreakAcquisitionEvidence() {
    var filter = CadenceFilter()
    var result = CadenceEstimate.acquiring

    for (index, value) in [96.0, nil, 97, nil, 96].enumerated() {
        result = filter.ingest(
            CadenceObservation(stepsPerMinute: value, elapsedSeconds: Double(index))
        )
    }

    #expect(result == .acquiring)
}

@Test func disagreeingRepLikeValuesDoNotAcquire() {
    var filter = CadenceFilter()
    var result = CadenceEstimate.acquiring

    for (index, value) in [94.0, 107, 96].enumerated() {
        result = filter.ingest(
            CadenceObservation(stepsPerMinute: value, elapsedSeconds: Double(index))
        )
    }

    #expect(result == .acquiring)
}

@Test func impossibleValuesAndSingleSpikeDoNotMoveTheLock() {
    var filter = CadenceFilter()
    for (index, value) in [168.0, 168, 169, 167, 168].enumerated() {
        _ = filter.ingest(
            CadenceObservation(stepsPerMinute: value, elapsedSeconds: Double(index))
        )
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
    for (index, value) in [168.0, 168, 168, 168, 168].enumerated() {
        _ = filter.ingest(
            CadenceObservation(stepsPerMinute: value, elapsedSeconds: Double(index))
        )
    }

    _ = filter.ingest(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 1))
    _ = filter.ingest(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 2))
    let result = filter.ingest(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 3))

    #expect(result == .acquiring)
}

@Test func sustainedOutOfRangeCadenceReturnsToAcquiring() {
    var filter = CadenceFilter()
    for (index, value) in [168.0, 168, 168, 168, 168].enumerated() {
        _ = filter.ingest(
            CadenceObservation(stepsPerMinute: value, elapsedSeconds: Double(index))
        )
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

@Test func savedPhoneDeliveryPatternAcquiresFromNewDelayedSamples() {
    var filter = CadenceFilter()
    let autoPolicy = AutoTargetPolicy()
    var autoState = AutoTargetState.initial
    let interval = 2.556
    let values: [Double?] = [
        nil, 158.13, 154.80, 154.36, 154.36, 154.36, 151.56, 151.71, 151.71,
        151.71, 151.71, 151.71, 151.71, 151.71, 151.71, 151.71, 151.71,
    ]
    var result = CadenceEstimate.acquiring

    for (index, value) in values.enumerated() {
        let isInitiallyFresh = index <= 1
        let isFinalFresh = index == values.count - 1
        result = filter.ingest(
            CadenceObservation(
                stepsPerMinute: value,
                elapsedSeconds: Double(index) * interval,
                sampleAgeSeconds: isInitiallyFresh || isFinalFresh ? 0.02 : 2.575,
                sampleEndDateSeconds: Double(index) * interval
            )
        )
        if let filtered = result.lockedStepsPerMinute {
            autoState = autoPolicy.update(
                state: autoState,
                cadenceSPM: filtered,
                cadenceReliable: true,
                deltaSeconds: interval
            )
        }
    }

    #expect(result.lockedStepsPerMinute != nil)
    #expect(autoState.settledTargetSPM != nil)
    #expect(autoState.status == .settled)
}

@Test func savedWalkingDeliveryShapeAcquiresFromSteadyDelayedSamples() {
    var filter = CadenceFilter()
    let interval = 2.556
    let values = [94.6, 94.6, 94.6, 98.5, 98.9, 101.3]
    var result = CadenceEstimate.acquiring

    for (index, value) in values.enumerated() {
        result = filter.ingest(
            CadenceObservation(
                stepsPerMinute: value,
                elapsedSeconds: Double(index) * interval,
                sampleAgeSeconds: index == 0 ? 0.02 : 2.575,
                sampleEndDateSeconds: Double(index) * interval
            )
        )
    }

    #expect(result.lockedStepsPerMinute != nil)
    #expect(filter.state == .tracking)
}

@Test func oldFirstSampleCannotEstablishFreshness() {
    var filter = CadenceFilter()

    let result = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 10,
            sampleAgeSeconds: 2.1,
            sampleEndDateSeconds: 100
        )
    )

    #expect(result == .acquiring)
    #expect(filter.lastSampleDisposition == .staleSample)
}

@Test func advancingDelayedSampleCanEstablishFreshnessAfterRejectedFirstSample() {
    var filter = CadenceFilter()

    let first = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 10,
            sampleAgeSeconds: 2.57,
            sampleEndDateSeconds: 100
        )
    )
    let second = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 12.56,
            sampleAgeSeconds: 2.57,
            sampleEndDateSeconds: 102.56
        )
    )

    #expect(first == .acquiring)
    #expect(second == .acquiring)
    #expect(filter.lastSampleDisposition == .acceptedDelayed)
}

@Test func repeatedOldFirstSampleNeverEstablishesFreshness() {
    var filter = CadenceFilter()
    let observation = CadenceObservation(
        stepsPerMinute: 160,
        elapsedSeconds: 10,
        sampleAgeSeconds: 2.57,
        sampleEndDateSeconds: 100
    )

    _ = filter.ingest(observation)
    let repeated = filter.ingest(observation)

    #expect(repeated == .acquiring)
    #expect(filter.lastSampleDisposition == .repeatedTimestamp)
}

@Test func repeatedAndBackwardTimestampsAreRejected() {
    var filter = CadenceFilter()
    _ = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 1,
            sampleEndDateSeconds: 100
        )
    )

    _ = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 1,
            sampleEndDateSeconds: 100
        )
    )
    #expect(filter.lastSampleDisposition == .repeatedTimestamp)

    _ = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 2,
            sampleEndDateSeconds: 99
        )
    )
    #expect(filter.lastSampleDisposition == .backwardTimestamp)
}

@Test func outOfOrderCallbackAndLargeGapAreRejected() {
    var filter = CadenceFilter()
    _ = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 10,
            sampleEndDateSeconds: 100
        )
    )

    _ = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 9,
            sampleEndDateSeconds: 101
        )
    )
    #expect(filter.lastSampleDisposition == .outOfOrderCallback)

    _ = filter.ingest(
        CadenceObservation(
            stepsPerMinute: 160,
            elapsedSeconds: 16,
            sampleEndDateSeconds: 106
        )
    )
    #expect(filter.lastSampleDisposition == .unexplainedGap)
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

@Test func sustainedSlowerCadenceTracksMostOfTheStepWithinThreeSeconds() {
    var filter = CadenceFilter()
    for index in 0..<5 {
        _ = filter.ingest(
            CadenceObservation(stepsPerMinute: 175, elapsedSeconds: Double(index))
        )
    }

    let first = filter.ingest(
        CadenceObservation(stepsPerMinute: 150, elapsedSeconds: 5)
    )
    let second = filter.ingest(
        CadenceObservation(stepsPerMinute: 150, elapsedSeconds: 6)
    )
    let third = filter.ingest(
        CadenceObservation(stepsPerMinute: 150, elapsedSeconds: 7)
    )

    #expect(first == .locked(stepsPerMinute: 175))
    guard case let .locked(secondSPM) = second,
        case let .locked(thirdSPM) = third
    else {
        Issue.record("Expected tracking estimates")
        return
    }
    #expect(secondSPM <= 163)
    #expect(thirdSPM <= 156)
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
