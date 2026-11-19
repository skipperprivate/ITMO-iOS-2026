import Foundation
import Combine

@MainActor
final class PreferencesStore: ObservableObject {
    @Published private(set) var preferences: UserPreferences

    private let getUseCase: GetPreferencesUseCase
    private let updateUseCase: UpdatePreferencesUseCase

    init(getUseCase: GetPreferencesUseCase, updateUseCase: UpdatePreferencesUseCase) {
        self.getUseCase = getUseCase
        self.updateUseCase = updateUseCase
        self.preferences = getUseCase.execute()
    }

    func setTemperatureUnit(_ unit: TemperatureUnit) {
        updateUseCase.setTemperatureUnit(unit)
        preferences.temperatureUnit = unit
    }

    func setWindUnit(_ unit: WindUnit) {
        updateUseCase.setWindUnit(unit)
        preferences.windUnit = unit
    }

    func setLastOpenedCity(_ city: String?) {
        updateUseCase.setLastOpenedCity(city)
        preferences.lastOpenedCity = city
    }

    func reset() {
        updateUseCase.reset()
        preferences = getUseCase.execute()
    }
}
