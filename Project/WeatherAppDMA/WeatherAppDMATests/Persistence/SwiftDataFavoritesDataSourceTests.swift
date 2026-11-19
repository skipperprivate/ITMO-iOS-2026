import Testing
import Foundation
import SwiftData
@testable import WeatherAppDMA

@MainActor
struct SwiftDataFavoritesDataSourceTests {

    private func makeDataSource() throws -> SwiftDataFavoritesDataSource {
        let schema = Schema([FavoriteCityModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return SwiftDataFavoritesDataSource(context: ModelContext(container))
    }

    @Test
    func insert_appearsInFetchAll() throws {
        let ds = try makeDataSource()
        _ = try ds.insert(cityName: "Москва", note: nil)
        let all = try ds.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.cityName == "Москва")
    }

    @Test
    func contains_isCaseInsensitive() throws {
        let ds = try makeDataSource()
        _ = try ds.insert(cityName: "Казань", note: nil)
        #expect(try ds.contains(cityName: "казань"))
        #expect(try ds.contains(cityName: "КАЗАНЬ"))
        #expect(try !ds.contains(cityName: "Самара"))
    }

    @Test
    func updateNote_persistsNewValue() throws {
        let ds = try makeDataSource()
        let created = try ds.insert(cityName: "Санкт-Петербург", note: nil)
        try ds.updateNote(id: created.id, note: "любимое кафе под дождём")
        let all = try ds.fetchAll()
        #expect(all.first?.note == "любимое кафе под дождём")
    }

    @Test
    func delete_removesItem() throws {
        let ds = try makeDataSource()
        let created = try ds.insert(cityName: "Москва", note: nil)
        try ds.delete(id: created.id)
        #expect(try ds.fetchAll().isEmpty)
    }

    @Test
    func deleteAll_clearsStorage() throws {
        let ds = try makeDataSource()
        _ = try ds.insert(cityName: "Москва", note: nil)
        _ = try ds.insert(cityName: "Казань", note: nil)
        try ds.deleteAll()
        #expect(try ds.fetchAll().isEmpty)
    }

    @Test
    func reorder_changesPosition() throws {
        let ds = try makeDataSource()
        let a = try ds.insert(cityName: "Москва", note: nil)
        let b = try ds.insert(cityName: "Казань", note: nil)
        let c = try ds.insert(cityName: "Санкт-Петербург", note: nil)
        try ds.reorder(ids: [c.id, a.id, b.id])
        let names = try ds.fetchAll().map(\.cityName)
        #expect(names == ["Санкт-Петербург", "Москва", "Казань"])
    }

    @Test
    func delete_missingId_throws() throws {
        let ds = try makeDataSource()
        #expect(throws: AppError.self) {
            try ds.delete(id: UUID())
        }
    }
}
