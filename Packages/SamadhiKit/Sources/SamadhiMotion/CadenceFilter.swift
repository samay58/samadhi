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

public enum CadenceSampleDisposition: String, Sendable, Equatable, Codable {
    case acceptedFresh
    case acceptedDelayed
    case missingValue
    case outsideSupportedRange
    case staleSample
    case repeatedTimestamp
    case backwardTimestamp
    case outOfOrderCallback
    case unexplainedGap
}

// Separates first acquisition from tracking. Acquisition needs agreement across fresh samples;
// tracking follows a sustained change on a time constant rather than a callback count, so response
// stays honest when Core Motion delivers irregularly. Thresholds are field-tuned; see
// Evidence/Device/2026-07-23-field-repair-analysis.md.
public struct CadenceFilter: Sendable {
    // A first sample has no earlier timestamp proving that it is new. Once one fresh sample is
    // established, a later timestamp may arrive one normal delivery interval late. The hard ceiling
    // prevents an advancing but abandoned stream from being accepted indefinitely.
    private static let maximumFirstSampleAgeSeconds = 2.0
    private static let deliveryDelayToleranceSeconds = 0.5
    private static let maximumDeferredSampleAgeSeconds = 4.0
    private static let maximumExplainedSampleGapSeconds = 5.0
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
    private var lastAcceptedSampleEndDateSeconds: Double?
    private var pendingStaleElapsedSeconds: Double?
    private var pendingStaleSampleEndDateSeconds: Double?
    private var lastAcceptedIntervalSeconds = 1.0
    public private(set) var state: CadenceTrackingState
    public private(set) var lastSampleDisposition: CadenceSampleDisposition = .missingValue

    // A prior cadence marks this as a reacquisition for reporting only. The filter never seeds from
    // it: a stale value must not outvote fresh agreeing samples.
    public init(isResuming: Bool = false) {
        state = isResuming ? .reacquiring : .acquiring
    }

    public mutating func ingest(_ observation: CadenceObservation) -> CadenceEstimate {
        guard acceptTiming(of: observation) else {
            return recordMissing()
        }

        guard let value = observation.stepsPerMinute else {
            lastSampleDisposition = .missingValue
            return recordMissing()
        }
        guard TempoEnvelope.locomotionCadenceSPM.contains(value) else {
            lastSampleDisposition = .outsideSupportedRange
            return recordMissing()
        }

        missingCount = 0
        let deltaSeconds = min(
            max(lastAcceptedIntervalSeconds, Self.sampleIntervalRange.lowerBound),
            Self.sampleIntervalRange.upperBound
        )

        if let publishedSPM {
            return track(value, from: publishedSPM, over: deltaSeconds)
        }
        return acquire(value)
    }

    private mutating func acceptTiming(of observation: CadenceObservation) -> Bool {
        guard let previousElapsedSeconds = lastElapsedSeconds else {
            if observation.sampleAgeSeconds <= Self.maximumFirstSampleAgeSeconds {
                recordAcceptedTiming(observation)
                lastSampleDisposition = .acceptedFresh
                return true
            }
            return acceptDelayedSampleAfterUntrustedBaseline(observation)
        }

        if let sampleEnd = observation.sampleEndDateSeconds,
            let lastSampleEnd = lastAcceptedSampleEndDateSeconds
        {
            if sampleEnd == lastSampleEnd {
                lastSampleDisposition = .repeatedTimestamp
                return false
            }
            if sampleEnd < lastSampleEnd {
                lastSampleDisposition = .backwardTimestamp
                return false
            }
        }

        let sampleInterval = observation.elapsedSeconds - previousElapsedSeconds
        if sampleInterval == 0 {
            lastSampleDisposition = .repeatedTimestamp
            return false
        }
        guard sampleInterval > 0 else {
            lastSampleDisposition = .outOfOrderCallback
            return false
        }
        guard sampleInterval <= Self.maximumExplainedSampleGapSeconds else {
            lastElapsedSeconds = nil
            lastAcceptedSampleEndDateSeconds = nil
            lastAcceptedIntervalSeconds = 1
            recordUntrustedTiming(observation)
            lastSampleDisposition = .unexplainedGap
            return false
        }

        let allowedAge = min(
            max(
                Self.maximumFirstSampleAgeSeconds,
                sampleInterval + Self.deliveryDelayToleranceSeconds
            ),
            Self.maximumDeferredSampleAgeSeconds
        )
        guard observation.sampleAgeSeconds <= allowedAge else {
            lastSampleDisposition = .staleSample
            return false
        }

        lastAcceptedIntervalSeconds = sampleInterval
        recordAcceptedTiming(observation)
        lastSampleDisposition =
            observation.sampleAgeSeconds > Self.maximumFirstSampleAgeSeconds
            ? .acceptedDelayed
            : .acceptedFresh
        return true
    }

    private mutating func recordAcceptedTiming(_ observation: CadenceObservation) {
        lastElapsedSeconds = observation.elapsedSeconds
        lastAcceptedSampleEndDateSeconds = observation.sampleEndDateSeconds
        pendingStaleElapsedSeconds = nil
        pendingStaleSampleEndDateSeconds = nil
    }

    private mutating func acceptDelayedSampleAfterUntrustedBaseline(
        _ observation: CadenceObservation
    ) -> Bool {
        guard let priorElapsed = pendingStaleElapsedSeconds,
            let priorEnd = pendingStaleSampleEndDateSeconds,
            let sampleEnd = observation.sampleEndDateSeconds
        else {
            recordUntrustedTiming(observation)
            lastSampleDisposition = .staleSample
            return false
        }

        if sampleEnd == priorEnd || observation.elapsedSeconds == priorElapsed {
            lastSampleDisposition = .repeatedTimestamp
            return false
        }
        guard sampleEnd > priorEnd else {
            lastSampleDisposition = .backwardTimestamp
            return false
        }

        let interval = observation.elapsedSeconds - priorElapsed
        guard interval > 0 else {
            lastSampleDisposition = .outOfOrderCallback
            return false
        }
        guard interval <= Self.maximumExplainedSampleGapSeconds else {
            recordUntrustedTiming(observation)
            lastSampleDisposition = .unexplainedGap
            return false
        }

        let allowedAge = min(
            max(Self.maximumFirstSampleAgeSeconds, interval + Self.deliveryDelayToleranceSeconds),
            Self.maximumDeferredSampleAgeSeconds
        )
        guard observation.sampleAgeSeconds <= allowedAge else {
            recordUntrustedTiming(observation)
            lastSampleDisposition = .staleSample
            return false
        }

        lastAcceptedIntervalSeconds = interval
        recordAcceptedTiming(observation)
        lastSampleDisposition = .acceptedDelayed
        return true
    }

    private mutating func recordUntrustedTiming(_ observation: CadenceObservation) {
        guard let sampleEnd = observation.sampleEndDateSeconds else { return }
        pendingStaleElapsedSeconds = observation.elapsedSeconds
        pendingStaleSampleEndDateSeconds = sampleEnd
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
        let latest = Array(recentValues.suffix(Self.samplesToAcquire))
        guard latest.count == Self.samplesToAcquire,
            maximumAbsoluteDeviation(latest) <= Self.agreementSPM
        else {
            return .acquiring
        }

        let acquired = median(latest)
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

    private func maximumAbsoluteDeviation(_ values: [Double]) -> Double {
        let center = median(values)
        return values.map { abs($0 - center) }.max() ?? 0
    }

    private func move(_ value: Double, toward target: Double, maximumChange: Double) -> Double {
        if value < target { return min(value + maximumChange, target) }
        return max(value - maximumChange, target)
    }

    private mutating func recordMissing() -> CadenceEstimate {
        missingCount += 1
        if publishedSPM == nil {
            recentValues.removeAll(keepingCapacity: true)
        }
        if missingCount >= Self.missingSamplesBeforeReacquiring {
            publishedSPM = nil
            recentValues.removeAll(keepingCapacity: true)
            pendingLargeChange = nil
            state = .reacquiring
        }
        return publishedSPM.map(CadenceEstimate.locked) ?? .acquiring
    }
}
