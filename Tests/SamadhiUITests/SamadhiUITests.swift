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
        XCTAssertTrue(app.staticTexts["Afterimage"].waitForExistence(timeout: 4))

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
        attachScreenshot(named: "setup-final-picker-large-scrolled")
        lastPlaylist.tap()

        XCTAssertTrue(element("music-ready").waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Long Run 40"].exists)
    }

    func testEmptyLibraryPickerKeepsAUsefulDismissiblePath() {
        prepareApp("-SAMADHI_MUSIC_LIBRARY_EMPTY")
        app.launch()

        app.buttons["choose-music"].tap()
        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["No playlists yet"].exists)
        XCTAssertTrue(app.buttons["reload-playlist-library"].exists)
        XCTAssertTrue(app.buttons["Cancel"].exists)
        XCTAssertEqual(playlistChoices.count, 0)
        attachScreenshot(named: "setup-final-picker-empty")

        app.buttons["reload-playlist-library"].tap()
        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 3))
    }

    func testTwoPlaylistPickerUsesACompactSheetAndStableChoices() {
        prepareApp("-SAMADHI_MUSIC_LIBRARY_TWO")
        app.launch()

        app.buttons["choose-music"].tap()
        let picker = element("playlist-picker")
        XCTAssertTrue(picker.waitForExistence(timeout: 2))
        XCTAssertEqual(playlistChoices.count, 2)
        XCTAssertTrue(app.buttons["playlist-choice-simulator-demo"].exists)
        XCTAssertTrue(app.buttons["playlist-choice-simulator-cruise"].exists)
        XCTAssertLessThan(picker.frame.height, app.windows.firstMatch.frame.height * 0.85)
        attachScreenshot(named: "setup-final-picker-two")

        app.buttons["playlist-choice-simulator-cruise"].tap()
        XCTAssertTrue(element("music-ready").waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Soft Miles"].exists)
    }

    func testSetupReviewSequenceKeepsOnePlaylistObject() {
        prepareApp([
            "-SAMADHI_MUSIC_NONE",
            "-SAMADHI_SETUP_REVIEW_MODE",
        ])
        app.launch()

        XCTAssertTrue(app.buttons["choose-music"].waitForExistence(timeout: 2))
        attachScreenshot(named: "setup-review-empty")
        app.buttons["choose-music"].tap()

        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 2))
        attachScreenshot(named: "setup-review-picker")
        app.buttons["playlist-choice-simulator-cruise"].tap()

        XCTAssertTrue(element("music-analyzing").waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["start-run"].exists)
        attachScreenshot(named: "setup-review-analyzing")

        XCTAssertTrue(element("music-ready").waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["start-run"].isHittable)
        XCTAssertTrue(app.staticTexts["Soft Miles"].exists)
        waitForVisualSettle()
        attachScreenshot(named: "setup-review-ready")
    }

    func testChangingMusicMarksTheCurrentPlaylist() {
        prepareApp()
        app.launch()

        app.buttons["change-music"].tap()
        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 2))
        let current = app.buttons["playlist-choice-simulator-demo"]
        XCTAssertTrue(current.exists)
        XCTAssertTrue(current.label.contains("Current playlist"))
        attachScreenshot(named: "setup-final-picker-current")
    }

    func testPlaylistLoadingKeepsOneTruthfulBusyAction() {
        prepareApp("-SAMADHI_MUSIC_LOADING")
        app.launch()

        XCTAssertTrue(element("music-loading").waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["start-run"].exists)
        XCTAssertFalse(app.buttons["choose-music"].exists)
    }

    func testPlaylistLoadingKeepsTheExistingSelectionVisible() {
        prepareApp("-SAMADHI_MUSIC_LOADING_SELECTED")
        app.launch()

        XCTAssertTrue(element("music-loading").waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Samadhi demo"].exists)
        XCTAssertFalse(app.buttons["start-run"].exists)
        XCTAssertFalse(app.buttons["change-music"].exists)
    }

    func testLongPlaylistNameRemainsCompleteAtNormalSize() {
        prepareApp("-SAMADHI_MUSIC_LONG_NAME")
        app.launch()

        let name = app.staticTexts["Saturday Miles Through the Hills After the Rain"]
        XCTAssertTrue(name.waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["start-run"].exists)
        XCTAssertTrue(app.buttons["change-music"].exists)
    }

    func testLongPlaylistNameKeepsStartReachableAtAccessibilitySize() {
        prepareApp([
            "-SAMADHI_MUSIC_LONG_NAME",
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL",
        ])
        app.launch()

        let name = app.staticTexts["Saturday Miles Through the Hills After the Rain"]
        XCTAssertTrue(name.waitForExistence(timeout: 2))
        let start = app.buttons["start-run"]
        XCTAssertTrue(start.exists)
        if !start.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(start.isHittable)
        XCTAssertGreaterThan(start.frame.width, app.windows.firstMatch.frame.width * 0.75)
        attachScreenshot(named: "setup-final-long-name-ax5")
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
        let readyCount = element("ready-track-count")
        XCTAssertTrue(readyCount.waitForExistence(timeout: 2))
        XCTAssertEqual(readyCount.label, "1 track ready")
        let results = app.buttons["review-skipped-tracks"]
        XCTAssertTrue(results.waitForExistence(timeout: 2))
        XCTAssertEqual(results.label, "Review 5 skipped tracks")
        XCTAssertTrue(app.buttons["start-run"].exists)
        attachScreenshot(named: "setup-final-partial-ready")
        results.tap()
        XCTAssertTrue(app.staticTexts["Rhythm unclear"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Preview unavailable"].exists)
        XCTAssertTrue(app.staticTexts["Distant Signal"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Warm Static"].exists)
        XCTAssertTrue(app.staticTexts["Side Street"].exists)

        let temporaryHeading = element("temporary-failure-section")
        let retry = app.buttons["retry-temporary-imports"]
        let readyTrack = app.staticTexts["Soft Current"]
        XCTAssertTrue(temporaryHeading.exists)
        XCTAssertTrue(retry.exists)
        XCTAssertTrue(readyTrack.exists)
        XCTAssertGreaterThan(retry.frame.minY, temporaryHeading.frame.minY)
        XCTAssertLessThan(retry.frame.minY, readyTrack.frame.minY)
        attachScreenshot(named: "setup-final-track-results")
    }

    func testImportFailureOffersRetry() {
        prepareApp("-SAMADHI_MUSIC_IMPORT_FAILURE")
        app.launch()

        XCTAssertTrue(element("music-import-failed").waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["retry-music-import"].exists)
        XCTAssertTrue(app.buttons["choose-another-music"].exists)
        XCTAssertFalse(app.buttons["start-run"].exists)
        attachScreenshot(named: "setup-final-import-failure")

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
        attachScreenshot(named: "setup-final-authorization-failure")

        app.buttons["retry-playlist-library"].tap()
        XCTAssertTrue(element("playlist-picker").waitForExistence(timeout: 2))
    }

    func testTempoControlRevealsAndSwitchesOwnership() {
        prepareApp()
        app.launch()
        XCTAssertTrue(app.buttons["start-run"].waitForExistence(timeout: 2))
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("cadence-lock").waitForExistence(timeout: 6))
        XCTAssertFalse(app.staticTexts["Turn the ring to tune"].exists)

        element("tempo-control").tap()
        XCTAssertTrue(element("rhythm-dial").waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["rhythm-auto"].exists)
        XCTAssertTrue(app.buttons["rhythm-manual"].exists)

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
        XCTAssertTrue(element("rhythm-dial").exists)
        XCTAssertFalse(app.buttons["pause-run"].exists)

        app.buttons["close-rhythm-control"].tap()
        element("tempo-control").tap()
        XCTAssertTrue(element("rhythm-dial").waitForExistence(timeout: 2))

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

        let close = app.buttons["close-rhythm-control"]
        XCTAssertTrue(close.exists)
        XCTAssertTrue(close.isHittable)
        assertCloseTargetClearsDial(close: close, dial: element("rhythm-dial"))
        attachScreenshot(named: "tempo-control-open-quiet-close")
        close.tap()
        XCTAssertTrue(app.buttons["pause-run"].waitForExistence(timeout: 2))
        XCTAssertFalse(element("rhythm-dial").exists)
        attachScreenshot(named: "tempo-control-closed-playback-controls")
    }

    func testManualReturnsToAutoOnlyAfterConfirmedSongChange() {
        prepareApp()
        app.launch()
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("cadence-lock").waitForExistence(timeout: 6))

        element("tempo-control").tap()
        app.buttons["rhythm-manual"].tap()
        XCTAssertTrue(app.buttons["rhythm-manual"].isSelected)
        attachScreenshot(named: "manual-before-confirmed-song-change")

        app.buttons["close-rhythm-control"].tap()
        let originalTrack = element("track-identity").label
        let skip = app.buttons["skip-track"]
        XCTAssertTrue(skip.waitForExistence(timeout: 2))
        skip.tap()

        let track = element("track-identity")
        let changed = NSPredicate(format: "label != %@", originalTrack)
        expectation(for: changed, evaluatedWith: track)
        waitForExpectations(timeout: 3)

        element("tempo-control").tap()
        XCTAssertTrue(app.buttons["rhythm-auto"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["rhythm-auto"].isSelected)
        XCTAssertFalse(app.buttons["rhythm-manual"].isSelected)
        attachScreenshot(named: "auto-after-confirmed-song-change")
    }

    func testTempoCloseRemainsUsableWithAccessibilityTextAndReduceMotion() {
        prepareApp([
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL",
            "-UIAccessibilityReduceMotionEnabled",
            "YES",
        ])
        app.launch()
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("cadence-lock").waitForExistence(timeout: 3))

        element("tempo-control").tap()
        let close = app.buttons["close-rhythm-control"]
        XCTAssertTrue(close.waitForExistence(timeout: 2))
        XCTAssertGreaterThanOrEqual(close.frame.width, 44)
        XCTAssertGreaterThanOrEqual(close.frame.height, 44)
        assertCloseTargetClearsDial(close: close, dial: element("rhythm-dial"))
        attachScreenshot(named: "tempo-close-accessibility-reduce-motion")

        close.tap()
        XCTAssertTrue(app.buttons["pause-run"].waitForExistence(timeout: 2))
        XCTAssertFalse(element("rhythm-dial").exists)
    }

    func testTempoCloseRemainsClearWithIncreasedContrast() {
        prepareApp(["-UIAccessibilityDarkerSystemColorsEnabled", "YES"])
        app.launch()
        app.buttons["start-run"].tap()
        XCTAssertTrue(element("cadence-lock").waitForExistence(timeout: 3))

        element("tempo-control").tap()
        let close = app.buttons["close-rhythm-control"]
        XCTAssertTrue(close.waitForExistence(timeout: 2))
        XCTAssertGreaterThanOrEqual(close.frame.width, 44)
        XCTAssertGreaterThanOrEqual(close.frame.height, 44)
        assertCloseTargetClearsDial(close: close, dial: element("rhythm-dial"))
        attachScreenshot(named: "tempo-close-increased-contrast")
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

    func testDiagnosticsKeepSongBeatsAndRunnerStepsSeparate() {
        prepareApp("--diagnostic-scenario=verified")
        app.launch()

        XCTAssertTrue(element("core-loop-diagnostics").waitForExistence(timeout: 3))
        XCTAssertTrue(element("build-identity-value").exists)
        XCTAssertFalse(element("build-identity-value").label.contains("unknown"))
        let sourceFingerprint = element("source-fingerprint-value")
        XCTAssertTrue(sourceFingerprint.exists)
        XCTAssertNotNil(
            sourceFingerprint.label.range(
                of: "[0-9a-f]{64}",
                options: .regularExpression
            )
        )
        for _ in 0..<3 where !element("measured-song-speed").exists {
            app.swipeUp()
        }
        XCTAssertTrue(element("measured-song-speed").label.contains("84.0 BPM"))
        XCTAssertTrue(element("step-relationship").label.contains("Two steps per beat"))
        XCTAssertTrue(element("original-step-rhythm").label.contains("168.0 SPM"))
        attachScreenshot(named: "core-diagnostics-low-tempo")
        for _ in 0..<4 where !element("settled-auto-target").exists {
            app.swipeUp()
        }
        XCTAssertTrue(element("sensor-sample-status").label.contains("Accepted, delayed but new"))
        XCTAssertTrue(element("settled-auto-target").label.contains("175 SPM, settled"))
        attachScreenshot(named: "core-diagnostics-sensor-and-auto-target")
    }

    func testDiagnosticsDistinguishEveryAppleMusicResult() {
        for status in ["waiting", "verified", "limited", "rejected"] {
            prepareApp("--diagnostic-scenario=\(status)")
            app.launch()
            XCTAssertTrue(element("core-loop-diagnostics").waitForExistence(timeout: 3))
            for _ in 0..<4 where !element("tempo-command-status").exists {
                app.swipeUp()
            }
            XCTAssertTrue(element("tempo-command-status").exists)
            XCTAssertFalse(element("tempo-command-status").label.isEmpty)
            attachScreenshot(named: "core-diagnostics-\(status)")
            app.terminate()
        }
    }

    func testTrackResetShowsNoOldAppleMusicReadback() {
        prepareApp("--diagnostic-scenario=waiting")
        app.launch()

        XCTAssertTrue(element("core-loop-diagnostics").waitForExistence(timeout: 3))
        for _ in 0..<8 where !element("tempo-command-status").exists {
            app.swipeUp()
        }
        XCTAssertTrue(element("apple-music-reported-rate").exists)
        XCTAssertTrue(element("apple-music-reported-rate").label.contains("Not available"))
        XCTAssertTrue(element("tempo-command-status").exists)
        XCTAssertEqual(element("tempo-command-status").label, "Waiting for Apple Music")
        attachScreenshot(named: "core-diagnostics-track-reset")
    }

    func testDiagnosticsRemainReadableAtAccessibilitySizeWithReduceMotion() {
        prepareApp([
            "--diagnostic-scenario=limited",
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL",
            "-UIAccessibilityReduceMotionEnabled",
            "YES",
        ])
        app.launch()

        XCTAssertTrue(element("core-loop-diagnostics").waitForExistence(timeout: 3))
        for _ in 0..<12 where !element("measured-song-speed").exists {
            app.swipeUp()
        }
        XCTAssertTrue(element("measured-song-speed").exists)
        for _ in 0..<12 where !element("tempo-command-status").exists {
            app.swipeUp()
        }
        XCTAssertEqual(element("tempo-command-status").label, "Limited by this song")
        attachScreenshot(named: "core-diagnostics-accessibility-reduce-motion")
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private var playlistChoices: XCUIElementQuery {
        app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "playlist-choice-")
        )
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func assertCloseTargetClearsDial(close: XCUIElement, dial: XCUIElement) {
        XCTAssertTrue(dial.exists)
        let closeFrame = close.frame
        let dialFrame = dial.frame
        let centerDistance = hypot(
            closeFrame.midX - dialFrame.midX,
            closeFrame.midY - dialFrame.midY
        )
        let dialRadius = min(dialFrame.width, dialFrame.height) / 2
        let closeHalfDiagonal = hypot(closeFrame.width, closeFrame.height) / 2
        XCTAssertGreaterThanOrEqual(centerDistance, dialRadius + closeHalfDiagonal)
    }

    private func waitForVisualSettle() {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.3))
    }

    private func currentDisplayedBPM() -> Int? {
        app.staticTexts.allElementsBoundByIndex
            .lazy
            .compactMap { Int($0.label) }
            .first { 90...210 ~= $0 }
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
        prepareApp(additionalArgument.map { [$0] } ?? [])
    }

    private func prepareApp(_ additionalArguments: [String]) {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-SAMADHI_FAST_MODE"]
        app.launchArguments.append(contentsOf: additionalArguments)
    }
}
