import Foundation
@testable import WeatherAppDMA

actor MockFavoritesRepository: FavoritesRepository {
    private var storage: [FavoriteCity] = []
    private(set) var reorderedIds: [UUID] = []

    func fetchAll() async throws -> [FavoriteCity] {
        storage.sorted { $0.position < $1.position }
    }

    func contains(cityName: String) async throws -> Bool {
        storage.contains { $0.cityName.lowercased() == cityName.lowercased() }
    }

    func add(cityName: String, note: String?) async throws -> FavoriteCity {
        let next = (storage.map(\.position).max() ?? -1) + 1
        let favorite = FavoriteCity(cityName: cityName, note: note, position: next)
        storage.append(favorite)
        return favorite
    }

    func updateNote(id: UUID, note: String?) async throws {
        guard let idx = storage.firstIndex(where: { $0.id == id }) else {
            throw AppError.favoriteNotFound
        }
        storage[idx].note = note
    }

    func reorder(ids: [UUID]) async throws {
        reorderedIds = ids
        for (index, id) in ids.enumerated() {
            if let i = storage.firstIndex(where: { $0.id == id }) {
                storage[i].position = index
            }
        }
    }

    func delete(id: UUID) async throws {
        guard let idx = storage.firstIndex(where: { $0.id == id }) else {
            throw AppError.favoriteNotFound
        }
        storage.remove(at: idx)
    }

    func deleteAll() async throws {
        storage.removeAll()
    }
}
