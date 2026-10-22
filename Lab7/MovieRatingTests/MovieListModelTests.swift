import XCTest
@testable import MovieRating

@MainActor
final class MovieListModelTests:
    XCTestCase {

    func testGetMoviesReturnsAllWhenFilterDisabled()
        async throws {

        let movies = [
            MovieFixtures.makeMovie(id: 1),
            MovieFixtures.makeMovie(id: 2),
            MovieFixtures.makeMovie(id: 3)
        ]

        let movieService =
            StubMovieService(movies: movies)

        let repository =
            StubUserMovieRepository()

        repository.watchedIDs = [2]

        let settings = makeSettings()
        settings.hideWatched = false

        let model = MovieListModel(
            settings: settings,
            userMovieRepository: repository,
            movieService: movieService,
            imageLoader: StubImageLoader()
        )

        let result =
            try await model.getMovies()

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(
            result.map(\.id),
            [1, 2, 3]
        )
    }

    func testGetMoviesHidesWatchedMovies()
        async throws {

        let movies = [
            MovieFixtures.makeMovie(id: 1),
            MovieFixtures.makeMovie(id: 2),
            MovieFixtures.makeMovie(id: 3)
        ]

        let movieService =
            StubMovieService(movies: movies)

        let repository =
            StubUserMovieRepository()

        repository.watchedIDs = [2]

        let settings = makeSettings()
        settings.hideWatched = true

        let model = MovieListModel(
            settings: settings,
            userMovieRepository: repository,
            movieService: movieService,
            imageLoader: StubImageLoader()
        )

        let result =
            try await model.getMovies()

        XCTAssertEqual(result.count, 2)

        XCTAssertEqual(
            result.map(\.id),
            [1, 3]
        )

        XCTAssertFalse(
            result.contains { $0.id == 2 }
        )
    }

    func testGetPosterDataLoadsImage()
        async throws {

        let url = try XCTUnwrap(
            URL(
                string: "https://example.com/poster.jpg"
            )
        )

        let movie = MovieFixtures.makeMovie(
            posterURL: url
        )

        let imageLoader = StubImageLoader()

        let model = MovieListModel(
            settings: makeSettings(),
            userMovieRepository:
                StubUserMovieRepository(),
            movieService: StubMovieService(),
            imageLoader: imageLoader
        )

        let data =
            try await model.getPosterData(
                for: movie
            )

        XCTAssertEqual(
            data,
            Data([1, 2, 3])
        )

        XCTAssertEqual(
            imageLoader.loadedURLs,
            [url]
        )
    }

    func testGetPosterDataWithoutURLReturnsNil()
        async throws {

        let movie =
            MovieFixtures.makeMovie(
                posterURL: nil
            )

        let imageLoader = StubImageLoader()

        let model = MovieListModel(
            settings: makeSettings(),
            userMovieRepository:
                StubUserMovieRepository(),
            movieService: StubMovieService(),
            imageLoader: imageLoader
        )

        let result =
            try await model.getPosterData(
                for: movie
            )

        XCTAssertNil(result)
        XCTAssertTrue(
            imageLoader.loadedURLs.isEmpty
        )
    }

    private func makeSettings() -> AppSettings {

        let defaults = UserDefaults(
            suiteName:
                "MovieRatingTests.\(UUID().uuidString)"
        )!

        return AppSettings(
            defaults: defaults
        )
    }
    
    @MainActor
    func testGetMoviesReturnsEmptyArray()
        async throws {

        let movieService =
            StubMovieService(movies: [])

        let model = MovieListModel(
            settings: makeSettings(),
            userMovieRepository:
                StubUserMovieRepository(),
            movieService: movieService,
            imageLoader: StubImageLoader()
        )

        let movies =
            try await model.getMovies()

        XCTAssertTrue(movies.isEmpty)
        XCTAssertEqual(movies.count, 0)
    }
    
    @MainActor
    func testUnknownWatchedIDDoesNotRemoveMovies()
        async throws {

        let movies = [
            MovieFixtures.makeMovie(id: 1),
            MovieFixtures.makeMovie(id: 2)
        ]

        let repository =
            StubUserMovieRepository()

        repository.watchedIDs = [999]

        let settings = makeSettings()
        settings.hideWatched = true

        let model = MovieListModel(
            settings: settings,
            userMovieRepository: repository,
            movieService:
                StubMovieService(movies: movies),
            imageLoader: StubImageLoader()
        )

        let result =
            try await model.getMovies()

        let ids = result.map { $0.id }

        XCTAssertEqual(ids, [1, 2])
    }
}
