//
//  UserPreferencesStore.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

/// Пользовательские настройки
public protocol UserPreferencesStoring: AnyObject {
    /// Идентификатор последнего просмотренного города.
    var activeCityID: Int? { get set }

    /// Список избранных городов.
    var favoriteCities: [CityEntity] { get set }

    /// Идентификатор выбранной темы оформления (`AppThemeProps.id`).
    var themeID: String? { get set }
}

/// Реализация поверх `UserDefaults`.
public final class UserPreferencesStore: UserPreferencesStoring {
    private enum Keys {
        static let activeCityID = "weather.preferences.activeCityID"
        static let favoriteCities = "weather.preferences.favoriteCities"
        static let themeID = "weather.preferences.themeID"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var activeCityID: Int? {
        get {
            guard defaults.object(forKey: Keys.activeCityID) != nil else { return nil }
            return defaults.integer(forKey: Keys.activeCityID)
        }
        set {
            guard let newValue else {
                defaults.removeObject(forKey: Keys.activeCityID)
                return
            }
            defaults.set(newValue, forKey: Keys.activeCityID)
        }
    }

    public var favoriteCities: [CityEntity] {
        get {
            guard
                let data = defaults.data(forKey: Keys.favoriteCities),
                let cities = try? JSONDecoder().decode([CityEntity].self, from: data)
            else {
                return []
            }
            return cities
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(data, forKey: Keys.favoriteCities)
        }
    }

    public var themeID: String? {
        get {
            defaults.string(forKey: Keys.themeID)
        }
        set {
            guard let newValue else {
                defaults.removeObject(forKey: Keys.themeID)
                return
            }
            defaults.set(newValue, forKey: Keys.themeID)
        }
    }
}
