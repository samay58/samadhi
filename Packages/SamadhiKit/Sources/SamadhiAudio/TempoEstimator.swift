import Accelerate
import SamadhiDomain

struct TempoEstimator: Sendable {
    static let analysisVersion = 2

    init() {}

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

        let scores = stride(from: 60.0, through: 200.0, by: 0.25).map { tempo in
            let lag = 60 * envelope.rate / tempo
            let correlation = normalizedCorrelation(envelope.values, lag: lag)
            return TempoScore(
                tempo: tempo,
                correlation: correlation
            )
        }
        guard let best = scores.max(by: { $0.correlation < $1.correlation }),
            best.correlation >= 0.32
        else { return nil }
        if best.tempo < 80,
            let tripleMeterAlias = score(near: best.tempo * 1.5, in: scores),
            let doubleTempo = score(near: best.tempo * 2, in: scores),
            tripleMeterAlias.correlation >= 0.3,
            doubleTempo.correlation < 0.3
        {
            return nil
        }

        let competingScore =
            scores
            .filter { !sameTempoFamily($0.tempo, best.tempo) }
            .map(\.correlation)
            .max() ?? 0
        let separation = max(best.correlation - competingScore, 0)
        let confidence = min(max((best.correlation - 0.18) / 0.55 + separation, 0), 1)
        guard confidence >= TempoAnalysis.readyConfidence else { return nil }

        return TempoAnalysis(
            baseBPM: best.tempo,
            confidence: confidence,
            analyzedDurationSeconds: Double(samples.count) / sampleRate,
            version: Self.analysisVersion
        )
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

    private func sameTempoFamily(_ lhs: Double, _ rhs: Double) -> Bool {
        [rhs / 2, rhs, rhs * 2].contains { abs(lhs - $0) / $0 <= 0.04 }
    }

    private func score(near tempo: Double, in scores: [TempoScore]) -> TempoScore? {
        scores.min { abs($0.tempo - tempo) < abs($1.tempo - tempo) }
    }
}

private struct TempoScore {
    let tempo: Double
    let correlation: Double
}
