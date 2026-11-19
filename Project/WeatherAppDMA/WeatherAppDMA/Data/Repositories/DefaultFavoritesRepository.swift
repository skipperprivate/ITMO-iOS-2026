import Foundation

@MainActor
final class DefaultFavoritesRepository: FavoritesRepository {
    private let dataSource: SwiftDataFavoritesDataSource

    init(dataSource: SwiftDataFavoritesDataSource) {
        self.dataSource = dataSource
    }

    nonisolated func fetchAll() async throws -> [FavoriteCity] {
        try await MainActor.run {
            try self.dataSource.fetchAll().map { $0.toDomain() }
        }
    }

    nonisolated func contains(cityName: String) async throws -> Bool {
        try await MainActor.run {
            try self.dataSource.contains(cityName: cityName)
        }
    }

    nonisolated func add(cityName: String, note: String?) async throws -> FavoriteCity {
        try await MainActor.run {
            try self.dataSource.insert(cityName: cityName, note: note).toDomain()
        }
    }

    nonisolated func updateNote(id: UUID, note: String?) async throws {
        try await MainActor.run {
            try self.dataSource.updateNote(id: id, note: note)
        }
    }

    nonisolated func reorder(ids: [UUID]) async throws {
        try await MainActor.run {
            try self.dataSource.reorder(ids: ids)
        }
    }

    nonisolated func delete(id: UUID) async throws {
        try await MainActor.run {
            try self.dataSource.delete(id: id)
        }
    }

    nonisolated func deleteAll() async throws {
        try await MainActor.run {
            try self.dataSource.deleteAll()
        }
    }
}
