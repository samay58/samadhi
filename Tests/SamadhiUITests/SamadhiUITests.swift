import XCTest

@MainActor
final class SamadhiUITests: XCTestCase {
    private var app: XCUIApplication!

    func testGoldenFlow() {
        prepareApp("-SAMADHI_TEST_ACQUISITION_WINDOW")
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(element("ready-screen").waitForExistence(timeout: 10))
        let start = app.buttons["start-run"]
        XCTAssertTrue(start.waitForExistence(timeout: 2))
        start.tap()

        XCTAssertTrue(app.staticTexts["Listening for your stride"].waitForExistence(timeout: 2))
        XCTAssertTrue(element("cadence-lock").waitForExistence(timeout: 3))

        element("track-identity").tap()
        let pause = app.buttons["pause-run"]
        XCTAssertTrue(pause.waitForExistence(timeout: 2))
        pause.tap()

        let resume = app.buttons["resume-run"]
        XCTAssertTrue(resume.waitForExistence(timeout: 2))
        resume.tap()

        XCTAssertTrue(app.buttons["skip-track"].waitForExistence(timeout: 2))
        app.buttons["skip-track"].tap()
        XCTAssertTrue(app.staticTexts["Afterimage"].waitForExistence(timeout: 2))

        element("track-identity").tap()
        XCTAssertTrue(app.buttons["finish-run"].waitForExistence(timeout: 2))
        app.buttons["finish-run"].tap()
        let hold = app.buttons["hold-to-finish"]
        XCTAssertTrue(hold.waitForExistence(timeout: 2))
        hold.press(forDuration: 1.5)

        XCTAssertTrue(element("run-summary").waitForExistence(timeout: 3))
        app.buttons["summary-done"].tap()
        XCTAssertTrue(element("ready-screen").waitForExistence(timeout: 2))
    }

    func testPermissionRecoveryUsesFixedRhythm() {
        prepareApp("-SAMADHI_PERMISSION_DENIED")
        app.launch()
        XCTAssertTrue(app.buttons["start-run"].waitForExistence(timeout: 2))
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("permission-recovery").waitForExistence(timeout: 2))
        app.buttons["use-fixed-rhythm"].tap()
        XCTAssertTrue(element("run-screen").waitForExistence(timeout: 2))
    }

    func testRouteLossRequiresExplicitResume() {
        prepareApp("-SAMADHI_ROUTE_LOST")
        app.launch()
        XCTAssertTrue(app.buttons["start-run"].waitForExistence(timeout: 2))
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("route-recovery").waitForExistence(timeout: 3))
        let resume = app.buttons["route-resume"]
        XCTAssertTrue(resume.waitForExistence(timeout: 2))
        resume.tap()
        XCTAssertTrue(element("run-screen").waitForExistence(timeout: 2))
    }

    func testMissingArtworkStillStarts() {
        prepareApp("-SAMADHI_MISSING_ARTWORK")
        app.launch()
        XCTAssertTrue(app.buttons["start-run"].waitForExistence(timeout: 2))
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("run-screen").waitForExistence(timeout: 2))
    }

    func testNoCollectionRequiresMusicChoice() {
        prepareApp("-SAMADHI_MUSIC_NONE")
        app.launch()

        XCTAssertTrue(app.buttons["choose-music"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["start-run"].exists)
    }

    func testAnalysisProgressIsHonest() {
        prepareApp("-SAMADHI_MUSIC_ANALYZING")
        app.launch()

        XCTAssertTrue(element("music-analyzing").waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["2 of 8 tracks"].exists)
        XCTAssertFalse(app.buttons["start-run"].exists)
    }

    func testPartialCollectionCanStartWithFailuresVisible() {
        prepareApp("-SAMADHI_MUSIC_PARTIAL")
        app.launch()

        XCTAssertTrue(element("music-ready").waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Rhythm unclear"].exists)
        XCTAssertTrue(app.staticTexts["Preview unavailable"].exists)
        XCTAssertTrue(app.buttons["start-run"].exists)
        app.buttons["all-imported-tracks"].tap()
        XCTAssertTrue(app.staticTexts["Distant Signal"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Warm Static"].exists)
        XCTAssertTrue(app.staticTexts["Side Street"].exists)
    }

    func testImportFailureOffersRetry() {
        prepareApp("-SAMADHI_MUSIC_IMPORT_FAILURE")
        app.launch()

        XCTAssertTrue(element("music-import-failed").waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["choose-music"].exists)
        XCTAssertFalse(app.buttons["start-run"].exists)
    }

    func testTempoControlRevealsAndSwitchesOwnership() {
        prepareApp()
        app.launch()
        XCTAssertTrue(app.buttons["start-run"].waitForExistence(timeout: 2))
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("cadence-lock").waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Turn the ring to tune"].exists)

        element("tempo-control").tap()
        XCTAssertTrue(element("rhythm-dial").waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["rhythm-auto"].exists)
        XCTAssertTrue(app.buttons["rhythm-manual"].exists)

        let dial = element("rhythm-dial")
        let top = dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08))
        let right = dial.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5))
        top.press(
            forDuration: 0.12,
            thenDragTo: right,
            withVelocity: .slow,
            thenHoldForDuration: 0.2
        )
        XCTAssertTrue(app.staticTexts["178"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Music 178"].waitForExistence(timeout: 2))

        right.press(
            forDuration: 0.12,
            thenDragTo: top,
            withVelocity: .slow,
            thenHoldForDuration: 0.2
        )
        let reverseTarget = waitForDialAgreement(dial, below: 178)
        XCTAssertNotNil(reverseTarget)

        dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        if let reverseTarget {
            XCTAssertTrue(app.staticTexts[String(reverseTarget)].exists)
        }

        app.buttons["rhythm-manual"].tap()
        XCTAssertTrue(app.buttons["rhythm-manual"].isSelected)

        app.buttons["rhythm-auto"].tap()
        XCTAssertTrue(app.buttons["rhythm-auto"].isSelected)
        XCTAssertTrue(app.staticTexts["168"].exists)
    }

    func testNormalSimulatorLaunchUsesLocalDemoMusic() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        XCTAssertTrue(element("music-ready").waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Samadhi demo"].exists)
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("cadence-lock").waitForExistence(timeout: 6))
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func waitForDialAgreement(
        _ dial: XCUIElement,
        below upperBound: Int,
        timeout: TimeInterval = 2
    ) -> Int? {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            let numbers = String(describing: dial.value ?? "")
                .split(whereSeparator: { !$0.isNumber })
                .compactMap { Int($0) }
            if numbers.count >= 2, numbers[0] < upperBound, numbers[0] == numbers[1] {
                return numbers[0]
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        } while Date() < deadline
        return nil
    }

    private func prepareApp(_ additionalArgument: String? = nil) {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-SAMADHI_FAST_MODE"]
        if let additionalArgument { app.launchArguments.append(additionalArgument) }
    }
}
