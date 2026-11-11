//
//  SettingsRepositoryImpl.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

@MainActor
public final class SettingsRepositoryImpl: SettingsRepository {
    private let preferences: UserPreferencesStoring

    public init(preferences: UserPreferencesStoring = UserPreferencesStore()) {
        self.preferences = preferences
    }

    public func LoadThemeID() -> String? {
        preferences.themeID
    }

    public func SetTheme(id: String) {
        preferences.themeID = id
    }
}
