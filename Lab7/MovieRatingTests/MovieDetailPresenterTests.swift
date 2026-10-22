import Foundation
import XCTest
@testable import MovieRating

final class MovieDetailPresenterTests:
    XCTestCase {

    @MainActor
    func testInvalidRatingIsNotSaved() {

        let model = MovieDetailModelSpy()
        let view = MovieDetailViewSpy()

        let presenter =
            MovieDetailPresenter(model: model)

        presenter.view = view

        presenter.savePersonalData(
            note: "Тестовая заметка",
            ratingText: "11"
        )

        XCTAssertNil(model.savedData)

        XCTAssertNotNil(
            view.lastError
        )

        XCTAssertEqual(
            view.savedMessageCount,
            0
        )
    }

    @MainActor
    func testValidRatingWithCommaIsSent()
        async {

        let model = MovieDetailModelSpy()
        let view = MovieDetailViewSpy()

        let presenter =
            MovieDetailPresenter(model: model)

        presenter.view = view

        let expectation =
            expectation(
                description: "Рейтинг отправлен"
            )

        view.onSavedMessage = {
            expectation.fulfill()
        }

        presenter.savePersonalData(
            note: "Хороший фильм",
            ratingText: "8,5"
        )

        await fulfillment(
            of: [expectation],
            timeout: 2
        )

        XCTAssertEqual(
            model.savedData?.note,
            "Хороший фильм"
        )

        XCTAssertEqual(
            model.savedData?.rating,
            8.5
        )

        XCTAssertEqual(
            model.sentRatings,
            [8.5]
        )
    }

    @MainActor
    func testEmptyRatingIsSavedLocallyWithoutPOST() {

        let model = MovieDetailModelSpy()
        let view = MovieDetailViewSpy()

        let presenter =
            MovieDetailPresenter(model: model)

        presenter.view = view

        presenter.savePersonalData(
            note: "Только заметка",
            ratingText: ""
        )

        XCTAssertEqual(
            model.savedData?.note,
            "Только заметка"
        )

        XCTAssertNil(
            model.savedData?.rating
        )

        XCTAssertTrue(
            model.sentRatings.isEmpty
        )

        XCTAssertEqual(
            view.savedMessageCount,
            1
        )
    }

    @MainActor
    func testNetworkErrorDoesNotLoseLocalRating()
        async {

        let model = MovieDetailModelSpy()

        model.ratingError =
            URLError(
                .notConnectedToInternet
            )

        let view = MovieDetailViewSpy()

        let presenter =
            MovieDetailPresenter(model: model)

        presenter.view = view

        let expectation =
            expectation(
                description: "Ошибка отправки показана"
            )

        view.onError = {
            expectation.fulfill()
        }

        presenter.savePersonalData(
            note: "Моя оценка",
            ratingText: "7.5"
        )

        await fulfillment(
            of: [expectation],
            timeout: 2
        )

        XCTAssertEqual(
            model.savedData?.rating,
            7.5
        )

        XCTAssertEqual(
            model.sentRatings,
            [7.5]
        )

        XCTAssertTrue(
            view.lastError?.contains(
                "сохранены локально"
            ) == true
        )
    }
}

// MARK: - Model Spy

private final class MovieDetailModelSpy:
    MovieDetailModelProtocol {

    let movie =
        MovieFixtures.makeMovie()

    var savedData: (
        note: String,
        rating: Double?
    )?

    var sentRatings: [Double] = []

    var ratingError: Error?

    func getPosterData()
        async throws -> Data? {

        nil
    }

    func sendRating(
        _ rating: Double
    ) async throws {

        sentRatings.append(rating)

        if let ratingError {
            throw ratingError
        }
    }

    func getUserData()
        -> UserMovieData? {

        nil
    }

    func toggleFavorite() {
    }

    func setWatched(
        _ isWatched: Bool
    ) {
    }

    func savePersonalData(
        note: String,
        rating: Double?
    ) {
        savedData = (
            note: note,
            rating: rating
        )
    }
}

// MARK: - View Spy

private final class MovieDetailViewSpy:
    MovieDetailViewProtocol {

    private(set) var lastError:
        String?

    private(set) var savedMessageCount = 0

    var onSavedMessage: (() -> Void)?
    var onError: (() -> Void)?

    func showMovie(
        _ movie: Movie
    ) {
    }

    func showPoster(
        _ data: Data?
    ) {
    }

    func showUserData(
        _ data: UserMovieData?
    ) {
    }

    func showError(
        _ message: String
    ) {
        lastError = message
        onError?()
    }

    func showSavedMessage() {
        savedMessageCount += 1
        onSavedMessage?()
    }
}
