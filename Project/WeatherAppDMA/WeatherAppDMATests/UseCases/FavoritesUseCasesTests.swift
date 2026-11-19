import Testing
import Foundation
@testable import WeatherAppDMA

struct FavoritesUseCasesTests {

    @Test
    func add_rejectsEmptyName() async {
        let repo = MockFavoritesRepository()
        let useCase = DefaultAddFavoriteUseCase(repository: repo)
        await #expect(throws: AppError.emptyQuery) {
            _ = try await useCase.execute(cityName: "   ", note: nil)
        }
    }

    @Test
    func add_rejectsDuplicates() async throws {
        let repo = MockFavoritesRepository()
        let useCase = DefaultAddFavoriteUseCase(repository: repo)
        _ = try await useCase.execute(cityName: "Москва", note: nil)
        await #expect(throws: AppError.favoriteAlreadyExists("Москва")) {
            _ = try await useCase.execute(cityName: "Москва", note: nil)
        }
    }

    @Test
    func add_trimsWhitespace() async throws {
        let repo = MockFavoritesRepository()
        let useCase = DefaultAddFavoriteUseCase(repository: repo)
        let fav = try await useCase.execute(cityName: "  Казань  ", note: nil)
        #expect(fav.cityName == "Казань")
    }

    @Test
    func updateNote_normalizesEmptyToNil() async throws {
        let repo = MockFavoritesRepository()
        let add = DefaultAddFavoriteUseCase(repository: repo)
        let update = DefaultUpdateFavoriteNoteUseCase(repository: repo)
        let fav = try await add.execute(cityName: "Москва", note: "note")
        try await update.execute(id: fav.id, note: "   ")
        let all = try await repo.fetchAll()
        #expect(all.first?.note == nil)
    }

    @Test
    func remove_deletesById() async throws {
        let repo = MockFavoritesRepository()
        let add = DefaultAddFavoriteUseCase(repository: repo)
        let remove = DefaultRemoveFavoriteUseCase(repository: repo)
        let fav = try await add.execute(cityName: "Москва", note: nil)
        try await remove.execute(id: fav.id)
        let all = try await repo.fetchAll()
        #expect(all.isEmpty)
    }

    @Test
    func removeAll_clearsRepository() async throws {
        let repo = MockFavoritesRepository()
        let add = DefaultAddFavoriteUseCase(repository: repo)
        let remove = DefaultRemoveFavoriteUseCase(repository: repo)
        _ = try await add.execute(cityName: "Москва", note: nil)
        _ = try await add.execute(cityName: "Казань", note: nil)
        try await remove.executeAll()
        let all = try await repo.fetchAll()
        #expect(all.isEmpty)
    }

    @Test
    func reorder_persistsNewOrder() async throws {
        let repo = MockFavoritesRepository()
        let add = DefaultAddFavoriteUseCase(repository: repo)
        let reorder = DefaultReorderFavoritesUseCase(repository: repo)
        let a = try await add.execute(cityName: "Москва", note: nil)
        let b = try await add.execute(cityName: "Казань", note: nil)
        try await reorder.execute(ids: [b.id, a.id])
        let names = try await repo.fetchAll().map(\.cityName)
        #expect(names == ["Казань", "Москва"])
    }
}
