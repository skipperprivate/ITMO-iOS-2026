import Foundation

protocol UserMovieRepositoryProtocol {

    func getData(
        for movieID: Int
    ) -> UserMovieData?

    func toggleFavorite(
        for movie: Movie
    )

    func setWatched(
        _ isWatched: Bool,
        for movie: Movie
    )

    func savePersonalData(
        note: String,
        rating: Double?,
        for movie: Movie
    )

    func getFavorites() async -> [UserMovieData]

    func getPersonalMovies() async -> [UserMovieData]

    func getWatchedMovieIDs() -> Set<Int>
}
