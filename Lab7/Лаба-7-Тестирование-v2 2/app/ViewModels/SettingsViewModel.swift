import Foundation
import Observation

// Один экземпляр используется лентой, деталями и настройками.
@MainActor
@Observable
final class SettingsViewModel {
    var showDates: Bool {
        didSet { defaults.set(showDates, forKey: "showDates") }
    }
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        showDates = defaults.object(forKey: "showDates") as? Bool ?? true
    }

    func reset() {
        showDates = true
        // Удаляем ключ после didSet, чтобы сброс действительно означал DELETE.
        defaults.removeObject(forKey: "showDates")
    }
}
