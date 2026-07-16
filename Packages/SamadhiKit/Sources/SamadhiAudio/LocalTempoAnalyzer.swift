import AVFoundation
import Foundation
import SamadhiDomain

public protocol TempoAnalyzing: Sendable {
    func analyze(fileURL: URL) async throws -> TempoAnalysis?
}

public struct LocalTempoAnalyzer: TempoAnalyzing {
    private let estimator = TempoEstimator()

    public init() {}

    public func analyze(fileURL: URL) async throws -> TempoAnalysis? {
        let decoded = try await Task.detached(priority: .utility) {
            try Self.decodeMono(fileURL: fileURL)
        }.value
        return estimator.analyze(samples: decoded.samples, sampleRate: decoded.sampleRate)
    }

    private static func decodeMono(fileURL: URL) throws -> (samples: [Float], sampleRate: Double) {
        let file = try AVAudioFile(forReading: fileURL)
        let format = file.processingFormat
        let maximumFrames = AVAudioFramePosition(format.sampleRate * 60)
        let frameCount = AVAudioFrameCount(min(file.length, maximumFrames))
        guard frameCount > 0,
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        else { throw TempoAnalyzerError.unreadablePCM }

        try file.read(into: buffer, frameCount: frameCount)
        guard buffer.frameLength > 0, let channels = buffer.floatChannelData else {
            throw TempoAnalyzerError.unreadablePCM
        }

        let channelCount = Int(format.channelCount)
        let sampleCount = Int(buffer.frameLength)
        var mono = Array(repeating: Float.zero, count: sampleCount)
        for channelIndex in 0..<channelCount {
            let channel = channels[channelIndex]
            for sampleIndex in 0..<sampleCount {
                mono[sampleIndex] += channel[sampleIndex] / Float(channelCount)
            }
        }
        return (mono, format.sampleRate)
    }
}

public enum TempoAnalyzerError: Error, Sendable, Equatable {
    case unreadablePCM
}
