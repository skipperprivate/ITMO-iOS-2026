//
//  SettingsViewModel.swift
//  Lab2
//
//  Created by n grebenkin on 01.10.2026.
//

import Observation

@Observable
class SettingsViewModel {
    private let settings: SettingsStore
    var minText = ""
    var maxText = ""
    var savesHistory = true

    init(settings: SettingsStore) {
        self.settings = settings
    }

    var isValid: Bool { parsedRange != nil }

    func save() {
        guard let range = parsedRange else { return }
        settings.range = range
        settings.savesHistory = savesHistory
    }

    func reset() {
        settings.reset()
        load()
    }

    func load() {
        minText = String(settings.range.lowerBound)
        maxText = String(settings.range.upperBound)
        savesHistory = settings.savesHistory
    }

    private var parsedRange: ClosedRange<Int>? {
        guard let lower = Int(minText), let upper = Int(maxText), lower <= upper else { return nil }
        return lower...upper
    }
}
