import Foundation
@testable import MovieRating

// MARK: - HTTP Client Mock

final class StubHTTPClient: HTTPClientProtocol {

    struct Reply {
        let statusCode: Int
        let body: Data

        init(
            statusCode: Int,
            body: Data = Data()
        ) {
            self.statusCode = statusCode
            self.body = body
        }
    }

    enum StubError: Error {
        case noPreparedResponse
        case invalidURL
    }

    private var responses:
        [Result<Reply, URLError>]

    private(set) var requests:
        [URLRequest] = []

    init(
        responses: [Result<Reply, URLError>]
    ) {
        self.responses = responses
    }

    func data(
        for request: URLRequest
    ) async throws -> (
        Data,
        HTTPURLResponse
    ) {

        requests.append(request)

        guard !responses.isEmpty else {
            throw StubError.noPreparedResponse
        }

        let reply =
            try responses.removeFirst().get()

        guard
            let url = request.url,
            let response = HTTPURLResponse(
                url: url,
                statusCode: reply.statusCode,
                httpVersion: nil,
                headerFields: nil
            )
        else {
            throw StubError.invalidURL
        }

        return (reply.body, response)
    }
}

// MARK: - Movie Service Mock

final class StubMovieService:
    MovieServiceProtocol {

    var movies: [Movie]

    init(
        movies: [Movie] = []
    ) {
        self.movies = movies
    }

    func getMovies() async throws
        -> [Movie] {

        movies
    }
}

// MARK: - Image Loader Mock

final class StubImageLoader:
    ImageLoaderProtocol {

    var imageData = Data([1, 2, 3])

    private(set) var loadedURLs:
        [URL] = []

    func loadImageData(
        from url: URL
    ) async throws -> Data {

        loadedURLs.append(url)

        return imageData
    }
}

// MARK: - User Movie Repository Mock

final class StubUserMovieRepository:
    UserMovieRepositoryProtocol {

    var watchedIDs: Set<Int> = []

    func getData(
        for movieID: Int
    ) -> UserMovieData? {
        nil
    }

    func toggleFavorite(
        for movie: Movie
    ) {
    }

    func setWatched(
        _ isWatched: Bool,
        for movie: Movie
    ) {
    }

    func savePersonalData(
        note: String,
        rating: Double?,
        for movie: Movie
    ) {
    }

    func getFavorites() async
        -> [UserMovieData] {
        []
    }

    func getPersonalMovies() async
        -> [UserMovieData] {
        []
    }

    func getWatchedMovieIDs()
        -> Set<Int> {
        watchedIDs
    }
}

// MARK: - Movie Fixtures

enum MovieFixtures {

    static func makeMovie(
        id: Int = 1,
        posterURL: URL? = nil
    ) -> Movie {

        Movie(
            id: id,
            title: "Тестовый фильм \(id)",
            originalTitle: "Test Movie \(id)",
            year: 2024,
            genre: "Фантастика",
            rating: 8.5,
            overview: "Описание фильма",
            posterURL: posterURL
        )
    }
}
