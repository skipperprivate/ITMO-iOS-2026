import Foundation

final class MyMoviesModel:
    MyMoviesModelProtocol {

    private let repository:
        UserMovieRepositoryProtocol

    init(
        repository:
            UserMovieRepositoryProtocol
    ) {
        self.repository = repository
    }

    func getPersonalMovies() async
        -> [UserMovieData] {

        await repository.getPersonalMovies()
    }
}
