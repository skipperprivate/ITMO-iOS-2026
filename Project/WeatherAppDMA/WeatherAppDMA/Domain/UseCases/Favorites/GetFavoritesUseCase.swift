import Foundation

protocol GetFavoritesUseCase: Sendable {
    func execute() async throws -> [FavoriteCity]
}

struct DefaultGetFavoritesUseCase: GetFavoritesUseCase {
    let repository: FavoritesRepository

    func execute() async throws -> [FavoriteCity] {
        try await repository.fetchAll()
    }
}
