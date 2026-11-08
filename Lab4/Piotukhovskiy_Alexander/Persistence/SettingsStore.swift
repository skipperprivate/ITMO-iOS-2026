import Foundation

@MainActor
final class SettingsStore {
    private enum Key {
        static let fahrenheit = "weather.useFahrenheit"
        static let selectedCityID = "weather.selectedCityID"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func createDefaultsIfNeeded() {
        if defaults.object(forKey: Key.fahrenheit) == nil {
            defaults.set(false, forKey: Key.fahrenheit)
        }
    }

    var useFahrenheit: Bool {
        get { defaults.bool(forKey: Key.fahrenheit) }
        set { defaults.set(newValue, forKey: Key.fahrenheit) }
    }

    var selectedCityID: Int? {
        get {
            guard defaults.object(forKey: Key.selectedCityID) != nil else { return nil }
            let value = defaults.integer(forKey: Key.selectedCityID)
            return value > 0 ? value : nil
        }
        set {
            if let newValue {
                defaults.set(newValue, forKey: Key.selectedCityID)
            } else {
                defaults.removeObject(forKey: Key.selectedCityID)
            }
        }
    }

    func reset() {
        defaults.removeObject(forKey: Key.fahrenheit)
        defaults.removeObject(forKey: Key.selectedCityID)
    }
}
