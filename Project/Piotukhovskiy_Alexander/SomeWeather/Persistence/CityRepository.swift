import Foundation
import SwiftData

@MainActor
protocol CityRepositoryProtocol {
    func history() throws -> [CityHistoryEntry]
    func find(id: Int) throws -> City?
    func saveSelection(_ city: City, at date: Date) throws
    func delete(id: Int) throws
}

@MainActor
final class CityRepository: CityRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        context.autosaveEnabled = false
    }

    func history() throws -> [CityHistoryEntry] {
        let descriptor = FetchDescriptor<SavedCity>(sortBy: [
            SortDescriptor(\SavedCity.lastSelectedAt, order: .reverse),
            SortDescriptor(\SavedCity.cityID)
        ])
        return try context.fetch(descriptor).map {
            CityHistoryEntry(city: $0.city, lastSelectedAt: $0.lastSelectedAt)
        }
    }

    func find(id: Int) throws -> City? {
        try record(id: id)?.city
    }

    func saveSelection(_ city: City, at date: Date) throws {
        do {
            if let saved = try record(id: city.id) {
                saved.update(from: city, selectedAt: date)
            } else {
                context.insert(SavedCity(city: city, selectedAt: date))
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func delete(id: Int) throws {
        do {
            if let saved = try record(id: id) {
                context.delete(saved)
                try context.save()
            }
        } catch {
            context.rollback()
            throw error
        }
    }

    private func record(id: Int) throws -> SavedCity? {
        let cityID = id
        var descriptor = FetchDescriptor<SavedCity>(
            predicate: #Predicate { $0.cityID == cityID }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
