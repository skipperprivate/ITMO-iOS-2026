//
//  SettingsRepository.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

// Настройки оформления приложения
@MainActor
public protocol SettingsRepository {
    // Идентификатор выбранной темы оформления (`AppThemeProps.id`)
    func LoadThemeID() -> String?

    // Сохраняет тему оформления
    func SetTheme(id: String)
}
