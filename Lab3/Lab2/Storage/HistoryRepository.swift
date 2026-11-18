//
//  HistoryRepository.swift
//  Lab2
//
//  Created by n grebenkin on 01.10.2026.
//

import Foundation
import SwiftData

protocol HistoryRepository {
    func add(_ value: Int)
    func fetchAll() -> [GeneratedNumber]
    func updateNote(_ item: GeneratedNumber, note: String)
    func delete(_ item: GeneratedNumber)
    func deleteAll()
}

final class SwiftDataHistoryRepository: HistoryRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func add(_ value: Int) {
        context.insert(GeneratedNumber(value: value))
        save()
    }

    func fetchAll() -> [GeneratedNumber] {
        let descriptor = FetchDescriptor<GeneratedNumber>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func updateNote(_ item: GeneratedNumber, note: String) {
        item.note = note
        save()
    }

    func delete(_ item: GeneratedNumber) {
        context.delete(item)
        save()
    }

    func deleteAll() {
        fetchAll().forEach(context.delete)
        save()
    }

    private func save() {
        do {
            try context.save()
        } catch {
            print("SwiftData save failed: \(error)")
        }
    }
}
