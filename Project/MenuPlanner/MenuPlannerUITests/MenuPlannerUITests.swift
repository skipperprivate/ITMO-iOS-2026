import XCTest

@MainActor
final class MenuPlannerUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launchEnvironment["MENU_PLANNER_TEST_ID"] = UUID().uuidString
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testOnboardingCompletesAndStaysCompletedAfterRelaunch() {
        app.launch()
        let start = app.buttons["onboarding.start"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        start.tap()
        XCTAssertTrue(app.buttons["tab.menu"].waitForExistence(timeout: 5))
        XCTAssertFalse(start.exists)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["tab.menu"].waitForExistence(timeout: 10))
        XCTAssertFalse(start.exists)
    }

    func testTabsShowEmptyStatesAndShoppingReturnsToMenu() {
        launchMainScreen()
        XCTAssertTrue(app.staticTexts["Моя неделя"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["weekPlan.collectShoppingList"].isEnabled)
        openRecipes()
        XCTAssertTrue(app.staticTexts["Пока нет рецептов"].waitForExistence(timeout: 5))
        app.buttons["tab.shopping"].tap()
        let openMenu = app.buttons["Открыть меню"]
        XCTAssertTrue(openMenu.waitForExistence(timeout: 5))
        openMenu.tap()
        XCTAssertTrue(app.staticTexts["Моя неделя"].waitForExistence(timeout: 5))
    }

    func testEmptyRecipeCannotBeSavedAndShowsInlineError() {
        launchMainScreen()
        openRecipes()
        openEditor()
        app.buttons["recipeEditor.save"].tap()
        XCTAssertTrue(app.staticTexts["Укажи название рецепта"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Новый рецепт"].exists)
        app.buttons["recipeEditor.cancel"].tap()
        XCTAssertTrue(app.staticTexts["Пока нет рецептов"].waitForExistence(timeout: 5))
    }

    func testCancellingRecipeDiscardsDraft() {
        launchMainScreen()
        openRecipes()
        openEditor()
        enter("Несохранённый рецепт", into: app.textFields["recipeEditor.name"])
        app.buttons["recipeEditor.cancel"].tap()
        XCTAssertTrue(app.staticTexts["Пока нет рецептов"].waitForExistence(timeout: 5))
        openEditor()
        XCTAssertEqual(app.textFields["recipeEditor.name"].value as? String, "Например, омлет с овощами")
    }

    func testCreatingRecipeAndSearchingByIngredient() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        let search = app.textFields["recipes.search"]
        enter("Рис", into: search)
        XCTAssertTrue(app.staticTexts["Тестовая каша"].waitForExistence(timeout: 5))
        search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 3) + "Несуществующий")
        XCTAssertTrue(app.staticTexts["Рецепты не найдены"].waitForExistence(timeout: 5))
        search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: "Несуществующий".count))
        search.typeText("\n")
        let recipe = app.staticTexts["Тестовая каша"]
        XCTAssertTrue(recipe.waitForExistence(timeout: 5))
        recipe.tap()
        XCTAssertTrue(app.staticTexts["Рис"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["100 г"].exists)
    }

    func testRecipeCanBePlannedAndConvertedToShoppingList() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        app.buttons["tab.menu"].tap()
        let lunch = app.buttons["weekPlan.meal.lunch"]
        XCTAssertTrue(lunch.waitForExistence(timeout: 5))
        lunch.tap()
        let add = app.buttons["Добавить в меню"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()
        XCTAssertTrue(app.staticTexts["Тестовая каша"].waitForExistence(timeout: 5))
        let collect = app.buttons["weekPlan.collectShoppingList"]
        // The action is below the meal slots on smaller displays.
        if !collect.isHittable { app.swipeUp() }
        XCTAssertTrue(collect.isEnabled)
        collect.tap()
        XCTAssertTrue(app.staticTexts["Список готов"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Куплено 0 из 1"].exists)
        let rice = app.buttons.containing(.staticText, identifier: "Рис").firstMatch
        XCTAssertTrue(rice.waitForExistence(timeout: 5))
        rice.tap()
        XCTAssertTrue(app.staticTexts["Куплено 1 из 1"].waitForExistence(timeout: 5))
    }

    func testEditingRecipeUpdatesCardAndCancellingDeletionKeepsRecipe() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        app.staticTexts["Тестовая каша"].tap()
        app.buttons["recipeDetail.actions"].tap()
        app.buttons["Редактировать"].tap()
        let name = app.textFields["recipeEditor.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        replaceText(in: name, old: "Тестовая каша", with: "Новая каша")
        app.buttons["recipeEditor.save"].tap()
        XCTAssertTrue(app.staticTexts["Новая каша"].waitForExistence(timeout: 5))
        app.buttons["recipeDetail.actions"].tap()
        app.buttons["Удалить рецепт"].tap()
        let cancel = app.buttons["Отмена"]
        XCTAssertTrue(app.buttons["Удалить рецепт"].waitForExistence(timeout: 5))
        if cancel.exists {
            cancel.tap()
        } else {
            // iOS 26 can present a popover without a cancel row; dismiss it outside.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.8)).tap()
        }
        XCTAssertTrue(app.staticTexts["Новая каша"].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Новая каша"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Тестовая каша"].exists)
    }

    func testDeletingRecipeConfirmsAndReturnsToEmptyCollection() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        app.staticTexts["Тестовая каша"].tap()
        app.buttons["recipeDetail.actions"].tap()
        app.buttons["Удалить рецепт"].tap()
        let confirm = app.buttons["Удалить рецепт"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()
        XCTAssertTrue(app.staticTexts["Пока нет рецептов"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Тестовая каша"].exists)
    }

    func testFavoriteToggleAndFavoritesFilter() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        app.staticTexts["Тестовая каша"].tap()
        let favorite = app.buttons["recipeDetail.favorite"]
        XCTAssertTrue(favorite.waitForExistence(timeout: 5))
        XCTAssertEqual(favorite.label, "Добавить в избранное")
        favorite.tap()
        XCTAssertEqual(favorite.label, "Убрать из избранного")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["recipes.sort"].tap()
        app.buttons["Только избранные"].tap()
        XCTAssertTrue(app.staticTexts["Тестовая каша"].waitForExistence(timeout: 5))
        app.staticTexts["Тестовая каша"].tap()
        app.buttons["recipeDetail.favorite"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Рецепты не найдены"].waitForExistence(timeout: 5))
    }

    func testServingsScaleIngredientsAndRespectLowerBound() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        app.staticTexts["Тестовая каша"].tap()
        let minus = app.buttons["recipeDetail.servings.minus"]
        let plus = app.buttons["recipeDetail.servings.plus"]
        XCTAssertTrue(minus.waitForExistence(timeout: 5))
        minus.tap()
        XCTAssertTrue(app.staticTexts["50 г"].waitForExistence(timeout: 5))
        XCTAssertFalse(minus.isEnabled)
        plus.tap()
        XCTAssertTrue(app.staticTexts["100 г"].waitForExistence(timeout: 5))
        plus.tap()
        XCTAssertTrue(app.staticTexts["150 г"].waitForExistence(timeout: 5))
    }

    func testRemovingLastIngredientShowsErrorAndCanBeCorrected() {
        launchMainScreen()
        openRecipes()
        openEditor()
        enter("Каша", into: app.textFields["recipeEditor.name"])
        app.textFields["recipeEditor.name"].typeText("\n")
        let remove = app.buttons["recipeEditor.deleteIngredient"].firstMatch
        XCTAssertTrue(remove.waitForExistence(timeout: 5))
        remove.tap()
        app.buttons["recipeEditor.save"].tap()
        XCTAssertTrue(app.staticTexts["Добавь хотя бы один ингредиент"].waitForExistence(timeout: 5))
        app.buttons["Добавить ингредиент"].tap()
        enter("Рис", into: app.textFields["recipeEditor.ingredientName"].firstMatch)
        app.textFields["recipeEditor.ingredientName"].firstMatch.typeText("\n")
        enter("0", into: app.textFields["recipeEditor.ingredientQuantity"].firstMatch)
        app.buttons["recipeEditor.save"].tap()
        XCTAssertTrue(app.staticTexts["Укажи количество больше нуля"].waitForExistence(timeout: 5))
        replaceText(in: app.textFields["recipeEditor.ingredientQuantity"].firstMatch, old: "0", with: "100")
        app.buttons["recipeEditor.save"].tap()
        XCTAssertTrue(app.staticTexts["Каша"].waitForExistence(timeout: 5))
    }

    func testPlanningDifferentWeeksAndRemovingMeal() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        planLunch()
        app.buttons["weekPlan.nextWeek"].tap()
        XCTAssertTrue(app.staticTexts["0 из 3 блюд"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["weekPlan.collectShoppingList"].isEnabled)
        app.buttons["weekPlan.previousWeek"].tap()
        XCTAssertTrue(app.staticTexts["Тестовая каша"].waitForExistence(timeout: 5))
        app.buttons["weekPlan.meal.lunch"].tap()
        let remove = app.buttons["Убрать из меню"]
        XCTAssertTrue(remove.waitForExistence(timeout: 5))
        remove.tap()
        XCTAssertTrue(app.staticTexts["0 из 3 блюд"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["weekPlan.collectShoppingList"].isEnabled)
    }

    func testMovingShoppingItemHomeAndBack() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        planLunch()
        collectShoppingList()
        let actions = app.buttons["shopping.itemActions.Рис"]
        XCTAssertTrue(actions.waitForExistence(timeout: 5))
        actions.tap()
        app.buttons["Есть дома"].tap()
        XCTAssertTrue(app.staticTexts["Всё необходимое есть дома"].waitForExistence(timeout: 5))
        app.buttons["Есть дома · 1"].tap()
        XCTAssertTrue(app.staticTexts["Рис"].waitForExistence(timeout: 5))
        app.buttons["shopping.itemActions.Рис"].tap()
        app.buttons["Вернуть в покупки"].tap()
        XCTAssertTrue(app.staticTexts["Пока ничего не отмечено"].waitForExistence(timeout: 5))
        app.buttons["Купить · 1"].tap()
        XCTAssertTrue(app.staticTexts["Рис"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Куплено 0 из 1"].exists)
    }

}

extension MenuPlannerUITests {
    func testOpeningEmptyInternetSearchAndClosingDoesNotCreateRecipe() {
        launchMainScreen()
        openRecipes()
        app.buttons["Найти в интернете"].tap()
        XCTAssertTrue(app.staticTexts["Введи название блюда"].waitForExistence(timeout: 5))
        app.buttons["Закрыть"].tap()
        XCTAssertTrue(app.staticTexts["Пока нет рецептов"].waitForExistence(timeout: 5))
    }

    func testInternetRecipePaginationAndImport() {
        launchMainScreen()
        openRecipes()
        app.buttons["Найти в интернете"].tap()
        enter("каша", into: app.textFields["Например, сырники"])
        XCTAssertTrue(app.staticTexts["Каша из каталога"].waitForExistence(timeout: 5))
        app.buttons["Показать ещё"].tap()
        XCTAssertTrue(app.staticTexts["Суп из каталога"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Показать ещё"].exists)
        app.staticTexts["Каша из каталога"].tap()
        let name = app.textFields["recipeEditor.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        XCTAssertEqual(name.value as? String, "Каша из каталога")
        app.buttons["recipeEditor.save"].tap()
        let close = app.buttons["Закрыть"]
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        close.tap()
        XCTAssertTrue(app.buttons["recipes.add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Каша из каталога"].exists)
        app.staticTexts["Каша из каталога"].tap()
        XCTAssertTrue(app.staticTexts["100 г"].waitForExistence(timeout: 5))
    }

    func testInternetRecipeFailureCanBeRetried() {
        app.launchEnvironment["MENU_PLANNER_NETWORK_SCENARIO"] = "retry"
        launchMainScreen()
        openRecipes()
        app.buttons["Найти в интернете"].tap()
        enter("каша", into: app.textFields["Например, сырники"])
        XCTAssertTrue(app.staticTexts["Не удалось загрузить рецепты"].waitForExistence(timeout: 5))
        app.buttons["Повторить"].tap()
        XCTAssertTrue(app.staticTexts["Каша из каталога"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Не удалось загрузить рецепты"].exists)
    }

    func testCartProductSearchAndLinkFailureCanBeRetriedAndQuantityValidated() {
        app.launchEnvironment["MENU_PLANNER_NETWORK_SCENARIO"] = "retry"
        launchMainScreen()
        openRecipes()
        createRecipe()
        planLunch()
        collectShoppingList()
        app.buttons["Собрать корзину во ВкусВилле"].tap()
        XCTAssertTrue(app.staticTexts["Не удалось загрузить товары"].waitForExistence(timeout: 5))
        app.buttons["Повторить"].tap()
        XCTAssertTrue(app.staticTexts["Рис тестовый 500 г"].waitForExistence(timeout: 5))
        app.staticTexts["Рис тестовый 500 г"].tap()
        XCTAssertTrue(app.staticTexts["Проверь количество"].waitForExistence(timeout: 5))
        let quantity = app.textFields["Количество"]
        XCTAssertEqual(quantity.value as? String, "1")
        replaceText(in: quantity, old: "1", with: "0")
        app.buttons["Получить ссылку на корзину"].tap()
        XCTAssertTrue(app.staticTexts["Укажи корректное количество для «Рис»."].waitForExistence(timeout: 5))
        replaceText(in: quantity, old: "0", with: "1")
        app.buttons["Получить ссылку на корзину"].tap()
        XCTAssertTrue(app.staticTexts["Не удалось получить ссылку на корзину. Попробуй ещё раз."].waitForExistence(timeout: 5))
        app.buttons["Получить ссылку на корзину"].tap()
        XCTAssertTrue(app.buttons["Открыть во ВкусВилле"].waitForExistence(timeout: 5))
        replaceText(in: quantity, old: "1", with: "2")
        XCTAssertTrue(app.buttons["Получить ссылку на корзину"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Открыть во ВкусВилле"].exists)
    }

    func testCartSkippedProductCanBeRevisitedAndAttached() {
        launchMainScreen()
        openRecipes()
        createRecipe()
        planLunch()
        collectShoppingList()
        app.buttons["Собрать корзину во ВкусВилле"].tap()
        let skip = app.buttons["Пропустить"]
        XCTAssertTrue(skip.waitForExistence(timeout: 5))
        skip.tap()
        XCTAssertTrue(app.staticTexts["Без товара: Рис"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Получить ссылку на корзину"].isEnabled)
        app.buttons["Подобрать пропущенные"].tap()
        XCTAssertTrue(app.staticTexts["Рис тестовый 500 г"].waitForExistence(timeout: 5))
        app.staticTexts["Рис тестовый 500 г"].tap()
        XCTAssertTrue(app.staticTexts["Проверь количество"].waitForExistence(timeout: 5))
        app.buttons["Заменить"].tap()
        XCTAssertTrue(app.buttons["Оставить текущий товар"].waitForExistence(timeout: 5))
        app.buttons["Оставить текущий товар"].tap()
        XCTAssertTrue(app.staticTexts["Проверь количество"].waitForExistence(timeout: 5))
        app.buttons["Закрыть"].tap()
        XCTAssertTrue(app.staticTexts["Рис тестовый 500 г"].waitForExistence(timeout: 5))
    }

    private func planLunch() {
        app.buttons["tab.menu"].tap()
        let lunch = app.buttons["weekPlan.meal.lunch"]
        XCTAssertTrue(lunch.waitForExistence(timeout: 5))
        lunch.tap()
        let add = app.buttons["Добавить в меню"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()
        XCTAssertTrue(app.staticTexts["Тестовая каша"].waitForExistence(timeout: 5))
    }

    private func collectShoppingList() {
        let collect = app.buttons["weekPlan.collectShoppingList"]
        if !collect.isHittable { app.swipeUp() }
        collect.tap()
        XCTAssertTrue(app.staticTexts["Список готов"].waitForExistence(timeout: 5))
    }

    private func replaceText(in field: XCUIElement, old: String, with text: String) {
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: old.count) + text)
    }

    private func launchMainScreen() {
        app.launchArguments.append("--skip-onboarding")
        app.launch()
        XCTAssertTrue(app.buttons["tab.menu"].waitForExistence(timeout: 10))
    }

    private func openRecipes() {
        app.buttons["tab.recipes"].tap()
        XCTAssertTrue(app.buttons["recipes.add"].waitForExistence(timeout: 5))
    }

    private func openEditor() {
        app.buttons["recipes.add"].tap()
        XCTAssertTrue(app.textFields["recipeEditor.name"].waitForExistence(timeout: 5))
    }

    private func createRecipe() {
        openEditor()
        enter("Тестовая каша", into: app.textFields["recipeEditor.name"])
        // Submit follows the editor's focus order and scrolls the ingredient into view.
        app.textFields["recipeEditor.name"].typeText("\n")
        let ingredient = app.textFields["recipeEditor.ingredientName"].firstMatch
        XCTAssertTrue(ingredient.waitForExistence(timeout: 5))
        enter("Рис", into: ingredient)
        ingredient.typeText("\n")
        enter("100", into: app.textFields["recipeEditor.ingredientQuantity"].firstMatch)
        app.buttons["recipeEditor.save"].tap()
        XCTAssertTrue(app.buttons["recipes.add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Тестовая каша"].waitForExistence(timeout: 5))
    }

    private func enter(_ text: String, into field: XCUIElement) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
    }
}
