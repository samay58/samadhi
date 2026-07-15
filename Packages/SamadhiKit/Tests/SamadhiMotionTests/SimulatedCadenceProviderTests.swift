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
