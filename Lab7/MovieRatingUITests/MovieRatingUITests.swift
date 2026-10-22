import XCTest

final class MovieRatingUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()

        app.launchArguments.append(
            "UITEST_MODE"
        )

        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Вкладки

    func testAllFourTabsExist() {

        let tabBar = app.tabBars.firstMatch

        XCTAssertTrue(tabBar.exists)

        XCTAssertTrue(
            tabBar.buttons["Фильмы"].exists
        )

        XCTAssertTrue(
            tabBar.buttons["Избранное"].exists
        )

        XCTAssertTrue(
            tabBar.buttons["Мои фильмы"].exists
        )

        XCTAssertTrue(
            tabBar.buttons["Настройки"].exists
        )
    }

    func testTabNavigation() {

        app.tabBars.buttons[
            "Избранное"
        ].tap()

        XCTAssertTrue(
            app.navigationBars[
                "Избранное"
            ].exists
        )

        app.tabBars.buttons[
            "Мои фильмы"
        ].tap()

        XCTAssertTrue(
            app.navigationBars[
                "Мои фильмы"
            ].exists
        )

        app.tabBars.buttons[
            "Настройки"
        ].tap()

        XCTAssertTrue(
            app.navigationBars[
                "Настройки"
            ].exists
        )
    }

    // MARK: - Каталог

    func testMovieListShowsMovies() {

        let interstellar = app.staticTexts[
            "Интерстеллар"
        ]

        let inception = app.staticTexts[
            "Начало"
        ]

        XCTAssertTrue(
            interstellar.waitForExistence(
                timeout: 10
            )
        )

        XCTAssertTrue(
            inception.exists
        )
    }

    func testMovieDetailOpens() {

        openInterstellar()

        XCTAssertTrue(
            app.navigationBars[
                "О фильме"
            ].exists
        )

        XCTAssertTrue(
            app.staticTexts[
                "Interstellar"
            ].exists
        )

        XCTAssertTrue(
            app.staticTexts[
                "Описание"
            ].exists
        )

        XCTAssertTrue(
            app.buttons[
                "Сохранить"
            ].exists
        )
    }

    func testBackNavigation() {

        openInterstellar()

        let backButton =
            app.navigationBars.buttons[
                "Фильмы"
            ]

        XCTAssertTrue(
            backButton.exists
        )

        backButton.tap()

        XCTAssertTrue(
            app.staticTexts[
                "Интерстеллар"
            ].exists
        )
    }

    // MARK: - Избранное

    func testAddMovieToFavorites() {

        openInterstellar()

        let favoriteButton = app.buttons[
            "Добавить в избранное"
        ]

        XCTAssertTrue(
            favoriteButton.exists
        )

        favoriteButton.tap()

        XCTAssertTrue(
            app.buttons[
                "♥ В избранном"
            ].exists
        )

        app.tabBars.buttons[
            "Избранное"
        ].tap()

        XCTAssertTrue(
            app.staticTexts[
                "Интерстеллар"
            ].waitForExistence(
                timeout: 5
            )
        )
    }

    func testInvalidRatingShowsError() {

        openInterstellar()

        let ratingField =
            app.textFields[
                "Моя оценка от 0 до 10"
            ]

        XCTAssertTrue(
            ratingField.exists
        )

        ratingField.tap()

        ratingField.typeText("11")

        app.swipeUp()

        app.buttons[
            "Сохранить"
        ].tap()

        XCTAssertTrue(
            app.alerts["Ошибка"]
                .waitForExistence(
                    timeout: 5
                )
        )
    }

    // MARK: - Настройки

    func testSettingsSwitchCanBeChanged() {

        app.tabBars.buttons[
            "Настройки"
        ].tap()

        XCTAssertTrue(
            app.staticTexts[
                "Скрывать просмотренные"
            ].exists
        )

        let hideWatchedSwitch =
            app.switches.firstMatch

        XCTAssertTrue(
            hideWatchedSwitch.exists
        )

        hideWatchedSwitch.tap()

        XCTAssertEqual(
            hideWatchedSwitch.value
                as? String,
            "1"
        )
    }

    // MARK: - Helpers

    private func openInterstellar(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        let movie = app.staticTexts[
            "Интерстеллар"
        ]

        XCTAssertTrue(
            movie.waitForExistence(
                timeout: 10
            ),
            "Фильм не появился в каталоге",
            file: file,
            line: line
        )

        movie.tap()

        XCTAssertTrue(
            app.navigationBars[
                "О фильме"
            ].waitForExistence(
                timeout: 5
            ),
            file: file,
            line: line
        )
    }
    
    func testRemoveMovieFromFavorites() {

        openInterstellar()

        let addButton =
            app.buttons["♡ Добавить в избранное"]

        XCTAssertTrue(addButton.exists)
        addButton.tap()

        let removeButton =
            app.buttons["♥ В избранном"]

        XCTAssertTrue(removeButton.exists)
        removeButton.tap()

        XCTAssertTrue(
            app.buttons[
                "♡ Добавить в избранное"
            ].exists
        )

        app.tabBars.buttons[
            "Избранное"
        ].tap()

        XCTAssertFalse(
            app.staticTexts[
                "Интерстеллар"
            ].exists
        )
    }
    
    func testMarkMovieAsWatched() {

        openInterstellar()

        let watchedSwitch =
            app.switches.firstMatch

        XCTAssertTrue(watchedSwitch.exists)

        let currentValue =
            watchedSwitch.value as? String

        if currentValue != "1" {
            watchedSwitch.tap()
        }

        XCTAssertEqual(
            watchedSwitch.value as? String,
            "1"
        )

        app.tabBars.buttons[
            "Мои фильмы"
        ].tap()

        let movie =
            app.staticTexts["Интерстеллар"]

        XCTAssertTrue(
            movie.waitForExistence(
                timeout: 5
            )
        )

        XCTAssertTrue(
            app.staticTexts[
                "✓ Просмотрено"
            ].exists
        )
    }

    
    private func tapSaveButton() {

        let saveButton = app.buttons["Сохранить"]
        let scrollView = app.scrollViews.firstMatch

        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 5)
        )

        XCTAssertTrue(
            scrollView.exists
        )

        // Убираем клавиатуру, если она открыта.
        if app.keyboards.firstMatch.exists {
            scrollView.swipeDown()
        }

        // Прокручиваем до кнопки.
        for _ in 0..<8 {
            if saveButton.isHittable {
                break
            }

            scrollView.swipeUp()
        }

        XCTAssertTrue(
            saveButton.isHittable,
            "Кнопка «Сохранить» недоступна для нажатия"
        )

        saveButton.tap()
    }
}
