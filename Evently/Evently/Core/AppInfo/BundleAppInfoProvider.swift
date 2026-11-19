import Foundation

struct BundleAppInfoProvider: AppInfoProviding {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func getInfo() -> AppInfo {
        AppInfo(
            name: value(for: "CFBundleDisplayName") ?? value(for: "CFBundleName") ?? "Evently",
            developer: value(for: "EventlyDeveloperName") ?? "—",
            version: value(for: "CFBundleShortVersionString") ?? "—",
            build: value(for: "CFBundleVersion") ?? "—",
            description: "Evently — приложение для поиска мероприятий и сохранения избранного.",
            technologies: "SwiftUI · SwiftData · Core Location · URLSession · Swift Concurrency"
        )
    }

    private func value(for key: String) -> String? {
        guard let value = bundle.object(forInfoDictionaryKey: key) as? String,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return value
    }
}
