//
//  CatalogViewModel.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import Foundation

@Observable
final class CatalogViewModel {
    private let pageLimit = 20

    private let repository = QuoteRepository.shared
    private let settings = SettingsStorage.shared
    private let api = QuotesAPI()

    var quotes: [Quote] = []
    var isLoading = false

    func load() {
        quotes = (try? repository.readAll()) ?? []
    }

    func importFromAPI() async {
        isLoading = true
        defer { isLoading = false }

        let skip = settings.importSkip

        async let firstPage = api.fetchPage(limit: pageLimit, skip: skip)
        async let secondPage = api.fetchPage(limit: pageLimit, skip: skip + pageLimit)

        guard let pages = try? await [firstPage, secondPage],
              let imported = try? repository.importedRemoteIDs() else { return }

        let remoteQuotes = pages.flatMap { $0.quotes }
        for remote in remoteQuotes where !imported.contains(remote.id) {
            try? repository.create(text: remote.quote, author: remote.author, remoteID: remote.id)
        }

        let next = skip + remoteQuotes.count
        settings.importSkip = next >= pages[0].total ? 0 : next
        load()
    }

    func update(_ quote: Quote, text: String, author: String) {
        var updated = quote
        updated.text = text
        updated.author = author
        try? repository.update(updated)
        load()
    }

    func toggleFavorite(_ quote: Quote) {
        var updated = quote
        updated.isFavorite.toggle()
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
