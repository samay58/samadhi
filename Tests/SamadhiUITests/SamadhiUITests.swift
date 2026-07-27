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
        XCTAssertFalse(app.buttons["change-music"].exists)
    }

    func testPlaylistPickerOpensScrollsAndSelects() {
        prepareApp("-SAMADHI_MUSIC_LIBRARY_LARGE")
        app.launch()

        app.buttons["choose-music"].tap()
        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["playlist-choice-simulator-library-1"].exists)

        let lastPlaylist = app.buttons["playlist-choice-simulator-library-40"]
        for _ in 0..<10 where !lastPlaylist.exists {
            app.swipeUp()
        }
        XCTAssertTrue(lastPlaylist.waitForExistence(timeout: 2))
        lastPlaylist.tap()

        XCTAssertTrue(element("music-ready").waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Long Run 40"].exists)
    }

    func testChangingMusicMarksTheCurrentPlaylist() {
        prepareApp()
        app.launch()

        app.buttons["change-music"].tap()
        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 2))
        let current = app.buttons["playlist-choice-simulator-demo"]
        XCTAssertTrue(current.exists)
        XCTAssertTrue(current.label.contains("Current playlist"))
    }

    func testPlaylistLoadingKeepsOneTruthfulBusyAction() {
        prepareApp("-SAMADHI_MUSIC_LOADING")
        app.launch()

        XCTAssertTrue(element("music-loading").waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["start-run"].exists)
        XCTAssertFalse(app.buttons["choose-music"].exists)
    }

    func testAnalysisProgressIsHonest() {
        prepareApp("-SAMADHI_MUSIC_ANALYZING")
        app.launch()

        XCTAssertTrue(element("music-analyzing").waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["2 / 8"].exists)
        XCTAssertFalse(app.buttons["start-run"].exists)
    }

    func testPartialCollectionCanStartWithFailuresVisible() {
        prepareApp("-SAMADHI_MUSIC_PARTIAL")
        app.launch()

        XCTAssertTrue(element("music-ready").waitForExistence(timeout: 2))
        let results = element("all-imported-tracks")
        XCTAssertTrue(results.waitForExistence(timeout: 2))
        XCTAssertTrue(results.label.contains("1 ready"))
        XCTAssertTrue(results.label.contains("5 skipped"))
        XCTAssertTrue(app.buttons["start-run"].exists)
        results.tap()
        XCTAssertTrue(app.staticTexts["Rhythm unclear"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Preview unavailable"].exists)
        XCTAssertTrue(app.staticTexts["Distant Signal"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Warm Static"].exists)
        XCTAssertTrue(app.staticTexts["Side Street"].exists)
    }

    func testImportFailureOffersRetry() {
        prepareApp("-SAMADHI_MUSIC_IMPORT_FAILURE")
        app.launch()

        XCTAssertTrue(element("music-import-failed").waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["retry-music-import"].exists)
        XCTAssertTrue(app.buttons["choose-another-music"].exists)
        XCTAssertFalse(app.buttons["start-run"].exists)

        app.buttons["retry-music-import"].tap()
        XCTAssertTrue(element("music-ready").waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Soft Miles"].exists)
    }

    func testImportFailureCanChooseAnotherPlaylist() {
        prepareApp("-SAMADHI_MUSIC_IMPORT_FAILURE")
        app.launch()

        XCTAssertTrue(element("music-import-failed").waitForExistence(timeout: 2))
        app.buttons["choose-another-music"].tap()
        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 2))
    }

    func testAuthorizationFailureUsesSettingsAndLibraryRetry() {
        prepareApp("-SAMADHI_MUSIC_AUTHORIZATION_FAILURE")
        app.launch()

        XCTAssertTrue(element("music-import-failed").waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Apple Music access is off"].exists)
        XCTAssertTrue(app.buttons["open-settings"].exists)
        XCTAssertTrue(app.buttons["retry-playlist-library"].exists)

        app.buttons["retry-playlist-library"].tap()
        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 2))
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

        let trackIdentity = element("track-identity")
        XCTAssertTrue(trackIdentity.exists)
        let originalTrackLabel = trackIdentity.label
        let dial = element("rhythm-dial")
        let top = dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08))
        let right = dial.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5))
        let initialBPM = currentDisplayedBPM()
        XCTAssertNotNil(initialBPM)
        for _ in 0..<8 {
            turn(from: top, to: right)
        }

        guard let upperBoundaryBPM = currentDisplayedBPM() else {
            XCTFail("The dial must keep showing its current BPM")
            return
        }
        XCTAssertGreaterThan(upperBoundaryBPM, initialBPM ?? 0)
        XCTAssertEqual(trackIdentity.label, originalTrackLabel)
        XCTAssertFalse(app.staticTexts["Changing song"].exists)

        for _ in 0..<2 {
            turn(from: top, to: right)
        }
        XCTAssertEqual(currentDisplayedBPM(), upperBoundaryBPM)
        XCTAssertEqual(trackIdentity.label, originalTrackLabel)

        turn(from: right, to: top)
        guard let reversedBPM = currentDisplayedBPM() else {
            XCTFail("The dial must keep showing its current BPM")
            return
        }
        XCTAssertLessThan(reversedBPM, upperBoundaryBPM)
        XCTAssertEqual(trackIdentity.label, originalTrackLabel)

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

    private func currentDisplayedBPM() -> Int? {
        app.staticTexts.allElementsBoundByIndex
            .lazy
            .compactMap { Int($0.label) }
            .first { 120...210 ~= $0 }
    }

    private func turn(from start: XCUICoordinate, to end: XCUICoordinate) {
        start.press(
            forDuration: 0.12,
            thenDragTo: end,
            withVelocity: .slow,
            thenHoldForDuration: 0.2
        )
    }

    private func prepareApp(_ additionalArgument: String? = nil) {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-SAMADHI_FAST_MODE"]
        if let additionalArgument { app.launchArguments.append(additionalArgument) }
    }
}
