// One shared limit keeps matching, controls, diagnostics, and player commands consistent.
public enum TempoEnvelope {
    public static let rateRange: ClosedRange<Double> = 0.85...1.15
    public static let locomotionCadenceRange: ClosedRange<Int> = 90...210
    public static let runningCadenceRange: ClosedRange<Int> = 120...210
    public static let approximateMatchToleranceSPM = 5.0

    public static let locomotionCadenceSPM: ClosedRange<Double> =
        Double(locomotionCadenceRange.lowerBound)...Double(locomotionCadenceRange.upperBound)

    public static let runningCadenceSPM: ClosedRange<Double> =
        Double(runningCadenceRange.lowerBound)...Double(runningCadenceRange.upperBound)

    public static func clampRate(_ rate: Double) -> Double {
        min(max(rate, rateRange.lowerBound), rateRange.upperBound)
    }
}
