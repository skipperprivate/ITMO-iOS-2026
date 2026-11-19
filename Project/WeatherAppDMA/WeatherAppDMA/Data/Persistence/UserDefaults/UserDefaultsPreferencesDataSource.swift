import Foundation

final class UserDefaultsPreferencesDataSource: @unchecked Sendable {
    private enum Key {
        static let temperatureUnit = "preferences.temperatureUnit"
        static let windUnit = "preferences.windUnit"
        static let lastOpenedCity = "preferences.lastOpenedCity"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> UserPreferences {
        let temperatureUnit = defaults.string(forKey: Key.temperatureUnit)
            .flatMap(TemperatureUnit.init(rawValue:)) ?? .celsius
        let windUnit = defaults.string(forKey: Key.windUnit)
            .flatMap(WindUnit.init(rawValue:)) ?? .metersPerSecond
        let lastOpenedCity = defaults.string(forKey: Key.lastOpenedCity)
        return UserPreferences(
            temperatureUnit: temperatureUnit,
            windUnit: windUnit,
            lastOpenedCity: lastOpenedCity
        )
    }

    func save(_ preferences: UserPreferences) {
        defaults.set(preferences.temperatureUnit.rawValue, forKey: Key.temperatureUnit)
        defaults.set(preferences.windUnit.rawValue, forKey: Key.windUnit)
        if let city = preferences.lastOpenedCity {
            defaults.set(city, forKey: Key.lastOpenedCity)
        } else {
            defaults.removeObject(forKey: Key.lastOpenedCity)
        }
    }

    func setTemperatureUnit(_ unit: TemperatureUnit) {
        defaults.set(unit.rawValue, forKey: Key.temperatureUnit)
    }

    func setWindUnit(_ unit: WindUnit) {
        defaults.set(unit.rawValue, forKey: Key.windUnit)
    }

    func setLastOpenedCity(_ city: String?) {
        if let city, !city.isEmpty {
            defaults.set(city, forKey: Key.lastOpenedCity)
        } else {
            defaults.removeObject(forKey: Key.lastOpenedCity)
        }
    }

    func reset() {
        defaults.removeObject(forKey: Key.temperatureUnit)
        defaults.removeObject(forKey: Key.windUnit)
        defaults.removeObject(forKey: Key.lastOpenedCity)
    }
}
