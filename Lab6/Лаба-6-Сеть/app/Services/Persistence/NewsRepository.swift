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
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RepositoryError.emptyArticle
        }
        if let item {
            guard item.remoteID == nil else { throw RepositoryError.readOnlyArticle }

            item.serverPostID = nil // После локальной правки прежний ответ POST больше не подтверждает этот текст.
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

    // Одна транзакция на ответ. Повторная загрузка обновляет записи по ID API.
    // Локальные публикации без remoteID не затрагиваются.
    func merge(_ articles: [RemoteArticle]) throws {
        let existing = try fetch()
        var byID: [String: Item] = [:]
        for item in existing {
            if let id = item.remoteID { byID[id] = item }
        }
        for article in articles {
            let item: Item
            if let saved = byID[article.id] {
                item = saved
            } else {
                item = Item()
                item.remoteID = article.id
                context.insert(item)
                byID[article.id] = item
            }
            item.title = article.title
            item.text = article.body
            // API не отдаёт дату публикации. timestamp — дата первой загрузки.
            item.source = "DummyJSON · автор №\(article.authorID)"
            item.category = article.tags.first ?? "Общее"
            item.sourceURL = nil
        }
        try commit()
    }

    func saveSubmitted(_ post: CreatedPost, submissionID: UUID, source: String, category: String) throws {
        // Локальный UUID, а не ID учебного API: POST может повторять один server ID.
        if try fetch().contains(where: { $0.submissionID == submissionID }) { return }
        let item = Item(title: post.title, text: post.body, source: source, category: category)
        item.serverPostID = post.id
        item.submissionID = submissionID
        context.insert(item)
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

private enum RepositoryError: LocalizedError {
    case readOnlyArticle
    case emptyArticle
    var errorDescription: String? {
        switch self {
        case .readOnlyArticle: "Загруженная публикация доступна только для чтения."
        case .emptyArticle: "Заполните заголовок и текст публикации."
        }
    }
}
