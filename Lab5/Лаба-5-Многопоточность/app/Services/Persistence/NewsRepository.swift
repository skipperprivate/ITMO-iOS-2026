import Foundation
import SwiftData

// CRUD. Контекст из SwiftData не выходит из MainActor
@MainActor
final class NewsRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func fetch() throws -> [Item] {
        try context.fetch(FetchDescriptor<Item>(sortBy: [SortDescriptor(\Item.timestamp, order: .reverse)]))
    }

    func save(item: Item?, title: String, text: String, source: String, category: String) throws {
        if let item {
            item.title = title
            item.text = text
            item.source = source
            item.category = category
        } else {
            context.insert(Item(title: title, text: text, source: source, category: category))
        }
        try commit()
    }

    func delete(_ items: [Item]) throws {
        for item in items { context.delete(item) }
        try commit()
    }

    private func commit() throws {
        do { try context.save() }
        catch {
            context.rollback()
            throw error
        }
    }
}
