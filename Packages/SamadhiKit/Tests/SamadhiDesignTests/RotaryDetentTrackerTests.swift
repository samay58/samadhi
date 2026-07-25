import Testing

@testable import SamadhiDesign

@Test func clockwiseRotationRaisesOneDetent() {
    let tracker = RotaryDetentTracker()
    tracker.begin(at: -.pi / 2)

    let detent = tracker.update(
        to: -.pi / 2 + RotaryDetentTracker.radiansPerDetent * 1.01
    )

    #expect(detent == 1)
}

@Test func counterclockwiseRotationLowersOneDetent() {
    let tracker = RotaryDetentTracker()
    tracker.begin(at: -.pi / 2)

    let detent = tracker.update(
        to: -.pi / 2 - RotaryDetentTracker.radiansPerDetent * 1.01
    )

    #expect(detent == -1)
}

@Test func partialTurnsAccumulateIntoADetent() {
    let tracker = RotaryDetentTracker()
    tracker.begin(at: 0)

    #expect(tracker.update(to: RotaryDetentTracker.radiansPerDetent * 0.44) == 0)
    #expect(tracker.update(to: RotaryDetentTracker.radiansPerDetent * 0.9) == 0)
    #expect(tracker.update(to: RotaryDetentTracker.radiansPerDetent * 1.1) == 1)
    #expect(tracker.update(to: RotaryDetentTracker.radiansPerDetent * 0.72) == 1)
    #expect(tracker.update(to: RotaryDetentTracker.radiansPerDetent * 0.44) == 0)
}

@Test func crossingAngleWrapDoesNotReverseTheWheel() {
    let tracker = RotaryDetentTracker()
    let nearPositivePi = Double.pi - RotaryDetentTracker.radiansPerDetent * 0.6
    let nearNegativePi = -Double.pi + RotaryDetentTracker.radiansPerDetent * 0.6
    tracker.begin(at: nearPositivePi)

    let detent = tracker.update(to: nearNegativePi)

    #expect(detent == 1)
}

@Test func reversingDirectionReturnsThroughPriorDetents() {
    let tracker = RotaryDetentTracker()
    tracker.begin(at: 0)
    #expect(tracker.update(to: RotaryDetentTracker.radiansPerDetent * 3.2) == 3)

    #expect(tracker.update(to: RotaryDetentTracker.radiansPerDetent * 0.8) == 1)
    #expect(tracker.update(to: RotaryDetentTracker.radiansPerDetent * 0.4) == 0)
}

@Test func resetClearsRotationHistory() {
    let tracker = RotaryDetentTracker()
    tracker.begin(at: 0)
    _ = tracker.update(to: RotaryDetentTracker.radiansPerDetent * 2)

    tracker.reset()

    #expect(!tracker.isTracking)
    #expect(tracker.currentDetent == 0)
    #expect(tracker.update(to: .pi) == 0)
}

@Test func oneRevolutionSpansThirtyBPM() {
    let tracker = RotaryDetentTracker()
    tracker.begin(at: -.pi / 2)

    #expect(tracker.update(to: 0) == 7)
    #expect(tracker.update(to: .pi / 2) == 15)
    #expect(tracker.update(to: .pi) == 22)
    #expect(tracker.update(to: -.pi / 2) == 30)
}

@Test func severalRevolutionsAccumulateWithoutLosingDirection() {
    let tracker = RotaryDetentTracker()
    tracker.begin(at: -.pi / 2)

    _ = tracker.update(to: 0)
    _ = tracker.update(to: .pi / 2)
    _ = tracker.update(to: .pi)
    #expect(tracker.update(to: -.pi / 2) == 30)
    _ = tracker.update(to: 0)
    _ = tracker.update(to: .pi / 2)
    _ = tracker.update(to: .pi)
    #expect(tracker.update(to: -.pi / 2) == 60)
}

@Test func aBoundedWheelDoesNotStoreOvershootAndReversesImmediately() {
    let tracker = RotaryDetentTracker()
    tracker.begin(at: 0, detentRange: -2...2)

    #expect(tracker.update(to: .pi / 2) == 2)
    #expect(tracker.boundaryDirection == .increase)
    let boundaryAngle = tracker.indicatorAngle

    #expect(tracker.update(to: .pi) == 2)
    #expect(tracker.indicatorAngle == boundaryAngle)
    #expect(tracker.update(to: .pi - 0.2) == 1)
    #expect(tracker.boundaryDirection == nil)
    #expect(tracker.indicatorAngle != boundaryAngle)
}
