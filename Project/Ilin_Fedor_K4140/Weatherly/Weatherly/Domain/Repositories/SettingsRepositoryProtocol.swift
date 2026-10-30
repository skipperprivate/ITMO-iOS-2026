//
//  SettingsRepositoryProtocol.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

nonisolated protocol SettingsRepositoryProtocol: Sendable {
    func loadSettings() -> AppSettings
    func save(_ settings: AppSettings)
}
