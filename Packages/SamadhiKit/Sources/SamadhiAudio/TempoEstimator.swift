import Accelerate
import SamadhiDomain

package struct TempoEstimator: Sendable {
    static let analysisVersion = 5

    init() {}

    /// Everything the estimator saw for one preview, for the probe tool. The product never reads this.
    package struct Probe: Sendable {
        package let analysis: TempoAnalysis?
        package let scores: [(tempo: Double, correlation: Double)]
    }

    package func probe(samples: [Float], sampleRate: Double) -> Probe {
        guard sampleRate.isFinite, sampleRate > 0, samples.count >= Int(sampleRate * 8),
            let envelope = spectralFluxEnvelope(samples: samples, sampleRate: sampleRate)
        else { return Probe(analysis: nil, scores: []) }
        let scores = tempoScores(envelope: envelope)
        let estimate = estimate(from: scores, support: supportScores(envelope: envelope))
        let analysis = estimate.map {
            TempoAnalysis(
                baseBPM: $0.primary.tempo,
                alternatePulseBPM: $0.alternate?.tempo,
                confidence: $0.confidence,
                analyzedDurationSeconds: Double(samples.count) / sampleRate,
                version: Self.analysisVersion
            )
        }
        return Probe(analysis: analysis, scores: scores.map { ($0.tempo, $0.correlation) })
    }

    func analyze(samples: [Float], sampleRate: Double) -> TempoAnalysis? {
        guard sampleRate.isFinite,
            sampleRate > 0,
            samples.count >= Int(sampleRate * 8),
            samples.allSatisfy(\.isFinite)
        else { return nil }

        guard let envelope = spectralFluxEnvelope(samples: samples, sampleRate: sampleRate),
            envelope.values.count >= 800,
            envelope.values.max() ?? 0 > 0.000_1
        else { return nil }

        let scores = tempoScores(envelope: envelope)
        guard let estimate = estimate(from: scores, support: supportScores(envelope: envelope))
        else { return nil }

        return TempoAnalysis(
            baseBPM: estimate.primary.tempo,
            alternatePulseBPM: estimate.alternate?.tempo,
            confidence: estimate.confidence,
            analyzedDurationSeconds: Double(samples.count) / sampleRate,
            version: Self.analysisVersion
        )
    }

    private func tempoScores(envelope: (values: [Double], rate: Double)) -> [TempoScore] {
        stride(from: 60.0, through: 210.0, by: 0.25).map { tempo in
            let lag = 60 * envelope.rate / tempo
            return TempoScore(tempo: tempo, correlation: normalizedCorrelation(envelope.values, lag: lag))
        }
    }

    // Support lags outside the candidate window, so a 117 BPM beat can still be backed by its half
    // at 58.5 and a 64 BPM pulse by its double at 128. Coarser, because they only ever support.
    private func supportScores(envelope: (values: [Double], rate: Double)) -> [TempoScore] {
        let below = stride(from: 30.0, to: 60.0, by: 0.5)
        let above = stride(from: 210.5, through: 420.0, by: 0.5)
        return (Array(below) + Array(above)).map { tempo in
            let lag = 60 * envelope.rate / tempo
            return TempoScore(tempo: tempo, correlation: normalizedCorrelation(envelope.values, lag: lag))
        }
    }

    private func estimate(from scores: [TempoScore], support: [TempoScore]) -> TempoEstimate? {
        // A tempo is judged with its family: the candidate plus its half or double. Swung and live
        // grooves put a strong lag at one and a half beats, which used to outrank the true beat on
        // its own; the true beat still has its half or double behind it, and that lag does not.
        let family = scores + support
        guard
            let lower = scores.filter({ $0.tempo < 120 }).max(
                by: { familyScore($0, among: family) < familyScore($1, among: family) }
            ),
            let running = scores.filter({ $0.tempo >= 120 }).max(
                by: { familyScore($0, among: family) < familyScore($1, among: family) }
            )
        else { return nil }

        let pairIsSupported =
            isDoublePulse(lower: lower, running: running)
            && lower.correlation >= 0.32
            && running.correlation >= 0.32
        if pairIsSupported {
            let primary: TempoScore
            let alternate: TempoScore
            if running.tempo > 190 {
                primary = lower
                alternate = running
            } else if running.correlation >= 0.50
                || running.correlation >= lower.correlation * 1.10
            {
                primary = running
                alternate = lower
            } else {
                primary = lower
                alternate = running
            }
            let harmonicConfidence = min(
                max((((lower.correlation + running.correlation) / 2) - 0.18) / 0.29, 0),
                1
            )
            let confidence = max(
                confidence(for: primary, among: scores),
                harmonicConfidence
            )
            guard confidence >= TempoAnalysis.readyConfidence else { return nil }
            return TempoEstimate(
                primary: primary,
                alternate: alternate,
                confidence: confidence
            )
        }

        // Not a pair, so the stronger family stands alone. A low pulse with a strong triple is the
        // deliberate rejection: that is a triple meter the step relationship cannot name honestly.
        let best =
            familyScore(lower, among: family) >= familyScore(running, among: family) ? lower : running
        guard best.correlation >= 0.32 else { return nil }
        if best.tempo < 120,
            let triple = score(near: best.tempo * 3, in: family),
            triple.correlation >= 0.32
        {
            return nil
        }
        let confidence = confidence(for: best, among: scores)
        guard confidence >= TempoAnalysis.readyConfidence else { return nil }
        return TempoEstimate(primary: best, alternate: nil, confidence: confidence)
    }

    private func familyScore(_ score: TempoScore, among scores: [TempoScore]) -> Double {
        let partner = score.tempo < 120 ? score.tempo * 2 : score.tempo / 2
        let support = self.score(near: partner, in: scores)?.correlation ?? 0
        return score.correlation + (0.5 * support)
    }

    // Lags that sit at a simple ratio to the candidate are the same groove seen through another
    // subdivision, not evidence for a different tempo, so they do not count against it. A lag that is
    // unrelated to the candidate still does.
    private static let relatedRatios: [Double] = [0.5, 2, 2 / 3, 3 / 2, 3 / 4, 4 / 3, 1 / 3, 3]

    private func confidence(for best: TempoScore, among scores: [TempoScore]) -> Double {
        let competingScore =
            scores
            .filter { candidate in
                let ratio = candidate.tempo / best.tempo
                guard abs(ratio - 1) > 0.04 else { return false }
                return !Self.relatedRatios.contains { abs(ratio - $0) / $0 <= 0.025 }
            }
            .map(\.correlation)
            .max() ?? 0
        let separation = max(best.correlation - competingScore, 0)
        return min(max((best.correlation - 0.18) / 0.55 + separation, 0), 1)
    }

    private func isDoublePulse(lower: TempoScore, running: TempoScore) -> Bool {
        abs(running.tempo - (lower.tempo * 2)) / running.tempo <= 0.02
    }

    private func score(near tempo: Double, in scores: [TempoScore]) -> TempoScore? {
        guard
            let score = scores.min(
                by: { abs($0.tempo - tempo) < abs($1.tempo - tempo) }
            ),
            abs(score.tempo - tempo) / tempo <= 0.02
        else { return nil }
        return score
    }

    private func spectralFluxEnvelope(
        samples: [Float],
        sampleRate: Double
    ) -> (values: [Double], rate: Double)? {
        let frameSize = spectralFrameSize(sampleRate: sampleRate)
        let hopSize = max(Int((sampleRate * 0.01).rounded()), 1)
        guard samples.count >= frameSize,
            let setup = vDSP_DFT_zop_CreateSetup(nil, vDSP_Length(frameSize), .FORWARD)
        else { return nil }
        defer { vDSP_DFT_DestroySetup(setup) }

        let binCount = frameSize / 2
        let frameCount = 1 + ((samples.count - frameSize) / hopSize)
        let window = hannWindow(count: frameSize)
        var inputReal = Array(repeating: Float.zero, count: frameSize)
        var inputImaginary = Array(repeating: Float.zero, count: frameSize)
        var outputReal = Array(repeating: Float.zero, count: frameSize)
        var outputImaginary = Array(repeating: Float.zero, count: frameSize)
        var previousMagnitudes = Array(repeating: Float.zero, count: binCount)
        var flux = Array(repeating: 0.0, count: frameCount)

        for frameIndex in 0..<frameCount {
            let start = frameIndex * hopSize
            samples.withUnsafeBufferPointer { samplesPointer in
                window.withUnsafeBufferPointer { windowPointer in
                    guard let samplesBase = samplesPointer.baseAddress,
                        let windowBase = windowPointer.baseAddress
                    else { return }
                    vDSP_vmul(
                        samplesBase + start,
                        1,
                        windowBase,
                        1,
                        &inputReal,
                        1,
                        vDSP_Length(frameSize)
                    )
                }
            }
            vDSP_DFT_Execute(
                setup,
                &inputReal,
                &inputImaginary,
                &outputReal,
                &outputImaginary
            )

            var total = 0.0
            for bin in 1..<binCount {
                let magnitude = hypot(outputReal[bin], outputImaginary[bin])
                let compressed = log1p(magnitude)
                total += Double(max(compressed - previousMagnitudes[bin], 0))
                previousMagnitudes[bin] = compressed
            }
            flux[frameIndex] = total / Double(binCount)
        }

        let thresholded = subtractLocalAverage(flux, radius: 8)
        return (smooth(thresholded), sampleRate / Double(hopSize))
    }

    private func spectralFrameSize(sampleRate: Double) -> Int {
        let target = Int((sampleRate * 0.046).rounded())
        var size = 256
        while size < target, size < 4_096 {
            size *= 2
        }
        return size
    }

    private func hannWindow(count: Int) -> [Float] {
        guard count > 1 else { return [1] }
        return (0..<count).map { index in
            Float(0.5 - (0.5 * cos((2 * .pi * Double(index)) / Double(count - 1))))
        }
    }

    private func subtractLocalAverage(_ values: [Double], radius: Int) -> [Double] {
        var prefix = Array(repeating: 0.0, count: values.count + 1)
        for index in values.indices {
            prefix[index + 1] = prefix[index] + values[index]
        }

        return values.indices.map { index in
            let lower = max(index - radius, 0)
            let upper = min(index + radius + 1, values.count)
            let average = (prefix[upper] - prefix[lower]) / Double(upper - lower)
            return max(values[index] - average, 0)
        }
    }

    private func smooth(_ values: [Double]) -> [Double] {
        guard values.count > 2 else { return values }
        var smoothed = values
        for index in 1..<values.count - 1 {
            smoothed[index] =
                (0.25 * values[index - 1])
                + (0.5 * values[index])
                + (0.25 * values[index + 1])
        }
        return smoothed
    }

    private func normalizedCorrelation(_ values: [Double], lag: Double) -> Double {
        let start = Int(ceil(lag))
        let count = values.count - start
        guard count > 0 else { return 0 }

        var shifted = Array(repeating: 0.0, count: count)
        for offset in 0..<count {
            let sourcePosition = Double(start + offset) - lag
            let lower = Int(sourcePosition.rounded(.down))
            let fraction = sourcePosition - Double(lower)
            let upper = min(lower + 1, values.count - 1)
            shifted[offset] = values[lower] + ((values[upper] - values[lower]) * fraction)
        }

        var dot = 0.0
        var leadingEnergy = 0.0
        var shiftedEnergy = 0.0
        values.withUnsafeBufferPointer { valuesPointer in
            shifted.withUnsafeBufferPointer { shiftedPointer in
                guard let valuesBase = valuesPointer.baseAddress,
                    let shiftedBase = shiftedPointer.baseAddress
                else { return }
                let leading = valuesBase + start
                vDSP_dotprD(
                    leading,
                    1,
                    shiftedBase,
                    1,
                    &dot,
                    vDSP_Length(count)
                )
                vDSP_svesqD(leading, 1, &leadingEnergy, vDSP_Length(count))
                vDSP_svesqD(
                    shiftedBase,
                    1,
                    &shiftedEnergy,
                    vDSP_Length(count)
                )
            }
        }
        let scale = (leadingEnergy * shiftedEnergy).squareRoot()
        return scale > 0 ? dot / scale : 0
    }

}

private struct TempoScore {
    let tempo: Double
    let correlation: Double
}

private struct TempoEstimate {
    let primary: TempoScore
    let alternate: TempoScore?
    let confidence: Double
}
