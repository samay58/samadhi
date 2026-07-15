import XCTest

final class InStepUITests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["In Step"].waitForExistence(timeout: 5))
    }
}
