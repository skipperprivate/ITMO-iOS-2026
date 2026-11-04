


import Foundation

final class AppSettings {

    private enum Keys {
        static let hideWatched = "hideWatched"
    }

    private let defaults: UserDefaults

    init(
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults
    }

    var hideWatched: Bool {
        get {
            defaults.bool(
                forKey: Keys.hideWatched
            )
        }

        set {
            defaults.set(
                newValue,
                forKey: Keys.hideWatched
            )
        }
    }
}
