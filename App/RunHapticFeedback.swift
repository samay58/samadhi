import CoreHaptics
import SamadhiDomain
import UIKit

@MainActor
final class RunHapticFeedback {
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    private var rhythmEngine: CHHapticEngine?
    private var nextRhythmTime = 0.0

    func prepareRhythmStep() {
        prepareRhythmEngine()
        try? rhythmEngine?.start()
        nextRhythmTime = rhythmEngine?.currentTime ?? 0
        lightImpact.prepare()
        softImpact.prepare()
    }

    func emit(_ event: HapticEvent) {
        switch event {
        case .start, .resume:
            lightImpact.impactOccurred()
        case .transportRequest:
            selection.selectionChanged()
            selection.prepare()
        case .finishArmed:
            softImpact.impactOccurred(intensity: 0.6)
        case .lock:
            notification.notificationOccurred(.success)
        case .pause:
            mediumImpact.impactOccurred()
        case .finish:
            heavyImpact.impactOccurred()
        case let .rhythmStep(direction, isMajor):
            if !playRhythmDetent(direction: direction, isMajor: isMajor) {
                switch direction {
                case .increase:
                    lightImpact.impactOccurred(intensity: isMajor ? 1 : 0.76)
                case .decrease:
                    softImpact.impactOccurred(intensity: isMajor ? 1 : 0.88)
                }
            }
            lightImpact.prepare()
            softImpact.prepare()
        case .rhythmAuto:
            softImpact.impactOccurred(intensity: 0.82)
            softImpact.prepare()
        case .rhythmLimit:
            notification.notificationOccurred(.warning)
        }
    }

    private func prepareRhythmEngine() {
        guard rhythmEngine == nil,
            CHHapticEngine.capabilitiesForHardware().supportsHaptics
        else { return }
        do {
            let engine = try CHHapticEngine()
            engine.playsHapticsOnly = true
            engine.isAutoShutdownEnabled = false
            try engine.start()
            rhythmEngine = engine
            engine.resetHandler = { [weak self] in
                try? self?.rhythmEngine?.start()
            }
        } catch {
            rhythmEngine = nil
        }
    }

    private func playRhythmDetent(
        direction: RhythmAdjustmentDirection,
        isMajor: Bool
    ) -> Bool {
        guard let engine = rhythmEngine else { return false }
        do {
            let primary = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(
                        parameterID: .hapticIntensity,
                        value: isMajor ? 0.74 : 0.46
                    ),
                    CHHapticEventParameter(
                        parameterID: .hapticSharpness,
                        value: direction == .increase ? 0.22 : 0.1
                    ),
                ],
                relativeTime: direction == .increase ? 0 : 0.012
            )
            let directionalAccent = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(
                        parameterID: .hapticIntensity,
                        value: isMajor ? 0.3 : 0.18
                    ),
                    CHHapticEventParameter(
                        parameterID: .hapticSharpness,
                        value: 0.04
                    ),
                ],
                relativeTime: direction == .increase ? 0.012 : 0
            )
            var events = [primary, directionalAccent]
            if isMajor {
                events.append(
                    CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.14),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.04),
                        ],
                        relativeTime: 0.018,
                        duration: 0.032
                    )
                )
            }

            let player = try engine.makePlayer(with: CHHapticPattern(events: events, parameters: []))
            let scheduledTime = max(engine.currentTime, nextRhythmTime)
            try player.start(atTime: scheduledTime)
            nextRhythmTime = scheduledTime + (isMajor ? 0.05 : 0.034)
            return true
        } catch {
            return false
        }
    }
}
