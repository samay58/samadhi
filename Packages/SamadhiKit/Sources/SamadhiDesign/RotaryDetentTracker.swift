import Foundation
import SamadhiDomain

final class RotaryDetentTracker {
    static let detentsPerRevolution = 30
    static let radiansPerDetent = 2 * Double.pi / Double(detentsPerRevolution)
    private static let reverseHysteresis = 0.55

    private(set) var currentDetent = 0
    private(set) var boundaryDirection: RhythmAdjustmentDirection?
    private var lastAngle: Double?
    private var originAngle: Double?
    private var accumulatedRotation = 0.0
    private var detentRange: ClosedRange<Int>?

    var isTracking: Bool { lastAngle != nil }
    var indicatorAngle: Double? {
        originAngle.map { $0 + accumulatedRotation }
    }

    func begin(at angle: Double, detentRange: ClosedRange<Int>? = nil) {
        currentDetent = 0
        accumulatedRotation = 0
        boundaryDirection = nil
        self.detentRange = detentRange
        originAngle = angle
        lastAngle = angle
    }

    func update(to angle: Double) -> Int {
        guard let priorAngle = lastAngle else {
            begin(at: angle)
            return currentDetent
        }

        var delta = angle - priorAngle
        if delta > .pi { delta -= 2 * .pi }
        if delta < -.pi { delta += 2 * .pi }
        let proposedRotation = accumulatedRotation + delta
        if let detentRange {
            let lowerRotation = Double(detentRange.lowerBound) * Self.radiansPerDetent
            let upperRotation = Double(detentRange.upperBound) * Self.radiansPerDetent
            if proposedRotation < lowerRotation {
                accumulatedRotation = lowerRotation
                boundaryDirection = .decrease
            } else if proposedRotation > upperRotation {
                accumulatedRotation = upperRotation
                boundaryDirection = .increase
            } else {
                accumulatedRotation = proposedRotation
                boundaryDirection = nil
            }
        } else {
            accumulatedRotation = proposedRotation
            boundaryDirection = nil
        }
        lastAngle = angle
        let rawDetent = accumulatedRotation / Self.radiansPerDetent
        settleCurrentDetent(toward: rawDetent)
        return currentDetent
    }

    func reset() {
        currentDetent = 0
        accumulatedRotation = 0
        boundaryDirection = nil
        detentRange = nil
        originAngle = nil
        lastAngle = nil
    }

    private func settleCurrentDetent(toward rawDetent: Double) {
        while rawDetent >= positiveThreshold {
            currentDetent += 1
        }
        while rawDetent <= negativeThreshold {
            currentDetent -= 1
        }
    }

    private var positiveThreshold: Double {
        let distance = currentDetent < 0 ? Self.reverseHysteresis : 1
        return Double(currentDetent) + distance
    }

    private var negativeThreshold: Double {
        let distance = currentDetent > 0 ? Self.reverseHysteresis : 1
        return Double(currentDetent) - distance
    }
}
