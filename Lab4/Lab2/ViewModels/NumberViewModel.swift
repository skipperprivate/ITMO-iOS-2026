//
//  NumberViewModel.swift
//  Lab2
//
//  Created by n grebenkin on 24.09.2026.
//

import Observation

@Observable
class NumberViewModel {
    private let generator: NumberGeneratorService
    private let settings: SettingsStore
    private let history: HistoryRepository
    private(set) var number: Int?
    private(set) var range: ClosedRange<Int>

    init(generator: NumberGeneratorService, settings: SettingsStore, history: HistoryRepository) {
        self.generator = generator
        self.settings = settings
        self.history = history
        self.range = settings.range
    }

    var numberText: String { number.map(String.init) ?? "—" }
    var rangeText: String { "Диапазон: \(range.lowerBound)…\(range.upperBound)" }

    func reloadSettings() {
        range = settings.range
    }

    func generateNumber() {
        let value = generator.generate(in: range)
        number = value
        if settings.savesHistory {
            history.add(value)
        }
    }
}
