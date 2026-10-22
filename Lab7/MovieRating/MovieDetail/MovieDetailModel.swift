import Foundation

final class MovieDetailModel:
    MovieDetailModelProtocol {

    let movie: Movie

    private let userMovieRepository:
        UserMovieRepositoryProtocol

    private let imageLoader:
        ImageLoaderProtocol

    private let ratingService:
        TMDBRatingServiceProtocol

    init(
        movie: Movie,
        userMovieRepository:
            UserMovieRepositoryProtocol,
        imageLoader:
            ImageLoaderProtocol,
        ratingService:
            TMDBRatingServiceProtocol
    ) {
        self.movie =
            movie

        self.userMovieRepository =
            userMovieRepository

        self.imageLoader =
            imageLoader

        self.ratingService =
            ratingService
    }

    func getPosterData()
        async throws -> Data? {

        guard
            let posterURL =
                movie.posterURL
        else {
            return nil
        }

        return try await imageLoader
            .loadImageData(
                from:
                    posterURL
            )
    }

    func sendRating(
        _ rating: Double
    ) async throws {

        try await ratingService
            .rateMovie(
                movieID:
                    movie.id,
                value:
                    rating
            )
    }

    func getUserData()
        -> UserMovieData? {

        userMovieRepository
            .getData(
                for:
                    movie.id
            )
    }

    func toggleFavorite() {

        userMovieRepository
            .toggleFavorite(
                for:
                    movie
            )
    }

    func setWatched(
        _ isWatched: Bool
    ) {

        userMovieRepository
            .setWatched(
                isWatched,
                for:
                    movie
            )
    }

    func savePersonalData(
        note: String,
        rating: Double?
    ) {

        userMovieRepository
            .savePersonalData(
                note:
                    note,
                rating:
                    rating,
                for:
                    movie
            )
    }
}
