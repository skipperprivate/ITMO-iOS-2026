//
//  UserDefaultsAppStateRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation

nonisolated final class UserDefaultsAppStateRepository: AppStateRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let selectedCityKey = "com.weatherly.selectedCityID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSelectedCityID() -> City.ID? {
        defaults.string(forKey: selectedCityKey)
    }

    func saveSelectedCityID(_ id: City.ID?) {
        defaults.set(id, forKey: selectedCityKey)
    }
}
