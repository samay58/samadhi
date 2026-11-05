import Darwin
import SamadhiDesign
import SamadhiDomain
import SwiftUI
import Testing
import UIKit

@testable import Samadhi

// These tests draw a screen directly from its state inside the running test host. That takes a
// fraction of a second where a tap-through launches the whole app, and the environments they set
// really apply. Real touch and the whole app wired together stay with SamadhiUITests.

// SwiftUI builds its accessibility tree only when something asks for it. This test-only switch is
// the one accessibility snapshot libraries use. It never ships in the app.
private let accessibilityTreeEnabled: Bool = {
    guard let library = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW),
        let symbol = dlsym(library, "_AXSSetAutomationEnabled")
    else { return false }
    typealias SetEnabled = @convention(c) (Int32) -> Void
    unsafeBitCast(symbol, to: SetEnabled.self)(1)
    return true
}()

private struct DrawingEnvironment {
    let name: String
    var reduceMotion = false
    var increasedContrast = false
    var dynamicType = DynamicTypeSize.large
    var appearance = UIUserInterfaceStyle.light
    // Lists and scroll views only build what fits. A taller window keeps every control in the tree.
    var height: CGFloat = 874

    static let all = [
        DrawingEnvironment(name: "normal"),
        DrawingEnvironment(name: "dark", appearance: .dark),
        DrawingEnvironment(name: "reduce-motion", reduceMotion: true),
        DrawingEnvironment(name: "increased-contrast", increasedContrast: true),
        DrawingEnvironment(name: "accessibility-xxxl", dynamicType: .accessibility5, height: 1400),
    ]
}

@MainActor
private final class HostedScreen {
    let window: UIWindow
    private let box: ActionBox

    var sent: [RunAction] { box.actions }

    init(_ state: RunViewState, in environment: DrawingEnvironment = DrawingEnvironment.all[0]) throws {
        var state = state
        state.forceReduceMotion = environment.reduceMotion
        state.forceIncreasedContrast = environment.increasedContrast
        let box = ActionBox()
        self.box = box
        window = try Self.show(
            SamadhiScreen(state: state) { box.actions.append($0) }
                .environment(\.dynamicTypeSize, environment.dynamicType),
            height: environment.height,
            appearance: environment.appearance
        )
    }

    init(view: some View, dynamicType: DynamicTypeSize = .large, height: CGFloat = 874) throws {
        box = ActionBox()
        window = try Self.show(view.environment(\.dynamicTypeSize, dynamicType), height: height)
    }

    private static func show(
        _ view: some View,
        height: CGFloat,
        appearance: UIUserInterfaceStyle = .light
    ) throws -> UIWindow {
        #expect(accessibilityTreeEnabled)
        let scene = try #require(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        )
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 402, height: height)
        window.overrideUserInterfaceStyle = appearance
        let host = UIHostingController(rootView: view)
        window.rootViewController = host
        window.isHidden = false
        host.view.frame = window.bounds
        host.view.layoutIfNeeded()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.15))
        return window
    }

    func element(_ identifier: String) -> NSObject? {
        find(identifier, in: window, depth: 0)
    }

    private func find(_ identifier: String, in object: NSObject, depth: Int) -> NSObject? {
        guard depth < 60 else { return nil }
        // SwiftUI's accessibility nodes answer this selector without declaring the protocol.
        let selector = NSSelectorFromString("accessibilityIdentifier")
        if object.responds(to: selector),
            object.perform(selector)?.takeUnretainedValue() as? String == identifier
        {
            return object
        }
        if let view = object as? UIView {
            for child in view.subviews {
                if let found = find(identifier, in: child, depth: depth + 1) { return found }
            }
        }
        let count = object.accessibilityElementCount()
        guard count != NSNotFound else { return nil }
        for index in 0..<count {
            if let child = object.accessibilityElement(at: index) as? NSObject,
                let found = find(identifier, in: child, depth: depth + 1)
            {
                return found
            }
        }
        return nil
    }

    func midY(_ identifier: String) throws -> CGFloat {
        try #require(element(identifier), "\(identifier) is missing").accessibilityFrame.midY
    }

    func recordFrame(named name: String) {
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        if let data = image.pngData() {
            Attachment.record(data, named: "\(name).png")
        }
    }
}

@MainActor
private final class ActionBox {
    var actions: [RunAction] = []
}

@MainActor
@Suite struct ScreenRenderingTests {
    private func controls(_ phase: RunVisualPhase) -> RunViewState {
        RunViewState(phase: phase, controlsVisible: true)
    }

    // A runner's thumb is already on its way when these controls change, so the target has to stay put.
    @Test(arguments: DrawingEnvironment.all)
    fileprivate func finishKeepsItsPlaceWhenItArms(_ environment: DrawingEnvironment) throws {
        let running = try HostedScreen(controls(.running), in: environment)
        let armed = try HostedScreen(controls(.confirmingFinish), in: environment)

        let finish = try running.midY("finish-run")
        let hold = try armed.midY("hold-to-finish")
        #expect(abs(finish - hold) <= 1, "Finish \(finish), Hold \(hold)")
        running.recordFrame(named: "after-transport-\(environment.name)")
        armed.recordFrame(named: "after-finish-armed-\(environment.name)")
    }

    @Test(arguments: DrawingEnvironment.all)
    fileprivate func pauseAndResumeShareOnePlace(_ environment: DrawingEnvironment) throws {
        let running = try HostedScreen(controls(.running), in: environment)
        let paused = try HostedScreen(controls(.paused), in: environment)

        let pause = try running.midY("pause-run")
        let resume = try paused.midY("resume-run")
        #expect(abs(pause - resume) <= 1, "Pause \(pause), Resume \(resume)")
        paused.recordFrame(named: "after-transport-paused-\(environment.name)")
    }

    @Test func theOpenWheelShowsItsTempoOverTheSpeaker() throws {
        let state = RunViewState(
            phase: .running,
            rhythmControl: RhythmControlPresentation(
                mode: .automatic,
                requestedBPM: 168,
                appliedBPM: 169,
                isVisible: true,
                isAvailable: true
            )
        )
        let screen = try HostedScreen(state)

        #expect(screen.element("rhythm-dial") != nil)
        screen.recordFrame(named: "tempo-control-open")
    }

    @Test func aLockBriefAppearingDoesNotMoveTheControls() throws {
        var briefed = controls(.running)
        briefed.showLockBrief = true
        let quiet = try HostedScreen(controls(.running))
        let announcing = try HostedScreen(briefed)

        #expect(abs(try quiet.midY("pause-run") - announcing.midY("pause-run")) <= 1)
    }

    @Test func transportOffersEveryControlAndEachSendsItsOwnAction() throws {
        let screen = try HostedScreen(controls(.running))

        for identifier in ["previous-track", "pause-run", "skip-track", "finish-run"] {
            let control = try #require(screen.element(identifier), "\(identifier) is missing")
            #expect(control.accessibilityActivate())
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        #expect(screen.sent.contains(.previous))
        #expect(screen.sent.contains(.pause))
        #expect(screen.sent.contains(.skip))
    }

    @Test(arguments: DrawingEnvironment.all)
    fileprivate func anOutOfReachPlaylistIsNamedInEveryEnvironment(_ environment: DrawingEnvironment) throws {
        var state = RunViewState(phase: .running)
        state.reachNotice = .mostlyFaster
        let screen = try HostedScreen(state, in: environment)

        let notice = try #require(screen.element("reach-notice"))
        #expect(notice.accessibilityLabel == "Most of this playlist is faster than you're moving.")
        screen.recordFrame(named: "out-of-reach-\(environment.name)")
    }

    @Test func theOutOfReachNoticeNamesTheSlowerDirectionToo() throws {
        var state = RunViewState(phase: .running)
        state.reachNotice = .mostlySlower
        let screen = try HostedScreen(state)

        let notice = try #require(screen.element("reach-notice"))
        #expect(notice.accessibilityLabel == "Most of this playlist is slower than you're moving.")
    }

    // A moving hand misses small targets, so every control a runner reaches for has to be big enough.
    @Test(arguments: DrawingEnvironment.all)
    fileprivate func autoAndManualAreBigEnoughToHit(_ environment: DrawingEnvironment) throws {
        let state = RunViewState(
            phase: .running,
            rhythmControl: RhythmControlPresentation(
                mode: .automatic,
                requestedBPM: 168,
                appliedBPM: 169,
                isVisible: true,
                isAvailable: true
            )
        )
        let screen = try HostedScreen(state, in: environment)

        for identifier in ["rhythm-auto", "rhythm-manual"] {
            let frame = try #require(screen.element(identifier), "\(identifier) is missing").accessibilityFrame
            #expect(frame.height >= 44 && frame.width >= 44, "\(identifier) is \(frame.size)")
        }
    }

    @Test func theWayOutOfARecoveryIsBigEnoughToHit() throws {
        let screen = try HostedScreen(
            RunViewState(phase: .routeRecovery(cause: .routeLost, restored: false))
        )

        let frame = try #require(screen.element("route-end-run")).accessibilityFrame
        #expect(frame.height >= 44, "End run is \(frame.size)")
    }

    @Test func aMissingCadenceIsNeverShownAsAnInventedNumber() throws {
        var state = RunViewState(phase: .running, cadenceSPM: nil)
        state.showLockBrief = true
        let screen = try HostedScreen(state)

        let label = try #require(screen.element("cadence-lock")).accessibilityLabel
        #expect(label == "Tempo matched", "label \(label ?? "nil")")
    }

    // Until the wheel can adjust anything, the largest thing on screen still answers a tap.
    @Test func tappingTheWheelBeforeItCanAdjustShowsTheControls() throws {
        let screen = try HostedScreen(
            RunViewState(
                phase: .acquiring,
                rhythmControl: RhythmControlPresentation(isAvailable: false)
            )
        )

        let wheel = try #require(screen.element("tempo-control"))
        #expect(wheel.accessibilityActivate())
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        #expect(screen.sent == [.revealControls])
    }

    @Test func voiceOverCanOpenTheTempoWheel() throws {
        let screen = try HostedScreen(
            RunViewState(
                phase: .running,
                rhythmControl: RhythmControlPresentation(appliedBPM: 169, isAvailable: true)
            )
        )

        let wheel = try #require(screen.element("tempo-control"))
        #expect(wheel.accessibilityActivate())
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        #expect(screen.sent.contains(.revealRhythmControl))
    }

    // Every screen a runner can reach, in both appearances. The frames are what a person looks at.
    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func everyScreenDrawsInBothAppearances(_ appearance: UIUserInterfaceStyle) throws {
        let collection = ImportedCollectionPresentation(
            name: "Morning Miles",
            totalTrackCount: 18,
            readyTrackCount: 18,
            completedTrackCount: 18,
            tracks: (0..<18).map {
                ImportedTrackPresentation(
                    id: "\($0)", title: "Song \($0)", status: .ready, pulseBPM: 120 + Double($0) * 4)
            }
        )
        let reading = ImportedCollectionPresentation(
            name: "Morning Miles",
            totalTrackCount: 18,
            readyTrackCount: 9,
            completedTrackCount: 9,
            tracks: (0..<9).map {
                ImportedTrackPresentation(
                    id: "\($0)", title: "Late Coffee", status: .ready, pulseBPM: 120 + Double($0) * 4)
            }
        )
        let open = RhythmControlPresentation(
            mode: .automatic, requestedBPM: 168, appliedBPM: 169, isVisible: true, isAvailable: true)
        let manual = RhythmControlPresentation(
            mode: .manual, requestedBPM: 172, appliedBPM: 171, isVisible: true, isAvailable: true)
        let locked = RhythmControlPresentation(appliedBPM: 169, isAvailable: true)
        let brief = RunViewState(phase: .running, cadenceSPM: 168, showLockBrief: true, rhythmControl: locked)

        let states: [(String, RunViewState)] = [
            ("01-empty", RunViewState(phase: .ready, musicSelection: .none)),
            ("02-reading", RunViewState(phase: .ready, musicSelection: .analyzing(reading))),
            ("03-ready", RunViewState(phase: .ready, musicSelection: .ready(collection))),
            ("04-failed", RunViewState(phase: .ready, musicSelection: .failed(.authorizationDenied))),
            ("05-acquiring", RunViewState(phase: .acquiring)),
            ("06-running", RunViewState(phase: .running, rhythmControl: locked)),
            ("07-lock-brief", brief),
            ("08-controls", RunViewState(phase: .running, controlsVisible: true, rhythmControl: locked)),
            ("09-wheel-auto", RunViewState(phase: .running, rhythmControl: open)),
            ("10-wheel-manual", RunViewState(phase: .running, rhythmControl: manual)),
            ("11-paused", RunViewState(phase: .paused, rhythmControl: locked)),
            ("12-finish-armed", RunViewState(phase: .confirmingFinish, controlsVisible: true, rhythmControl: locked)),
            ("13-route-lost", RunViewState(phase: .routeRecovery(cause: .routeLost, restored: false))),
            ("14-route-back", RunViewState(phase: .routeRecovery(cause: .routeLost, restored: true))),
            ("15-permission", RunViewState(phase: .permissionRecovery)),
            (
                "16-summary",
                RunViewState(
                    phase: .summary(
                        RunSummary(
                            durationSeconds: 1843,
                            averageCadence: 168,
                            tempoMatchedPercent: 86,
                            tempoMatchedCoveragePercent: 92,
                            automaticSeconds: 1500,
                            manualSeconds: 343,
                            songCount: 7
                        )
                    ))
            ),
        ]
        let environment = DrawingEnvironment(name: appearance == .dark ? "dark" : "light", appearance: appearance)
        for (name, state) in states {
            let screen = try HostedScreen(state, in: environment)
            screen.recordFrame(named: "\(environment.name)-\(name)")
        }
    }

    #if DEBUG
        @Test(arguments: [
            ("waiting", TempoDiagnosticStatus.waiting),
            ("verified", .verified),
            ("limited", .limited),
            ("rejected", .rejected),
        ])
        func diagnosticsDistinguishEveryAppleMusicResult(_ name: String, _ status: TempoDiagnosticStatus) throws {
            let screen = try HostedScreen(
                view: CoreLoopDiagnosticsView(presentation: .fixture(status)),
                height: 3000
            )

            let label = try #require(screen.element("tempo-command-status")).accessibilityLabel
            #expect(label?.isEmpty == false)
        }

        @Test func diagnosticsRemainReadableAtTheLargestTextSize() throws {
            let screen = try HostedScreen(
                view: CoreLoopDiagnosticsView(presentation: .fixture(.limited)),
                dynamicType: .accessibility5,
                height: 12000
            )

            #expect(screen.element("measured-song-speed") != nil)
            let label = screen.element("tempo-command-status")?.accessibilityLabel
            #expect(label == "Limited by this song", "label \(label ?? "nil")")
        }
    #endif
}
