import Foundation

protocol MovieDetailViewProtocol:
    AnyObject {

    func showMovie(
        _ movie: Movie
    )

    func showPoster(
        _ data: Data?
    )

    func showUserData(
        _ data: UserMovieData?
    )

    func showError(
        _ message: String
    )

    func showSavedMessage()
}

protocol MovieDetailPresenterProtocol:
    AnyObject {

    func viewDidLoad()

    func favoriteButtonTapped()

    func watchedChanged(
        _ isWatched: Bool
    )

    func savePersonalData(
        note: String,
        ratingText: String
    )
}

protocol MovieDetailModelProtocol:
    AnyObject {

    var movie: Movie { get }

    func getPosterData()
        async throws -> Data?

    func sendRating(
        _ rating: Double
    ) async throws

    func getUserData()
        -> UserMovieData?

    func toggleFavorite()

    func setWatched(
        _ isWatched: Bool
    )

    func savePersonalData(
        note: String,
        rating: Double?
    )
}
