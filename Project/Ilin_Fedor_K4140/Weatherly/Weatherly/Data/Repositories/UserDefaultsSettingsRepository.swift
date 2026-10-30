//
//  UserDefaultsSettingsRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

nonisolated final class UserDefaultsSettingsRepository: SettingsRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key = "com.weatherly.appSettings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() -> AppSettings {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .default
        }
        return decoded
    }

    func save(_ settings: AppSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}
