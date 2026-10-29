//
//  FavoritesViewModel.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import Foundation

@Observable
final class FavoritesViewModel {
    private let repository = QuoteRepository.shared

    var quotes: [Quote] = []

    func load() {
        quotes = (try? repository.readFavorites()) ?? []
    }

    func removeFromFavorites(_ quote: Quote) {
        var updated = quote
        updated.isFavorite = false
        try? repository.update(updated)
        load()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            try? repository.delete(id: quotes[index].id)
        }
        load()
    }
}
