public enum RhythmControlMode: String, Sendable, Equatable, Codable {
    case automatic
    case manual
}

public enum RhythmAdjustmentDirection: String, Sendable, Equatable, Codable {
    case increase
    case decrease
}

public struct RhythmControlState: Sendable, Equatable, Codable {
    public static let runningTargetRange = 120...210
    public static let automaticCorrectionRange = -20...20
    public static let manualTargetRange = runningTargetRange

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
        self.manualTargetBPM = Self.manualTargetRange.clamped(manualTargetBPM)
    }

    public static let initial = RhythmControlState()

    public func requestedBPM(cadenceSPM: Double?) -> Double? {
        switch mode {
        case .automatic:
            cadenceSPM.map {
                let requested = $0 + Double(automaticCorrectionBPM)
                return min(
                    max(requested, Double(Self.runningTargetRange.lowerBound)),
                    Double(Self.runningTargetRange.upperBound)
                )
            }
        case .manual:
            Double(manualTargetBPM)
        }
    }

    public mutating func adjust(by steps: Int) -> Bool {
        let prior = self
        switch mode {
        case .automatic:
            automaticCorrectionBPM = Self.automaticCorrectionRange.clamped(
                automaticCorrectionBPM + steps
            )
        case .manual:
            manualTargetBPM = Self.manualTargetRange.clamped(manualTargetBPM + steps)
        }
        return self != prior
    }

    public mutating func setManualTargetBPM(_ bpm: Int) {
        mode = .manual
        manualTargetBPM = Self.manualTargetRange.clamped(bpm)
    }

    public mutating func useManual(seedBPM: Double?) {
        mode = .manual
        if let seedBPM {
            manualTargetBPM = Self.manualTargetRange.clamped(Int(seedBPM.rounded()))
        }
    }

    public mutating func resetToAutomatic() {
        mode = .automatic
        automaticCorrectionBPM = 0
    }
}

private extension ClosedRange where Bound == Int {
    func clamped(_ value: Int) -> Int {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}
