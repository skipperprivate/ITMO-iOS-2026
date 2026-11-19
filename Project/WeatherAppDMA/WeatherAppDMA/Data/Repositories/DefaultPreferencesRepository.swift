import Foundation

final class DefaultPreferencesRepository: PreferencesRepository, @unchecked Sendable {
    private let dataSource: UserDefaultsPreferencesDataSource

    init(dataSource: UserDefaultsPreferencesDataSource) {
        self.dataSource = dataSource
    }

    func get() -> UserPreferences {
        dataSource.load()
    }

    func update(_ preferences: UserPreferences) {
        dataSource.save(preferences)
    }

    func setTemperatureUnit(_ unit: TemperatureUnit) {
        dataSource.setTemperatureUnit(unit)
    }

    func setWindUnit(_ unit: WindUnit) {
        dataSource.setWindUnit(unit)
    }

    func setLastOpenedCity(_ city: String?) {
        dataSource.setLastOpenedCity(city)
    }

    func reset() {
        dataSource.reset()
    }
}
