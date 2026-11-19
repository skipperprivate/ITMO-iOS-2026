//
//  SettingsStore.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

@Observable
@MainActor
final class SettingsStore {
    private let repository: SettingsRepositoryProtocol

    var settings: AppSettings {
        didSet { repository.save(settings) }
    }

    init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
        self.settings = repository.loadSettings()
    }

    func colorScheme(isDaytime: Bool) -> ColorScheme {
        switch settings.theme {
        case .auto: isDaytime ? .light : .dark
        case .light: .light
        case .dark: .dark
        }
    }
}
