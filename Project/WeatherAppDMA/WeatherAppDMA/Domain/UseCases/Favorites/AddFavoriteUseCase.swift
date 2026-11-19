import Foundation

protocol AddFavoriteUseCase: Sendable {
    func execute(cityName: String, note: String?) async throws -> FavoriteCity
}

struct DefaultAddFavoriteUseCase: AddFavoriteUseCase {
    let repository: FavoritesRepository

    func execute(cityName: String, note: String?) async throws -> FavoriteCity {
        let trimmed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.emptyQuery
        }
        if try await repository.contains(cityName: trimmed) {
            throw AppError.favoriteAlreadyExists(trimmed)
        }
        return try await repository.add(cityName: trimmed, note: note)
    }
}
