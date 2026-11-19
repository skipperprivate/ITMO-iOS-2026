import Foundation
import OSLog
import SwiftData


@MainActor
final class CachedEventRepository: EventRepository {

    private let locationStore: LocationStore
    private let remote: EventRepository
    private let context: ModelContext
    private let logger = Logger(subsystem: "com.rekill04.Evently", category: "EventCache")
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        remote: EventRepository,
        context: ModelContext,
        locationStore: LocationStore
    ) {
        self.remote = remote
        self.context = context
        self.locationStore = locationStore
    }

    func fetchEvents() async throws -> [Event] {
        try await fetchEvents(category: .all, page: 0, size: EventCatalogConfiguration.pageSize).events
    }

    func fetchEvents(category: EventCategoryRu) async throws -> [Event] {
        try await fetchEvents(category: category, page: 0, size: EventCatalogConfiguration.pageSize).events
    }

    func fetchEvents(
        category: EventCategoryRu,
        page: Int,
        size: Int
    ) async throws -> EventPage {
        let key = "catalog|\(locationStore.selectionKey)|\(category.rawValue)|\(page)|\(size)"

        return try await cachedPage(for: key) {
            try await self.remote.fetchEvents(category: category, page: page, size: size)
        }
    }

    func searchEvents(
        keyword: String,
        page: Int,
        size: Int
    ) async throws -> EventPage {
        let normalizedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let key = "search|\(locationStore.selectionKey)|\(normalizedKeyword)|\(page)|\(size)"

        return try await cachedPage(for: key) {
            try await self.remote.searchEvents(keyword: keyword, page: page, size: size)
        }
    }

    func fetchEventDetails(id: String) async throws -> Event? {
        let key = "details|\(id)"

        do {
            let result = try await remote.fetchEventDetails(id: id)
            try Task.checkCancellation()

            if let result {
                save(CachedEventSnapshot(result), for: key)
            }

            return result
        } catch {
            try Task.checkCancellation()

            if let saved: CachedEventSnapshot = read(for: key) {
                return saved.event
            }

            throw error
        }
    }

    private func cachedPage(
        for key: String,
        fetch: () async throws -> EventPage
    ) async throws -> EventPage {
        do {
            let page = try await fetch()
            try Task.checkCancellation()
            save(CachedPageSnapshot(page), for: key)
            return page
        } catch {
            try Task.checkCancellation()

            if let saved: CachedPageSnapshot = read(for: key) {
                return saved.eventPage
            }

            throw error
        }
    }

    private func read<Value: Decodable>(for key: String) -> Value? {
        do {
            let descriptor = FetchDescriptor<CachedEventResponse>(
                predicate: #Predicate { $0.key == key }
            )
            guard let record = try context.fetch(descriptor).first else {
                return nil
            }
            return try decoder.decode(Value.self, from: record.payload)
        } catch {
            logger.warning("Cached response could not be loaded: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func save<Value: Encodable>(_ value: Value, for key: String) {
        do {
            let data = try encoder.encode(value)
            let descriptor = FetchDescriptor<CachedEventResponse>(
                predicate: #Predicate { $0.key == key }
            )

            if let record = try context.fetch(descriptor).first {
                record.payload = data
                record.updatedAt = .now
            } else {
                context.insert(CachedEventResponse(key: key, payload: data))
            }

            try context.save()
        } catch {
            logger.warning("Cached response could not be saved: \(error.localizedDescription, privacy: .public)")
        }
    }
}
