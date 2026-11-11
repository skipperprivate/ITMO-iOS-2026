import Foundation

final class ToggleFavoriteUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(userId: UUID, productId: UUID) async throws {
        let isFavorite = try await repository.isFavorite(userId: userId, productId: productId)
        if isFavorite {
            try await repository.removeFromFavorites(userId: userId, productId: productId)
        } else {
            try await repository.addToFavorites(userId: userId, productId: productId)
        }
    }
}
