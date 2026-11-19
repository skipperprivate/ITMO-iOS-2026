import Foundation
import SwiftData

@MainActor
final class SwiftDataFavoritesDataSource {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [FavoriteCityModel] {
        let descriptor = FetchDescriptor<FavoriteCityModel>(
            sortBy: [
                SortDescriptor(\.position, order: .forward),
                SortDescriptor(\.addedAt, order: .reverse)
            ]
        )
        return try context.fetch(descriptor)
    }

    func contains(cityName: String) throws -> Bool {
        let needle = cityName.lowercased()
        let descriptor = FetchDescriptor<FavoriteCityModel>()
        let all = try context.fetch(descriptor)
        return all.contains { $0.cityName.lowercased() == needle }
    }

    @discardableResult
    func insert(cityName: String, note: String?) throws -> FavoriteCityModel {
        let maxPosition = try fetchAll().map(\.position).max() ?? -1
        let model = FavoriteCityModel(
            cityName: cityName,
            addedAt: Date(),
            note: note,
            position: maxPosition + 1
        )
        context.insert(model)
        try context.save()
        return model
    }

    func updateNote(id: UUID, note: String?) throws {
        guard let model = try fetch(id: id) else {
            throw AppError.favoriteNotFound
        }
        model.note = note
        try context.save()
    }

    func reorder(ids: [UUID]) throws {
        let all = try fetchAll()
        var byId = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
        for (index, id) in ids.enumerated() {
            byId[id]?.position = index
        }
        try context.save()
    }

    func delete(id: UUID) throws {
        guard let model = try fetch(id: id) else {
            throw AppError.favoriteNotFound
        }
        context.delete(model)
        try context.save()
    }

    func deleteAll() throws {
        for model in try fetchAll() {
            context.delete(model)
        }
        try context.save()
    }

    private func fetch(id: UUID) throws -> FavoriteCityModel? {
        let descriptor = FetchDescriptor<FavoriteCityModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }
}
