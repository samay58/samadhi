public enum RhythmControlMode: String, Sendable, Equatable, Codable {
    case automatic
    case manual
}

public enum RhythmAdjustmentDirection: String, Sendable, Equatable, Codable {
    case increase
    case decrease
}

// The BPM a single song can actually reach. Manual travel is bounded by this so the wheel never
// offers a value the current track cannot produce inside the proven rate envelope.
public struct ManualTempoEnvelope: Sendable, Equatable {
    public let bpmRange: ClosedRange<Int>

    public init?(
        cadencePulseBPM: Double,
        minimumRate: Double = TempoEnvelope.rateRange.lowerBound,
        maximumRate: Double = TempoEnvelope.rateRange.upperBound,
        targetRange: ClosedRange<Int> = TempoEnvelope.locomotionCadenceRange
    ) {
        guard cadencePulseBPM > 0, minimumRate > 0, minimumRate <= maximumRate else {
            return nil
        }
        // Nudge before rounding so a bound that is exactly an integer in real arithmetic is not
        // pushed off the envelope by binary floating-point error.
        let lower = max(
            targetRange.lowerBound,
            Int(((cadencePulseBPM * minimumRate) - 0.000_001).rounded(.up))
        )
        let upper = min(
            targetRange.upperBound,
            Int(((cadencePulseBPM * maximumRate) + 0.000_001).rounded(.down))
        )
        guard lower <= upper else { return nil }
        bpmRange = lower...upper
    }

    public func clamped(_ bpm: Int) -> Int {
        bpmRange.clamped(bpm)
    }
}

public struct RhythmControlState: Sendable, Equatable, Codable {
    public static let automaticCorrectionRange = -20...20

    public var mode: RhythmControlMode
    public var automaticCorrectionBPM: Int
    public var manualTargetBPM: Int

    public init(
        mode: RhythmControlMode = .automatic,
        automaticCorrectionBPM: Int = 0,
        manualTargetBPM: Int = 168
    ) {
        self.mode = mode
        self.automaticCorrectionBPM = Self.automaticCorrectionRange.clamped(automaticCorrectionBPM)
        self.manualTargetBPM = TempoEnvelope.locomotionCadenceRange.clamped(manualTargetBPM)
    }

    public static let initial = RhythmControlState()

    public func requestedBPM(cadenceSPM: Double?) -> Double? {
        switch mode {
        case .automatic:
            cadenceSPM.map {
                let requested = $0 + Double(automaticCorrectionBPM)
                return min(
                    max(requested, TempoEnvelope.locomotionCadenceSPM.lowerBound),
                    TempoEnvelope.locomotionCadenceSPM.upperBound
                )
            }
        case .manual:
            Double(manualTargetBPM)
        }
    }

    public mutating func adjust(
        by steps: Int,
        manualEnvelope: ManualTempoEnvelope? = nil
    ) -> Bool {
        let prior = self
        switch mode {
        case .automatic:
            automaticCorrectionBPM = Self.automaticCorrectionRange.clamped(
                automaticCorrectionBPM + steps
            )
        case .manual:
            manualTargetBPM = Self.clampManualTarget(manualTargetBPM + steps, within: manualEnvelope)
        }
        return self != prior
    }

    public mutating func setManualTargetBPM(
        _ bpm: Int,
        manualEnvelope: ManualTempoEnvelope? = nil
    ) {
        mode = .manual
        manualTargetBPM = Self.clampManualTarget(bpm, within: manualEnvelope)
    }

    public mutating func useManual(
        seedBPM: Double?,
        manualEnvelope: ManualTempoEnvelope? = nil
    ) {
        mode = .manual
        if let seedBPM {
            manualTargetBPM = Self.clampManualTarget(
                Int(seedBPM.rounded()),
                within: manualEnvelope
            )
        }
    }

    public mutating func resetToAutomatic() {
        mode = .automatic
        automaticCorrectionBPM = 0
    }

    // Without a current track there is no per-song envelope, so the supported movement range applies.
    private static func clampManualTarget(
        _ bpm: Int,
        within envelope: ManualTempoEnvelope?
    ) -> Int {
        envelope?.clamped(bpm) ?? TempoEnvelope.locomotionCadenceRange.clamped(bpm)
    }
}

private extension ClosedRange where Bound == Int {
    func clamped(_ value: Int) -> Int {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}
