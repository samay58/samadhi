#if os(iOS)
    import CoreMotion
    import Foundation
    import SamadhiDomain

    public final class CoreMotionCadenceProvider: CadenceProviding, @unchecked Sendable {
        private let pedometer: CMPedometer

        public init(pedometer: CMPedometer = CMPedometer()) {
            self.pedometer = pedometer
        }

        public func events() -> AsyncStream<CadenceProviderEvent> {
            let start = Date()

            return AsyncStream { [weak self] continuation in
                guard let self else {
                    continuation.finish()
                    return
                }
                guard CMPedometer.isCadenceAvailable() else {
                    continuation.yield(.unavailable(.notSupported))
                    continuation.finish()
                    return
                }

                if [.denied, .restricted].contains(CMPedometer.authorizationStatus()) {
                    continuation.yield(.unavailable(.permissionDenied))
                    continuation.finish()
                    return
                }

                pedometer.startUpdates(from: start) { data, error in
                    if error != nil {
                        let reason: CadenceUnavailableReason =
                            [.denied, .restricted].contains(CMPedometer.authorizationStatus())
                            ? .permissionDenied
                            : .sensorFailure
                        continuation.yield(.unavailable(reason))
                        continuation.finish()
                        return
                    }

                    let now = Date()
                    let sampleDate = data?.endDate ?? now
                    continuation.yield(
                        .observation(
                            CadenceObservation(
                                stepsPerMinute: data?.currentCadence.map { $0.doubleValue * 60 },
                                elapsedSeconds: sampleDate.timeIntervalSince(start),
                                sampleAgeSeconds: now.timeIntervalSince(sampleDate)
                            )
                        )
                    )
                }

                continuation.onTermination = { [weak self] _ in
                    self?.pedometer.stopUpdates()
                }
            }
        }
    }
#endif
