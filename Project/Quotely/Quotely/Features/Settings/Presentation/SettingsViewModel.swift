//
//  SettingsViewModel.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import Foundation

@Observable
final class SettingsViewModel {
    private let repository = QuoteRepository.shared
    private let settings = SettingsStorage.shared

    var statistics = QuoteStatistics.empty

    func load() async {
        let quotes = (try? repository.readAll()) ?? []
        statistics = await QuoteStatistics.calculate(for: quotes)
    }

    func deleteAllQuotes() async {
        try? repository.deleteAll()
        settings.dailyQuoteID = nil
        settings.dailyQuoteDate = nil
        await load()
    }

    func resetSettings() {
        settings.reset()
    }
}
