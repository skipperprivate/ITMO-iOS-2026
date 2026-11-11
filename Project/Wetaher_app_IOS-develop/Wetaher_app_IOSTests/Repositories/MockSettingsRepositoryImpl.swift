//
//  MockSettingRepositoryImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 11.11.2026.
//


@testable import Wetaher_app_IOS

// Настройки в памяти: тема хранится в переданном хранилище и не трогает `UserDefaults`
public final class MockSettingsRepositoryImpl: SettingsRepository {
    private let preferences: UserPreferencesStoring

    public init(preferences: UserPreferencesStoring = MockUserPreferencesStore()) {
        self.preferences = preferences
    }

    public func LoadThemeID() -> String? {
        preferences.themeID
    }

    public func SetTheme(id: String) {
        preferences.themeID = id
    }
}
