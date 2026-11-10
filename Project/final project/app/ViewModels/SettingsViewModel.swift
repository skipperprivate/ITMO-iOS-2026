import Foundation
import Observation

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
        defaults.removeObject(forKey: "showDates")
    }
}
