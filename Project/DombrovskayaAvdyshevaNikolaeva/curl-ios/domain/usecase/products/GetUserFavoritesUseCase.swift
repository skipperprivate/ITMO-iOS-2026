import Foundation

final class GetUserFavoritesUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(userId: UUID) async throws -> [Favorite] {
        try await repository.getUserFavorites(userId: userId) ?? []
    }
}
