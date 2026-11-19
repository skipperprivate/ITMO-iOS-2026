import Foundation

protocol RemoveFavoriteUseCase: Sendable {
    func execute(id: UUID) async throws
    func executeAll() async throws
}

struct DefaultRemoveFavoriteUseCase: RemoveFavoriteUseCase {
    let repository: FavoritesRepository

    func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }

    func executeAll() async throws {
        try await repository.deleteAll()
    }
}
