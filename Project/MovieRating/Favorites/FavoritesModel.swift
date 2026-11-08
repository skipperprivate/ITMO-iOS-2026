import Foundation

final class FavoritesModel:
    FavoritesModelProtocol {

    private let repository:
        UserMovieRepositoryProtocol

    init(
        repository:
            UserMovieRepositoryProtocol
    ) {
        self.repository = repository
    }

    func getFavorites() async
        -> [UserMovieData] {

        await repository.getFavorites()
    }
}
