//
//  QuoteRepository.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import Foundation
import SwiftData

final class QuoteRepository {
    static let shared = QuoteRepository()

    private let container: ModelContainer
    private let context: ModelContext

    private init() {
        do {
            container = try ModelContainer(for: QuoteEntity.self)
            context = container.mainContext
        } catch {
            fatalError("Не удалось открыть базу SwiftData: \(error)")
        }
    }

    func create(text: String, author: String, remoteID: Int? = nil) throws {
        let entity = QuoteEntity(text: text, author: author, remoteID: remoteID)
        context.insert(entity)
        try context.save()
    }

    func readAll() throws -> [Quote] {
        let descriptor = FetchDescriptor<QuoteEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map { $0.toQuote() }
    }

    func readFavorites() throws -> [Quote] {
        let descriptor = FetchDescriptor<QuoteEntity>(
            predicate: #Predicate<QuoteEntity> { $0.isFavorite },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map { $0.toQuote() }
    }

    func read(id: UUID) throws -> Quote? {
        try entity(id: id)?.toQuote()
    }

    func count() throws -> Int {
        try context.fetchCount(FetchDescriptor<QuoteEntity>())
    }

    func importedRemoteIDs() throws -> Set<Int> {
        let entities = try context.fetch(FetchDescriptor<QuoteEntity>())
        return Set(entities.compactMap { $0.remoteID })
    }

    func update(_ quote: Quote) throws {
        guard let entity = try entity(id: quote.id) else { return }
        entity.text = quote.text
        entity.author = quote.author
        entity.isFavorite = quote.isFavorite
        try context.save()
    }

    func delete(id: UUID) throws {
        guard let entity = try entity(id: id) else { return }
        context.delete(entity)
        try context.save()
    }

    func deleteAll() throws {
        try context.delete(model: QuoteEntity.self)
        try context.save()
    }

    private func entity(id: UUID) throws -> QuoteEntity? {
        var descriptor = FetchDescriptor<QuoteEntity>(
            predicate: #Predicate<QuoteEntity> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
