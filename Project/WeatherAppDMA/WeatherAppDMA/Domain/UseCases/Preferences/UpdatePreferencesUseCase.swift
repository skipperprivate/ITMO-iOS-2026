import Foundation

protocol UpdatePreferencesUseCase: Sendable {
    func setTemperatureUnit(_ unit: TemperatureUnit)
    func setWindUnit(_ unit: WindUnit)
    func setLastOpenedCity(_ city: String?)
    func reset()
}

struct DefaultUpdatePreferencesUseCase: UpdatePreferencesUseCase {
    let repository: PreferencesRepository

    func setTemperatureUnit(_ unit: TemperatureUnit) {
        repository.setTemperatureUnit(unit)
    }

    func setWindUnit(_ unit: WindUnit) {
        repository.setWindUnit(unit)
    }

    func setLastOpenedCity(_ city: String?) {
        repository.setLastOpenedCity(city)
    }

    func reset() {
        repository.reset()
    }
}
