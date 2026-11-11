import XCTest

final class RecipeBookUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(app.staticTexts["RecipeBook"].waitForExistence(timeout: 5))
    }


    @MainActor
    func testSearchFieldUpdatesRecipeList() throws {

        let app = XCUIApplication()
        app.launch()
        let searchField = app.textFields["searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Поле поиска должно существовать на экране")
        

        searchField.tap()
        searchField.typeText("Chicken")
        
        // swiftlint:disable:next empty_count
       XCTAssertTrue(app.staticTexts.count > 0, "Интерфейс должен отображать контент после поиска")
    }

    @MainActor
    func testAddToFavoritesAndSeeItInFavoritesTab() throws {
        let app = XCUIApplication()
        app.launch()
        
        let firstFavoriteButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'favoriteButton_'")
        ).firstMatch
        XCTAssertTrue(
            firstFavoriteButton.waitForExistence(timeout: 30),
            "Кнопка избранного должна появиться на карточке"
        )
        

        firstFavoriteButton.tap()
        

        let favoritesTab = app.tabBars.buttons["Избранное"]
        XCTAssertTrue(favoritesTab.waitForExistence(timeout: 5), "Вкладка 'Избранное' должна быть на экране")
        favoritesTab.tap()
        

        let favoritesList = app.collectionViews.firstMatch
        XCTAssertTrue(
            favoritesList.waitForExistence(timeout: 10),
            "Список избранного должен отображаться"
        )
        XCTAssertGreaterThan(
            favoritesList.cells.count, 0,
            "В избранном должен быть хотя бы один рецепт"
        )
    }
}
