import XCTest

final class PerfectStackUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeToGameplayToResultsReplayLoop() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["home.play"].waitForExistence(timeout: 3))
        app.buttons["home.play"].tap()

        XCTAssertTrue(app.buttons["game.tapSurface"].waitForExistence(timeout: 3))
        app.buttons["game.tapSurface"].tap()

        XCTAssertTrue(app.staticTexts["results.score"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["results.replay"].exists)
    }
}
