

import Foundation

final class SettingsModel:
    SettingsModelProtocol {

    private let settings:
        AppSettings

    init(
        settings: AppSettings
    ) {
        self.settings = settings
    }

    var hideWatched: Bool {

        get {
            settings.hideWatched
        }

        set {
            settings.hideWatched =
                newValue
        }
    }
}
