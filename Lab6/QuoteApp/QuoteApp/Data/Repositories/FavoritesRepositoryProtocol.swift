//
//  FavoritesRepositoryProtocol.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation
import CoreData

protocol FavoritesRepositoryProtocol {
    func getAll() async throws -> [Quote]
    func add(_ quote: Quote) async throws
    func remove(_ quote: Quote) async throws
    func isFavorite(_ quote: Quote) async throws -> Bool
    func clear() async throws
}

final class CoreDataFavoritesRepository: FavoritesRepositoryProtocol {
    
    private let stack: CoreDataStackProtocol

    init(stack: CoreDataStackProtocol = CoreDataStack.shared) {
        self.stack = stack
    }

    func getAll() async throws -> [Quote] {
        let context = stack.viewContext
        let request = QuoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        return try await context.perform {
            try context.fetch(request).map { $0.toDomain() }
        }
    }

    func isFavorite(_ quote: Quote) async throws -> Bool {
        let context = stack.viewContext
        let id = Int64(quote.id)
        return try await context.perform {
            let request = QuoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d AND isFavorite == YES", id)
            request.fetchLimit = 1
            return try context.count(for: request) > 0
        }
    }

    func add(_ quote: Quote) async throws {
        let id = Int64(quote.id)
        try await stack.performBackgroundTask { context in
            let request = QuoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                existing.isFavorite = true
                existing.createdAt = Date()
            } else {
                QuoteEntity.from(domain: quote, context: context, isFavorite: true)
            }
        }
    }

    func remove(_ quote: Quote) async throws {
        let id = Int64(quote.id)
        try await stack.performBackgroundTask { context in
            let request = QuoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            request.fetchLimit = 1
            if let existing = try context.fetch(request).first {
                existing.isFavorite = false
            }
        }
    }

    func clear() async throws {
        try await stack.performBackgroundTask { context in
            let request = QuoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isFavorite == YES")
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
        }
    }
}
