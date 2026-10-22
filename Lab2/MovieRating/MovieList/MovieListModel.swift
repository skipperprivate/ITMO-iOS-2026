import Foundation

final class MovieListModel:
    MovieListModelProtocol {

    private let settings:
        AppSettings

    private let userMovieRepository:
        UserMovieRepositoryProtocol

    private let movieService:
        MovieServiceProtocol

    private let imageLoader:
        ImageLoaderProtocol

    init(
        settings: AppSettings,
        userMovieRepository:
            UserMovieRepositoryProtocol,
        movieService:
            MovieServiceProtocol,
        imageLoader:
            ImageLoaderProtocol
    ) {
        self.settings = settings

        self.userMovieRepository =
            userMovieRepository

        self.movieService =
            movieService

        self.imageLoader =
            imageLoader
    }

    func getMovies() async throws
        -> [Movie] {

        var result =
            try await movieService
                .getMovies()

        if settings.hideWatched {
            let watchedIDs =
                userMovieRepository
                    .getWatchedMovieIDs()

            result = result.filter {
                !watchedIDs.contains(
                    $0.id
                )
            }
        }

        return result
    }

    func getPosterData(
        for movie: Movie
    ) async throws -> Data? {

        guard let posterURL =
                movie.posterURL
        else {
            return nil
        }

        return try await imageLoader
            .loadImageData(
                from: posterURL
            )
    }
}
