
import Foundation

@Observable
@MainActor
final class SettingsViewModel {
    private let store: SettingsStore

    init(store: SettingsStore) {
        self.store = store
    }

    var settings: AppSettings {
        get { store.settings }
        set { store.settings = newValue }
    }

    var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
