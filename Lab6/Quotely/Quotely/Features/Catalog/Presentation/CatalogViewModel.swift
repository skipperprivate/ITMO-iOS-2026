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
    var errorMessage: String?

    func load() {
        quotes = (try? repository.readAll()) ?? []
    }

    func importFromAPI() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let skip = settings.importSkip

        async let firstPage = api.fetchPage(limit: pageLimit, skip: skip)
        async let secondPage = api.fetchPage(limit: pageLimit, skip: skip + pageLimit)

        do {
            let pages = try await [firstPage, secondPage]
            var imported = try repository.importedRemoteIDs()
            let remoteQuotes = pages.flatMap { $0.quotes }

            for remote in remoteQuotes {
                let text = remote.quote.trimmingCharacters(in: .whitespacesAndNewlines)
                let author = remote.author.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty, !author.isEmpty else { continue }
                guard !imported.contains(remote.id) else { continue }

                try repository.create(text: text, author: author, remoteID: remote.id)
                imported.insert(remote.id)
            }

            let next = skip + remoteQuotes.count
            settings.importSkip = next >= pages[0].total ? 0 : next
            quotes = try repository.readAll()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func update(_ quote: Quote, text: String, author: String) async throws {
        var updated = quote
        updated.text = text
        updated.author = author

        _ = try await api.publish(updated)

        try repository.update(updated)
        quotes = try repository.readAll()
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
