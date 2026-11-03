import AVFoundation
import Foundation
import UIKit

// The conditions a run happened under: battery, heat, whether the screen was locked, and where the
// sound went. Read when something changes and every 30 seconds, so it adds no timer of its own.
struct DeviceContext: Codable, Equatable, Sendable {
    struct Output: Codable, Equatable, Sendable {
        let type: String
        let name: String
    }

    let reason: String
    let batteryLevel: Float
    let batteryState: String
    let thermalState: String
    let lowPowerMode: Bool
    let appState: String
    let protectedDataAvailable: Bool
    let outputs: [Output]
    let outputVolume: Float
    let outputLatencySeconds: Double
}

struct TimedDeviceContext: Codable, Equatable, Sendable {
    let offsetSeconds: Double
    let context: DeviceContext
}

#if DEBUG
    extension DeviceContext {
        @MainActor
        static func current(reason: String) -> DeviceContext {
            let session = AVAudioSession.sharedInstance()
            let application = UIApplication.shared
            return DeviceContext(
                reason: reason,
                batteryLevel: UIDevice.current.batteryLevel,
                batteryState: String(describing: UIDevice.current.batteryState.rawValue),
                thermalState: String(describing: ProcessInfo.processInfo.thermalState.rawValue),
                lowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
                appState: String(describing: application.applicationState.rawValue),
                protectedDataAvailable: application.isProtectedDataAvailable,
                outputs: session.currentRoute.outputs.map {
                    Output(type: $0.portType.rawValue, name: $0.portName)
                },
                outputVolume: session.outputVolume,
                outputLatencySeconds: session.outputLatency
            )
        }
    }

    // Lives as long as its model, and stops listening when the model goes.
    final class DeviceContextObserver {
        private var tokens: [any NSObjectProtocol] = []

        @MainActor
        init(onChange: @escaping @MainActor (String) -> Void) {
            UIDevice.current.isBatteryMonitoringEnabled = true
            let reasons: [(Notification.Name, String)] = [
                (UIApplication.didEnterBackgroundNotification, "enteredBackground"),
                (UIApplication.willEnterForegroundNotification, "enteringForeground"),
                (UIApplication.protectedDataWillBecomeUnavailableNotification, "locking"),
                (UIApplication.protectedDataDidBecomeAvailableNotification, "unlocked"),
                (AVAudioSession.routeChangeNotification, "routeChanged"),
                (ProcessInfo.thermalStateDidChangeNotification, "thermalChanged"),
                (.NSProcessInfoPowerStateDidChange, "lowPowerChanged"),
            ]
            tokens = reasons.map { name, reason in
                NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
                    MainActor.assumeIsolated { onChange(reason) }
                }
            }
        }

        deinit {
            tokens.forEach(NotificationCenter.default.removeObserver)
        }
    }
#endif
