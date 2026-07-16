import SamadhiDomain

struct TempoEstimator: Sendable {
    static let analysisVersion = 1

    init() {}

    func analyze(samples: [Float], sampleRate: Double) -> TempoAnalysis? {
        guard sampleRate.isFinite,
            sampleRate > 0,
            samples.count >= Int(sampleRate * 8),
            samples.allSatisfy(\.isFinite)
        else { return nil }

        let frameSize = max(Int(sampleRate * 0.02), 1)
        let envelope = onsetEnvelope(samples: samples, frameSize: frameSize)
        guard envelope.count >= 400, envelope.max() ?? 0 > 0.000_1 else { return nil }

        let envelopeRate = sampleRate / Double(frameSize)
        let minimumLag = max(Int((60 * envelopeRate / 200).rounded()), 1)
        let maximumLag = min(Int((60 * envelopeRate / 60).rounded()), envelope.count / 2)
        guard maximumLag > minimumLag else { return nil }

        let scores = (minimumLag...maximumLag).map { lag in
            (lag: lag, score: normalizedCorrelation(envelope, lag: lag))
        }
        guard let best = scores.max(by: { $0.score < $1.score }),
            best.score >= 0.45
        else { return nil }

        let tempo = 60 * envelopeRate / refinedLag(best.lag, scores: scores)
        guard (60...200).contains(tempo) else { return nil }
        let confidence = min(max((best.score - 0.2) / 0.75, 0), 1)
        guard confidence >= TempoAnalysis.readyConfidence else { return nil }

        return TempoAnalysis(
            baseBPM: tempo,
            confidence: confidence,
            analyzedDurationSeconds: Double(samples.count) / sampleRate,
            version: Self.analysisVersion
        )
    }

    private func onsetEnvelope(samples: [Float], frameSize: Int) -> [Double] {
        let frameCount = samples.count / frameSize
        var energy = Array(repeating: 0.0, count: frameCount)
        for frameIndex in 0..<frameCount {
            let start = frameIndex * frameSize
            let end = start + frameSize
            var sum = 0.0
            for sample in samples[start..<end] {
                let value = Double(sample)
                sum += value * value
            }
            energy[frameIndex] = sum / Double(frameSize)
        }

        var envelope = Array(repeating: 0.0, count: frameCount)
        for index in 1..<frameCount {
            envelope[index] = max(energy[index] - energy[index - 1], 0)
        }
        guard envelope.count > 2 else { return envelope }
        var smoothed = envelope
        for index in 1..<envelope.count - 1 {
            smoothed[index] =
                (0.25 * envelope[index - 1])
                + (0.5 * envelope[index])
                + (0.25 * envelope[index + 1])
        }
        return smoothed
    }

    private func normalizedCorrelation(_ values: [Double], lag: Int) -> Double {
        var dot = 0.0
        var leadingEnergy = 0.0
        var trailingEnergy = 0.0
        for index in lag..<values.count {
            let leading = values[index]
            let trailing = values[index - lag]
            dot += leading * trailing
            leadingEnergy += leading * leading
            trailingEnergy += trailing * trailing
        }
        let scale = (leadingEnergy * trailingEnergy).squareRoot()
        return scale > 0 ? dot / scale : 0
    }

    private func refinedLag(_ lag: Int, scores: [(lag: Int, score: Double)]) -> Double {
        guard let index = scores.firstIndex(where: { $0.lag == lag }),
            index > scores.startIndex,
            index < scores.index(before: scores.endIndex)
        else { return Double(lag) }

        let previous = scores[scores.index(before: index)].score
        let center = scores[index].score
        let next = scores[scores.index(after: index)].score
        let denominator = previous - (2 * center) + next
        guard abs(denominator) > 0.000_001 else { return Double(lag) }
        let offset = 0.5 * (previous - next) / denominator
        return Double(lag) + min(max(offset, -0.5), 0.5)
    }
}
