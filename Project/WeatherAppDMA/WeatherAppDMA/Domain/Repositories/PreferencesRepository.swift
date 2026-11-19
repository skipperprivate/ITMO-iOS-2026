import Foundation

protocol PreferencesRepository: Sendable {
    func get() -> UserPreferences
    func update(_ preferences: UserPreferences)
    func setTemperatureUnit(_ unit: TemperatureUnit)
    func setWindUnit(_ unit: WindUnit)
    func setLastOpenedCity(_ city: String?)
    func reset()
}
