//
//  HistoryViewModel.swift
//  Lab2
//
//  Created by n grebenkin on 01.10.2026.
//

import Foundation
import Observation

@Observable
class HistoryViewModel {
    private let repository: HistoryRepository
    private(set) var items: [GeneratedNumber] = []

    init(repository: HistoryRepository) {
        self.repository = repository
    }

    func load() {
        items = repository.fetchAll()
    }

    func updateNote(_ item: GeneratedNumber, note: String) {
        repository.updateNote(item, note: note.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func delete(at offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(repository.delete)
        load()
    }

    func deleteAll() {
        repository.deleteAll()
        load()
    }
}
