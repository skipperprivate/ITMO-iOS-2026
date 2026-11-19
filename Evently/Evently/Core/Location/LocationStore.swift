import Foundation
import Observation


@MainActor
@Observable
final class LocationStore {
    private enum Keys {
        static let city = "evently.location.city"
        static let country = "evently.location.country"
    }

    private(set) var city: String?
    private(set) var countryCode: String?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        city = defaults.string(forKey: Keys.city)
        countryCode = defaults.string(forKey: Keys.country)
    }

    @ObservationIgnored private let defaults: UserDefaults

    var displayName: String {
        guard let city, !city.isEmpty else { return "Город не выбран" }
        return city + (countryCode.map { " (\($0))" } ?? "")
    }

    var selectionKey: String {
        "\(countryCode ?? EventCatalogConfiguration.defaultCountryCode)|\(city ?? "*")".lowercased()
    }

    func select(city: String, countryCode: String) {
        let cleanCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCode = countryCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleanCity.isEmpty, cleanCode.count == 2 else { return }
        self.city = cleanCity
        self.countryCode = cleanCode
        defaults.set(cleanCity, forKey: Keys.city)
        defaults.set(cleanCode, forKey: Keys.country)
    }

    func clear() {
        city = nil
        countryCode = nil
        defaults.removeObject(forKey: Keys.city)
        defaults.removeObject(forKey: Keys.country)
    }
}
