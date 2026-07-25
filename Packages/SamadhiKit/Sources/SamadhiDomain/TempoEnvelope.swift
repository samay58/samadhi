// Shared evidence-backed limits keep matching, controls, and player commands consistent.
public enum TempoEnvelope {
    public static let rateRange: ClosedRange<Double> = 0.90...1.10
    public static let runningCadenceRange: ClosedRange<Int> = 120...210

    public static let runningCadenceBPM: ClosedRange<Double> =
        Double(runningCadenceRange.lowerBound)...Double(runningCadenceRange.upperBound)

    public static func clampRate(_ rate: Double) -> Double {
        min(max(rate, rateRange.lowerBound), rateRange.upperBound)
    }
}
