import Foundation

enum AppConfig {
    static let kinopoiskAPIKey: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "KINOPOISK_API_KEY"
        ) as? String,
              !key.isEmpty else {
            fatalError("API key is missing")
        }
        return key
    }()
}
