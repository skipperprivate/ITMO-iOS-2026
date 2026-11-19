import Foundation

protocol ReorderFavoritesUseCase: Sendable {
    func execute(ids: [UUID]) async throws
}

struct DefaultReorderFavoritesUseCase: ReorderFavoritesUseCase {
    let repository: FavoritesRepository

    func execute(ids: [UUID]) async throws {
        try await repository.reorder(ids: ids)
    }
}
