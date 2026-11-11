import XCTest

final class DictionaryScreenUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        app.buttons["Войти"].tap()
        app.buttons["Словарь"].tap()
        XCTAssertTrue(
            app.navigationBars["Словарь"].waitForExistence(timeout: 5),
            "Экран словаря не открылся"
        )
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testDictionarySearchFiltersAndRestoresWords() {
        let searchField = app.textFields["dictionary.searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3),
                      "Поле поиска не найдено")

        searchField.tap()
        searchField.typeText("Squ")

        let squish = app.staticTexts["Squish to condish"]
        XCTAssertTrue(squish.waitForExistence(timeout: 3),
                      "Отфильтрованное слово 'Squish to condish' не отображается при поиске 'Squ'")

        XCTAssertFalse(app.staticTexts["Афропик"].exists,
                       "Слово 'Афропик' не должно отображаться при поиске 'Squ'")
        XCTAssertFalse(app.staticTexts["Диффузор"].exists,
                       "Слово 'Диффузор' не должно отображаться при поиске 'Squ'")

        let clearButton = searchField.buttons["Clear text"]
        if clearButton.waitForExistence(timeout: 1) {
            clearButton.tap()
        } else {
            searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 3))
        }

        XCTAssertTrue(app.staticTexts["Афропик"].waitForExistence(timeout: 3),
                      "Список не восстановился после очистки поиска: 'Афропик' отсутствует")
        XCTAssertTrue(app.staticTexts["Диффузор"].exists,
                      "Список не восстановился после очистки поиска: 'Диффузор' отсутствует")
    }
    
    func testDictionarySearchShowsNoResultsForUnknownQuery() {
        let searchField = app.textFields["dictionary.searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3),
                      "Поле поиска не найдено")

        searchField.tap()
        searchField.typeText("zzz")

        let firstWord = app.staticTexts["Афропик"]
        let squish = app.staticTexts["Squish to condish"]

        let noResults = NSPredicate(format: "exists == false")
        expectation(for: noResults, evaluatedWith: firstWord)
        expectation(for: noResults, evaluatedWith: squish)
        waitForExpectations(timeout: 3)

        XCTAssertFalse(firstWord.exists,
                       "При поиске 'zzz' слово 'Афропик' не должно отображаться")
        XCTAssertFalse(squish.exists,
                       "При поиске 'zzz' слово 'Squish to condish' не должно отображаться")
    }
}
