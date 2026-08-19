import Foundation
import SamadhiDomain

public enum SimulatedCadenceSignal: Sendable, Equatable {
    case acquiring
    case locked(spm: Int)
}

// A scripted walk through cadence. The standard profile is the original demo shape. A settled
// change profile holds one cadence long enough for Auto to settle, then moves to a second cadence
// and holds it long enough for Auto to commit exactly one new target.
public struct SimulatedCadenceProfile: Sendable, Equatable {
    public struct Stage: Sendable, Equatable {
        public let stepsPerMinute: Int?
        public let sampleCount: Int

        public init(stepsPerMinute: Int?, sampleCount: Int) {
            self.stepsPerMinute = stepsPerMinute
            self.sampleCount = max(sampleCount, 1)
        }
    }

    public let stages: [Stage]

    public init(lockedSPM: Int = 168, holdSamples: Int = 5) {
        stages = [
            Stage(stepsPerMinute: nil, sampleCount: 1),
            Stage(stepsPerMinute: nil, sampleCount: 1),
            Stage(stepsPerMinute: lockedSPM, sampleCount: holdSamples),
        ]
    }

    private init(stages: [Stage]) {
        self.stages = stages
    }

    public static let standard = SimulatedCadenceProfile()

    // Five settled samples let Auto commit the first target and start its eight-second interval.
    // Eighteen changed samples cover the filter's response, the five-second sustained-change
    // evidence, and that interval, so the second commit is certain.
    public static func settledChange(
        from settledSPM: Int,
        to changedSPM: Int,
        settledSamples: Int = 5,
        changedSamples: Int = 18
    ) -> SimulatedCadenceProfile {
        SimulatedCadenceProfile(
            stages: [
                Stage(stepsPerMinute: nil, sampleCount: 1),
                Stage(stepsPerMinute: nil, sampleCount: 1),
                Stage(stepsPerMinute: settledSPM, sampleCount: settledSamples),
                Stage(stepsPerMinute: changedSPM, sampleCount: changedSamples),
            ]
        )
    }

    var signals: [SimulatedCadenceSignal] {
        stages.map { stage in
            stage.stepsPerMinute.map { SimulatedCadenceSignal.locked(spm: $0) } ?? .acquiring
        }
    }
}

public struct SimulatedCadenceProvider: Sendable {
    private let sampleDelay: Duration
    private let profile: SimulatedCadenceProfile

    public init(sampleDelay: Duration = .milliseconds(420), lockedSPM: Int = 168) {
        self.sampleDelay = sampleDelay
        profile = SimulatedCadenceProfile(lockedSPM: lockedSPM)
    }

    public init(sampleDelay: Duration = .milliseconds(420), profile: SimulatedCadenceProfile) {
        self.sampleDelay = sampleDelay
        self.profile = profile
    }

    public func samples() -> AsyncStream<SimulatedCadenceSignal> {
        AsyncStream { continuation in
            let task = Task {
                do {
                    for (index, signal) in profile.signals.enumerated() {
                        continuation.yield(signal)
                        guard index < profile.signals.count - 1 else { break }
                        try await Task.sleep(for: sampleDelay)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

extension SimulatedCadenceProvider: CadenceProviding {
    public func events() -> AsyncStream<CadenceProviderEvent> {
        AsyncStream { continuation in
            let task = Task {
                var elapsedSeconds = 0.0
                var stageIndex = 0
                for await _ in samples() {
                    guard profile.stages.indices.contains(stageIndex) else { break }
                    let stage = profile.stages[stageIndex]
                    stageIndex += 1
                    for _ in 0..<stage.sampleCount {
                        continuation.yield(
                            .observation(
                                CadenceObservation(
                                    stepsPerMinute: stage.stepsPerMinute.map(Double.init),
                                    elapsedSeconds: elapsedSeconds,
                                    sampleEndDateSeconds: elapsedSeconds
                                )
                            )
                        )
                        elapsedSeconds += 1
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
