import Foundation
import XCTest
@testable import MovieRating

final class MovieListPresenterTests:
    XCTestCase {

    @MainActor
    func testViewWillAppearShowsMovies()
        async {

        let movies = [
            MovieFixtures.makeMovie(id: 1),
            MovieFixtures.makeMovie(id: 2)
        ]

        let model =
            MovieListModelSpy(movies: movies)

        let view =
            MovieListViewSpy()

        let presenter =
            MovieListPresenter(model: model)

        presenter.view = view

        let expectation =
            expectation(
                description: "Фильмы показаны"
            )

        view.onShowMovies = {
            expectation.fulfill()
        }

        presenter.viewWillAppear()

        await fulfillment(
            of: [expectation],
            timeout: 2
        )

        XCTAssertEqual(
            view.displayedMovies,
            movies
        )
    }

    @MainActor
    func testSelectingMovieOpensDetail()
        async {

        let movies = [
            MovieFixtures.makeMovie(id: 1),
            MovieFixtures.makeMovie(id: 2)
        ]

        let model =
            MovieListModelSpy(movies: movies)

        let view =
            MovieListViewSpy()

        let presenter =
            MovieListPresenter(model: model)

        presenter.view = view

        let expectation =
            expectation(
                description: "Каталог загружен"
            )

        view.onShowMovies = {
            expectation.fulfill()
        }

        presenter.viewWillAppear()

        await fulfillment(
            of: [expectation],
            timeout: 2
        )

        presenter.didSelectMovie(at: 1)

        XCTAssertEqual(
            view.openedMovie?.id,
            2
        )
    }

    @MainActor
    func testInvalidIndexDoesNotOpenDetail() {

        let model = MovieListModelSpy()
        let view = MovieListViewSpy()

        let presenter =
            MovieListPresenter(model: model)

        presenter.view = view

        presenter.didSelectMovie(at: 99)

        XCTAssertNil(view.openedMovie)
    }

    @MainActor
    func testLoadingErrorIsShownToView()
        async {

        let model = MovieListModelSpy()
        model.error = URLError(
            .notConnectedToInternet
        )

        let view = MovieListViewSpy()

        let presenter =
            MovieListPresenter(model: model)

        presenter.view = view

        let expectation =
            expectation(
                description: "Ошибка показана"
            )

        view.onShowError = {
            expectation.fulfill()
        }

        presenter.viewWillAppear()

        await fulfillment(
            of: [expectation],
            timeout: 2
        )

        XCTAssertNotNil(
            view.displayedError
        )
    }
}

// MARK: - Model Spy

private final class MovieListModelSpy:
    MovieListModelProtocol {

    var movies: [Movie]
    var error: Error?

    init(
        movies: [Movie] = []
    ) {
        self.movies = movies
    }

    func getMovies() async throws
        -> [Movie] {

        if let error {
            throw error
        }

        return movies
    }

    func getPosterData(
        for movie: Movie
    ) async throws -> Data? {

        nil
    }
}

// MARK: - View Spy

private final class MovieListViewSpy:
    MovieListViewProtocol {

    private(set) var displayedMovies:
        [Movie] = []

    private(set) var openedMovie:
        Movie?

    private(set) var displayedError:
        String?

    var onShowMovies: (() -> Void)?
    var onShowError: (() -> Void)?

    func showMovies(
        _ movies: [Movie]
    ) {
        displayedMovies = movies
        onShowMovies?()
    }

    func showPoster(
        _ data: Data?,
        for movieID: Int
    ) {
    }

    func showError(
        _ message: String
    ) {
        displayedError = message
        onShowError?()
    }

    func openMovieDetail(
        _ movie: Movie
    ) {
        openedMovie = movie
    }
    
    @MainActor
    func testNegativeMovieIndexDoesNotOpenDetail() {

        let model =
            MovieListModelSpy(
                movies: [
                    MovieFixtures.makeMovie(id: 1)
                ]
            )

        let view =
            MovieListViewSpy()

        let presenter =
            MovieListPresenter(model: model)

        presenter.view = view

        presenter.didSelectMovie(at: -1)

        XCTAssertNil(view.openedMovie)
    }
}
