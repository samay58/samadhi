import Foundation
import SamadhiDomain

public enum CadenceEstimate: Sendable, Equatable {
    case acquiring
    case locked(stepsPerMinute: Double)

    public var lockedStepsPerMinute: Double? {
        guard case let .locked(stepsPerMinute) = self else { return nil }
        return stepsPerMinute
    }
}

// Separates first acquisition from tracking. Acquisition needs agreement across fresh samples;
// tracking follows a sustained change on a time constant rather than a callback count, so response
// stays honest when Core Motion delivers irregularly. Thresholds are field-tuned; see
// Evidence/Device/2026-07-23-field-repair-analysis.md.
public struct CadenceFilter: Sendable {
    private static let maximumSampleAgeSeconds = 2.0
    private static let samplesToAcquire = 3
    private static let acquisitionWindow = 6
    private static let agreementSPM = 3.0
    private static let deadbandSPM = 2.0
    private static let largeChangeSPM = 12.0
    private static let corroborationSPM = 4.0
    private static let responseTimeConstantSeconds = 1.1
    private static let maximumChangeSPMPerSecond = 14.0
    private static let missingSamplesBeforeReacquiring = 3
    private static let sampleIntervalRange = 0.25...2.5

    private var recentValues: [Double] = []
    private var publishedSPM: Double?
    private var missingCount = 0
    private var pendingLargeChange: Double?
    private var lastElapsedSeconds: Double?
    public private(set) var state: CadenceTrackingState

    // A prior cadence marks this as a reacquisition for reporting only. The filter never seeds from
    // it: a stale value must not outvote fresh agreeing samples.
    public init(isResuming: Bool = false) {
        state = isResuming ? .reacquiring : .acquiring
    }

    public mutating func ingest(_ observation: CadenceObservation) -> CadenceEstimate {
        guard observation.sampleAgeSeconds <= Self.maximumSampleAgeSeconds,
            let value = observation.stepsPerMinute,
            TempoEnvelope.runningCadenceBPM.contains(value)
        else {
            return recordMissing()
        }

        missingCount = 0
        let deltaSeconds = observationDelta(at: observation.elapsedSeconds)

        if let publishedSPM {
            return track(value, from: publishedSPM, over: deltaSeconds)
        }
        return acquire(value)
    }

    private mutating func track(
        _ value: Double,
        from publishedSPM: Double,
        over deltaSeconds: Double
    ) -> CadenceEstimate {
        state = .tracking
        let difference = value - publishedSPM
        guard abs(difference) > Self.deadbandSPM else {
            pendingLargeChange = nil
            return .locked(stepsPerMinute: publishedSPM)
        }

        let target: Double
        if abs(difference) > Self.largeChangeSPM {
            // One isolated jump is a spike until a second sample agrees with it.
            guard let pendingLargeChange,
                abs(value - pendingLargeChange) <= Self.corroborationSPM
            else {
                self.pendingLargeChange = value
                return .locked(stepsPerMinute: publishedSPM)
            }
            target = (pendingLargeChange + value) / 2
            self.pendingLargeChange = nil
        } else {
            pendingLargeChange = nil
            target = value
        }

        let response = 1 - exp(-deltaSeconds / Self.responseTimeConstantSeconds)
        let smoothed = publishedSPM + (response * (target - publishedSPM))
        let limited = move(
            publishedSPM,
            toward: smoothed,
            maximumChange: Self.maximumChangeSPMPerSecond * deltaSeconds
        )
        self.publishedSPM = limited
        return .locked(stepsPerMinute: limited)
    }

    // The window is acquisition-only state. Once locked, tracking works from the published value.
    private mutating func acquire(_ value: Double) -> CadenceEstimate {
        recentValues.append(value)
        if recentValues.count > Self.acquisitionWindow {
            recentValues.removeFirst()
        }
        guard recentValues.count >= Self.samplesToAcquire,
            medianAbsoluteDeviation(recentValues) <= Self.agreementSPM
        else {
            return .acquiring
        }

        let acquired = median(recentValues)
        publishedSPM = acquired
        recentValues.removeAll(keepingCapacity: true)
        state = .tracking
        pendingLargeChange = nil
        return .locked(stepsPerMinute: acquired)
    }

    private func median(_ values: [Double]) -> Double {
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }

    private func medianAbsoluteDeviation(_ values: [Double]) -> Double {
        let center = median(values)
        return median(values.map { abs($0 - center) })
    }

    private func move(_ value: Double, toward target: Double, maximumChange: Double) -> Double {
        if value < target { return min(value + maximumChange, target) }
        return max(value - maximumChange, target)
    }

    private mutating func observationDelta(at elapsedSeconds: Double) -> Double {
        defer { lastElapsedSeconds = elapsedSeconds }
        guard let lastElapsedSeconds else { return 1 }
        let measured = elapsedSeconds - lastElapsedSeconds
        guard measured > 0 else { return 1 }
        return min(
            max(measured, Self.sampleIntervalRange.lowerBound),
            Self.sampleIntervalRange.upperBound
        )
    }

    private mutating func recordMissing() -> CadenceEstimate {
        missingCount += 1
        if missingCount >= Self.missingSamplesBeforeReacquiring {
            publishedSPM = nil
            recentValues.removeAll(keepingCapacity: true)
            pendingLargeChange = nil
            state = .reacquiring
        }
        return publishedSPM.map(CadenceEstimate.locked) ?? .acquiring
    }
}
