import Foundation

/// Контракт сценария получения фактов о фильме
protocol GetFilmFactsUseCase {
    func getFacts(filmId: Int) async throws -> [FunFactModel]
}

// UC - посредник между ViewModel и Repository
final class GetFilmFactsUseCaseImpl: GetFilmFactsUseCase {
    private let repository: FilmFactsRepository

    init(repository: FilmFactsRepository) {
        self.repository = repository
    }

    func getFacts(filmId: Int) async throws -> [FunFactModel] {
        try await repository.getFacts(filmId: filmId)
    }
}

