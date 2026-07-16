import SamadhiDomain

public enum CadenceEstimate: Sendable, Equatable {
    case acquiring
    case locked(stepsPerMinute: Double)
}

public struct CadenceFilter: Sendable {
    private var recentValues: [Double] = []
    private var publishedSPM: Double?
    private var priorSPM: Double?
    private var missingCount = 0

    public init(priorSPM: Double? = nil) {
        self.priorSPM = priorSPM
    }

    public mutating func ingest(_ observation: CadenceObservation) -> CadenceEstimate {
        guard let value = observation.stepsPerMinute else {
            missingCount += 1
            if missingCount >= 3 {
                priorSPM = publishedSPM ?? priorSPM
                publishedSPM = nil
                recentValues.removeAll(keepingCapacity: true)
            }
            return publishedSPM.map(CadenceEstimate.locked) ?? .acquiring
        }

        guard (120...210).contains(value) else {
            return publishedSPM.map(CadenceEstimate.locked) ?? .acquiring
        }

        missingCount = 0
        recentValues.append(value)
        if recentValues.count > 6 {
            recentValues.removeFirst()
        }

        if let publishedSPM {
            let target = median(recentValues)
            guard medianAbsoluteDeviation(recentValues) <= 3,
                abs(target - publishedSPM) > 2
            else {
                return .locked(stepsPerMinute: publishedSPM)
            }
            let smoothed = publishedSPM + (0.2 * (target - publishedSPM))
            let limited = move(publishedSPM, toward: smoothed, maximumChange: 2)
            self.publishedSPM = limited
            return .locked(stepsPerMinute: limited)
        }

        let requiredCount = priorSPM == nil ? 5 : 3
        guard recentValues.count >= requiredCount,
            medianAbsoluteDeviation(recentValues) <= 3
        else {
            return .acquiring
        }

        let target = median(recentValues)
        let acquired: Double
        if let priorSPM {
            let smoothed = priorSPM + (0.2 * (target - priorSPM))
            acquired = move(priorSPM, toward: smoothed, maximumChange: 2)
        } else {
            acquired = target
        }
        publishedSPM = acquired
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
}
