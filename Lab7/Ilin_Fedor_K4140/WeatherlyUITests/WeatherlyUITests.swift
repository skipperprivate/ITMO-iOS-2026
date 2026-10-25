import XCTest

@MainActor
final class WeatherlyUITests: XCTestCase {
    private var app: XCUIApplication!
    private var session: UUID!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        session = UUID()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        session = nil
    }

    func testAddedCitySurvivesAppRelaunch() {
        launch(reset: true)
        addMoscow()

        app.terminate()
        launch(reset: false)
        openPlaces()

        XCTAssertTrue(element("places.favorite.moscow").waitForExistence(timeout: 5))
    }

    func testRemovedCityStaysRemovedAfterAppRelaunch() {
        launch(reset: true)
        addMoscow()
        app.buttons["city.favorite"].tap()
        XCTAssertTrue(app.buttons["Добавить в избранное"].waitForExistence(timeout: 5))

        app.terminate()
        launch(reset: false)

        XCTAssertTrue(app.staticTexts["Пока нет городов"].waitForExistence(timeout: 5))
        openPlaces()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Здесь пока пусто")).firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(element("places.favorite.moscow").exists)
    }

    func testFailedSearchCanBeRetriedAndOpensForecast() {
        launch(reset: true, failSearch: true)
        openPlaces()
        searchMoscow()

        XCTAssertTrue(app.staticTexts["Нет подключения к интернету"].waitForExistence(timeout: 5))
        let retry = app.buttons["Повторить"]
        XCTAssertTrue(retry.waitForExistence(timeout: 5))
        retry.tap()
        openMoscowResult()
    }

    private func launch(reset: Bool, failSearch: Bool = false) {
        app.launchArguments = ["--uitesting", "--uitesting-session", session.uuidString]
        if reset { app.launchArguments.append("--uitesting-reset") }
        if failSearch { app.launchArguments.append("--uitesting-fail-search") }
        app.launch()
    }

    private func openPlaces() {
        let places = app.buttons["home.places"]
        XCTAssertTrue(places.waitForExistence(timeout: 5))
        places.tap()
        XCTAssertTrue(app.textFields["places.search"].waitForExistence(timeout: 5))
    }

    private func searchMoscow() {
        let search = app.textFields["places.search"]
        search.tap()
        search.typeText("Москва")
    }

    private func openMoscowResult() {
        let result = app.buttons["places.result.moscow"]
        XCTAssertTrue(result.waitForExistence(timeout: 5))
        result.tap()
        XCTAssertTrue(element("city.weather.moscow").waitForExistence(timeout: 5))
    }

    private func addMoscow() {
        openPlaces()
        searchMoscow()
        openMoscowResult()
        let favorite = app.buttons["city.favorite"]
        XCTAssertEqual(favorite.label, "Добавить в избранное")
        favorite.tap()
        XCTAssertTrue(app.buttons["Убрать из избранного"].waitForExistence(timeout: 5))
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
