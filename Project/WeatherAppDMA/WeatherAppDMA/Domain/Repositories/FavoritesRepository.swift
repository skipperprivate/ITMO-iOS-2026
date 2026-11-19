import Foundation

protocol FavoritesRepository: Sendable {
    func fetchAll() async throws -> [FavoriteCity]
    func contains(cityName: String) async throws -> Bool
    func add(cityName: String, note: String?) async throws -> FavoriteCity
    func updateNote(id: UUID, note: String?) async throws
    func reorder(ids: [UUID]) async throws
    func delete(id: UUID) async throws
    func deleteAll() async throws
}
