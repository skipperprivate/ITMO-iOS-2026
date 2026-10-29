import XCTest

@MainActor
final class NewsFeedE2ETests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLoadedArticleOpensFullText() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        // Сначала ждём завершения загрузки и обновления списка.
        guard waitFor(app.staticTexts["network-message"],
                      predicate: "exists == true AND label == %@",
                      value: "Загружено публикаций: 1.", app: app,
                      message: "Лента не завершила загрузку") else { return }

        let article = app.buttons["article-dummyjson:101"]
        guard waitFor(article, predicate: "exists == true AND hittable == true", app: app,
                      message: "Строка новости недоступна для нажатия") else { return }
        article.tap()

        // Проверяем содержимое экрана, а не представление NavigationBar в iOS.
        // Эти идентификаторы есть только на экране подробностей.
        let title = app.staticTexts["article-title"]
        let body = app.staticTexts["article-body"]
        guard waitFor(title, predicate: "exists == true", app: app,
                      message: "После нажатия не появился заголовок на экране новости") else { return }
        guard waitFor(body, predicate: "exists == true", app: app,
                      message: "На экране новости не появился полный текст") else { return }
        XCTAssertEqual(title.label, "Тестовая новость")
        XCTAssertEqual(body.label, "Полный текст тестовой новости.")
    }

    func testRetryLoadsFeedAfterNetworkFailure() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--fail-first-request"]
        app.launch()

        let retry = app.buttons["retry-loading"]
        guard waitFor(retry, predicate: "exists == true AND hittable == true", app: app,
                      message: "После ошибки не появилась доступная кнопка повтора") else { return }
        XCTAssertTrue(app.staticTexts["network-message"].label.contains("Не удалось загрузить ленту"))
        XCTAssertFalse(app.buttons["article-dummyjson:101"].exists)
        retry.tap()

        guard waitFor(app.staticTexts["network-message"],
                      predicate: "exists == true AND label == %@",
                      value: "Загружено публикаций: 1.", app: app,
                      message: "Повторная загрузка не завершилась успешно") else { return }
        guard waitFor(app.buttons["article-dummyjson:101"],
                      predicate: "exists == true AND hittable == true", app: app,
                      message: "После повторной загрузки новость не появилась") else { return }
        _ = waitFor(retry, predicate: "exists == false", app: app,
                    message: "После успешной загрузки осталась кнопка повтора")
    }

    // Ожидание конкретного состояния вместо sleep и повторных нажатий.
    // При тайм-ауте тест обязательно падает и сохраняет диагностику.
    @discardableResult
    private func waitFor(_ element: XCUIElement, predicate format: String,
                         value: String? = nil, app: XCUIApplication, message: String,
                         file: StaticString = #filePath, line: UInt = #line) -> Bool {
        let predicate = value.map { NSPredicate(format: format, $0) } ?? NSPredicate(format: format)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: 15)
        guard result == .completed else {
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = message
            screenshot.lifetime = .keepAlways
            add(screenshot)
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.name = "Иерархия интерфейса при ошибке"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
            XCTFail(message, file: file, line: line)
            return false
        }
        return true
    }
}
