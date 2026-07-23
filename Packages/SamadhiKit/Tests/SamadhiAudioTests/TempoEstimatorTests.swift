import AVFoundation
import Foundation
import SamadhiAudio
import SamadhiDomain
import Testing

@Test func periodicOnsetsProduceTheExpectedRunningPulse() async throws {
    let sampleRate = 8_000.0
    let samples = pulseTrain(bpm: 168, durationSeconds: 20, sampleRate: sampleRate)

    let result = try await analyze(samples: samples, sampleRate: sampleRate)

    #expect(result != nil)
    #expect(tempoError(result?.baseBPM ?? 0, referenceBPM: 168) <= 0.02)
    #expect(result?.confidence ?? 0 >= 0.72)
}

@Test func silenceIsRejectedInsteadOfReceivingAConfidentTempo() async throws {
    let sampleRate = 8_000.0

    let result = try await analyze(
        samples: Array(repeating: 0, count: Int(sampleRate * 20)),
        sampleRate: sampleRate
    )

    #expect(result == nil)
}

@Test(arguments: [120.0, 150.0, 190.0])
func generatedTempoCorpusStaysInsideTwoPercent(_ referenceBPM: Double) async throws {
    let sampleRate = 8_000.0
    let samples = pulseTrain(
        bpm: referenceBPM,
        durationSeconds: 24,
        sampleRate: sampleRate,
        accentEveryOtherBeat: true
    )

    let result = try await analyze(samples: samples, sampleRate: sampleRate)

    #expect(result != nil)
    #expect(tempoError(result?.baseBPM ?? 0, referenceBPM: referenceBPM) <= 0.02)
}

@Test func irregularOnsetsAreRejected() async throws {
    let sampleRate = 8_000.0
    let samples = irregularPulseTrain(durationSeconds: 24, sampleRate: sampleRate)

    let result = try await analyze(samples: samples, sampleRate: sampleRate)

    #expect(result == nil)
}

@Test func stereoAudioIsDownmixedBeforeEstimation() async throws {
    let sampleRate = 8_000.0
    let samples = pulseTrain(bpm: 150, durationSeconds: 20, sampleRate: sampleRate)

    let result = try await analyze(samples: samples, sampleRate: sampleRate, channels: 2)

    #expect(result != nil)
    #expect(tempoError(result?.baseBPM ?? 0, referenceBPM: 150) <= 0.02)
}

@Test func aStrongEveryThirdBeatAccentIsRejectedRatherThanMislabelled() async throws {
    let sampleRate = 8_000.0
    let samples = pulseTrain(
        bpm: 180,
        durationSeconds: 24,
        sampleRate: sampleRate,
        accentEveryThirdBeat: true
    )

    let result = try await analyze(samples: samples, sampleRate: sampleRate)

    #expect(result == nil)
}

@Test func aStableNinetyBPMMusicalPulseIsMeasuredTruthfullyWithoutInventingStrideEvidence()
    async throws
{
    let sampleRate = 8_000.0
    let samples = pulseTrain(bpm: 90, durationSeconds: 24, sampleRate: sampleRate)

    let result = try await analyze(samples: samples, sampleRate: sampleRate)

    #expect(result != nil)
    #expect(tempoError(result?.baseBPM ?? 0, referenceBPM: 90) <= 0.02)
    #expect(result?.alternatePulseBPM == nil)
    #expect(tempoError(result?.runningPulseBPM ?? 0, referenceBPM: 90) <= 0.02)
    #expect(result?.isAdaptiveReady == false)
}

@Test func aOneEightyPulseWithAlternatingAccentsStaysOneEighty() async throws {
    let sampleRate = 8_000.0
    let samples = pulseTrain(
        bpm: 180,
        durationSeconds: 24,
        sampleRate: sampleRate,
        accentEveryOtherBeat: true
    )

    let result = try await analyze(samples: samples, sampleRate: sampleRate)

    #expect(result != nil)
    #expect(tempoError(result?.baseBPM ?? 0, referenceBPM: 180) <= 0.02)
    #expect(tempoError(result?.runningPulseBPM ?? 0, referenceBPM: 180) <= 0.02)
}

private func analyze(
    samples: [Float],
    sampleRate: Double,
    channels: AVAudioChannelCount = 1
) async throws -> TempoAnalysis? {
    let fileURL = try writeAudioFile(
        samples: samples,
        sampleRate: sampleRate,
        channels: channels
    )
    defer { try? FileManager.default.removeItem(at: fileURL) }
    return try await LocalTempoAnalyzer().analyze(fileURL: fileURL)
}

private func pulseTrain(
    bpm: Double,
    durationSeconds: Double,
    sampleRate: Double,
    accentEveryOtherBeat: Bool = false,
    accentEveryThirdBeat: Bool = false
) -> [Float] {
    let sampleCount = Int(durationSeconds * sampleRate)
    let samplesPerBeat = sampleRate * 60 / bpm
    var samples = Array(repeating: Float.zero, count: sampleCount)
    var beat = 0.0
    var beatIndex = 0
    while Int(beat) < sampleCount {
        let start = Int(beat)
        let amplitude: Float
        if accentEveryThirdBeat {
            amplitude = beatIndex.isMultiple(of: 3) ? 1 : 0.12
        } else {
            amplitude = accentEveryOtherBeat && !beatIndex.isMultiple(of: 2) ? 0.45 : 1
        }
        for offset in 0..<min(8, sampleCount - start) {
            samples[start + offset] = amplitude * (1 - (Float(offset) / 8))
        }
        beat += samplesPerBeat
        beatIndex += 1
    }
    return samples
}

private func irregularPulseTrain(durationSeconds: Double, sampleRate: Double) -> [Float] {
    let sampleCount = Int(durationSeconds * sampleRate)
    var samples = Array(repeating: Float.zero, count: sampleCount)
    var position = 0
    var seed: UInt64 = 0x5A17
    while position < sampleCount {
        seed = (seed &* 6_364_136_223_846_793_005) &+ 1
        let intervalSeconds = 0.18 + (Double(seed % 670) / 1_000)
        position += Int(intervalSeconds * sampleRate)
        guard position < sampleCount else { break }
        samples[position] = 1
    }
    return samples
}

private func writeAudioFile(
    samples: [Float],
    sampleRate: Double,
    channels: AVAudioChannelCount
) throws -> URL {
    let url = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString)
        .appendingPathExtension("caf")
    guard
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: channels,
            interleaved: false
        )
    else { throw TempoFixtureError.couldNotCreateBuffer }
    guard
        let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(samples.count)
        )
    else { throw TempoFixtureError.couldNotCreateBuffer }
    buffer.frameLength = buffer.frameCapacity
    guard let channelData = buffer.floatChannelData else {
        throw TempoFixtureError.couldNotCreateBuffer
    }
    for channelIndex in 0..<Int(channels) {
        let channel = channelData[channelIndex]
        let gain: Float = channelIndex == 0 ? 1 : 0.6
        for index in samples.indices {
            channel[index] = samples[index] * gain
        }
    }
    var fileSettings = format.settings
    fileSettings[AVLinearPCMIsNonInterleaved] = false
    let file = try AVAudioFile(forWriting: url, settings: fileSettings)
    try file.write(from: buffer)
    return url
}

private enum TempoFixtureError: Error {
    case couldNotCreateBuffer
}

private func tempoError(_ actual: Double, referenceBPM: Double) -> Double {
    abs(actual - referenceBPM) / referenceBPM
}
