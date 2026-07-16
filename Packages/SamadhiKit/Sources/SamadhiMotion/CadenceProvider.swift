import SamadhiDomain

public enum CadenceUnavailableReason: Sendable, Equatable {
    case permissionDenied
    case notSupported
    case sensorFailure
}

public enum CadenceProviderEvent: Sendable, Equatable {
    case observation(CadenceObservation)
    case unavailable(CadenceUnavailableReason)
}

public protocol CadenceProviding: Sendable {
    func events() -> AsyncStream<CadenceProviderEvent>
}
