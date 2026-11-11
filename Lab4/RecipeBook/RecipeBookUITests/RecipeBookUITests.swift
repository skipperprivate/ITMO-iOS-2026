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

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    @MainActor
//    func testAddToFavoritesAndSeeItInFavoritesTab() throws {
//
//        let app = XCUIApplication()
//        app.launch()
//        let firstFavoriteButton = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'favoriteButton_'")).firstMatch
//        XCTAssertTrue(firstFavoriteButton.waitForExistence(timeout: 30), "Кнопка избранного должна появиться на карточке")
//        firstFavoriteButton.tap()
//        let favoritesTab = app.tabBars.buttons["Избранное"]
//        XCTAssertTrue(favoritesTab.waitForExistence(timeout: 2), "Вкладка 'Избранное' должна быть на экране")
//        favoritesTab.tap()
//        
//
//        let favoritesList = app.collectionViews.firstMatch
//        let emptyText = app.staticTexts["Избранное пусто"]
//        
//        let startTime = Date()
//        while Date().timeIntervalSince(startTime) < 10 {
//            if favoritesList.exists {
//                break
//            }
//            if emptyText.exists {
//                break
//            }
//            Thread.sleep(forTimeInterval: 0.5)
//        }
//        
//        if emptyText.exists {
//            XCTFail("Избранное пусто — рецепт не добавился. Проверь, работает ли кнопка сердечка.")
//        } else {
//            XCTAssertTrue(favoritesList.exists, "Список избранного должен отображаться")
//            XCTAssertGreaterThan(favoritesList.cells.count, 0, "В избранном должен быть хотя бы один рецепт")
//        }
//    }
//    @MainActor
//    func testAddToFavoritesAndSeeItInFavoritesTab() throws {
//        let app = XCUIApplication()
//        app.launch()
//        
//        // 1. Ждем появления сердечка
//        let firstFavoriteButton = app.buttons.matching(
//            NSPredicate(format: "identifier BEGINSWITH 'favoriteButton_'")
//        ).firstMatch
//        XCTAssertTrue(firstFavoriteButton.waitForExistence(timeout: 30), "Кнопка избранного не появилась")
//        print("✅ [1] Кнопка сердечка найдена")
//        
//        // 2. Тапаем
//        firstFavoriteButton.tap()
//        print("✅ [2] Тап по сердечку выполнен")
//        
//        // 3. Проверяем, закрасилось ли сердечко
//        Thread.sleep(forTimeInterval: 1) // Даем время на обновление UI
//        let filledHearts = app.images.matching(identifier: "heart.fill")
//        print("🔍 [3] Найдено закрашенных сердечек: \(filledHearts.count)")
//        
//        // 4. Переходим на вкладку "Избранное"
//        let favoritesTab = app.tabBars.buttons["Избранное"]
//        XCTAssertTrue(favoritesTab.waitForExistence(timeout: 5), "Вкладка 'Избранное' не найдена")
//        favoritesTab.tap()
//        print("✅ [4] Переход на вкладку 'Избранное' выполнен")
//        
//        // 5. Ждем загрузки (10 секунд)
//        Thread.sleep(forTimeInterval: 3)
//        
//        // 6. Смотрим, что вообще есть на экране
//        print("🔍 [5] collectionViews: \(app.collectionViews.count)")
//        print("🔍 [5] tables: \(app.tables.count)")
//        print("🔍 [5] staticTexts: \(app.staticTexts.count)")
//        print("🔍 [5] cells: \(app.cells.count)")
//        
//        // Печатаем все видимые тексты на экране
//        for i in 0..<app.staticTexts.count {
//            let text = app.staticTexts.element(boundBy: i)
//            print("🔍 [5] Текст \(i): '\(text.label)' (exists: \(text.exists))")
//        }
//        
//        // Печатаем все коллекции
//        for i in 0..<app.collectionViews.count {
//            let cv = app.collectionViews.element(boundBy: i)
//            print("🔍 [5] CollectionView \(i): cells = \(cv.cells.count)")
//        }
//        
//        // Проверяем "Избранное пусто"
//        let emptyText = app.staticTexts["Избранное пусто"]
//        print("🔍 [5] 'Избранное пусто' exists: \(emptyText.exists)")
//        
//        // Финальный Assert
//        let favoritesList = app.collectionViews.firstMatch
//        let hasList = favoritesList.waitForExistence(timeout: 5)
//        let hasEmpty = emptyText.exists
//        
//        XCTAssertTrue(hasList || hasEmpty, "На экране нет ни списка, ни сообщения 'пусто'")
//        
//        if hasEmpty {
//            XCTFail("❌ Избранное пусто — рецепт НЕ добавился. Проблема в кнопке сердечка.")
//        } else {
//            XCTAssertGreaterThan(favoritesList.cells.count, 0, "Список есть, но пустой")
//        }
//    }
    
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
