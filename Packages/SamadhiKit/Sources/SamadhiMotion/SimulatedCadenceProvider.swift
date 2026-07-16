import Foundation
import SamadhiDomain

public enum SimulatedCadenceSignal: Sendable, Equatable {
    case acquiring
    case locked(spm: Int)
}

public struct SimulatedCadenceProvider: Sendable {
    private let sampleDelay: Duration
    private let lockedSPM: Int

    public init(sampleDelay: Duration = .milliseconds(420), lockedSPM: Int = 168) {
        self.sampleDelay = sampleDelay
        self.lockedSPM = lockedSPM
    }

    public func samples() -> AsyncStream<SimulatedCadenceSignal> {
        AsyncStream { continuation in
            let task = Task {
                do {
                    continuation.yield(.acquiring)
                    try await Task.sleep(for: sampleDelay)
                    continuation.yield(.acquiring)
                    try await Task.sleep(for: sampleDelay)
                    continuation.yield(.locked(spm: lockedSPM))
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
                for await sample in samples() {
                    switch sample {
                    case .acquiring:
                        continuation.yield(
                            .observation(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 0))
                        )
                    case let .locked(spm):
                        continuation.yield(
                            .observation(CadenceObservation(stepsPerMinute: Double(spm), elapsedSeconds: 0))
                        )
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
