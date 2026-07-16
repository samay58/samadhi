import SamadhiDomain
import Testing

@testable import SamadhiMotion

@Test func cadenceSimulationHasDeterministicOrderingAndCompletion() async {
    let provider = SimulatedCadenceProvider(sampleDelay: .zero, lockedSPM: 172)
    var samples: [SimulatedCadenceSignal] = []
    for await sample in provider.samples() {
        samples.append(sample)
    }
    #expect(samples == [.acquiring, .acquiring, .locked(spm: 172)])
}

@Test func simulationAlsoUsesTheProductionProviderBoundary() async {
    let provider: any CadenceProviding = SimulatedCadenceProvider(sampleDelay: .zero, lockedSPM: 172)
    var events: [CadenceProviderEvent] = []
    for await event in provider.events() {
        events.append(event)
    }

    #expect(
        events == [
            .observation(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 0)),
            .observation(CadenceObservation(stepsPerMinute: nil, elapsedSeconds: 0)),
            .observation(CadenceObservation(stepsPerMinute: 172, elapsedSeconds: 0)),
        ]
    )
}
