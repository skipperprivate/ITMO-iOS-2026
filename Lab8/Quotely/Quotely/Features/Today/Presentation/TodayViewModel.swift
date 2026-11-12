//
//  TodayViewModel.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import Foundation

@Observable
final class TodayViewModel {
    private let repository = QuoteRepository.shared
    private let settings = SettingsStorage.shared

    var quote: Quote?

    func load() {
        if let savedID = settings.dailyQuoteID,
           let savedDate = settings.dailyQuoteDate,
           Calendar.current.isDateInToday(savedDate),
           let saved = try? repository.read(id: savedID) {
            quote = saved
        } else {
            pickNew()
        }
    }

    func pickNew() {
        let all = (try? repository.readAll()) ?? []
        quote = all.randomElement()
        settings.dailyQuoteID = quote?.id
        settings.dailyQuoteDate = .now
    }

    func toggleFavorite() {
        guard var updated = quote else { return }
        updated.isFavorite.toggle()
        try? repository.update(updated)
        quote = updated
    }
}
