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

    var quotesCount = 0

    func load() {
        quotesCount = (try? repository.count()) ?? 0
    }

    func deleteAllQuotes() {
        try? repository.deleteAll()
        settings.dailyQuoteID = nil
        settings.dailyQuoteDate = nil
        load()
    }

    func resetSettings() {
        settings.reset()
    }
}
