import Foundation

@MainActor
struct MockCityService: CityService {
    let availableCities: [City] = [
        City(id: 524901, name: "Москва",
             latitude: 55.75204, longitude: 37.61781,
             country: "Россия", countryCode: "RU",
             region: "Москва", timezone: "Europe/Moscow"),
        City(id: 498817, name: "Санкт-Петербург",
             latitude: 59.93863, longitude: 30.31413,
             country: "Россия", countryCode: "RU",
             region: "Санкт-Петербург", timezone: "Europe/Moscow"),
        City(id: 2950159, name: "Берлин",
             latitude: 52.52437, longitude: 13.41053,
             country: "Германия", countryCode: "DE",
             region: "Берлин", timezone: "Europe/Berlin")
    ]

    func search(_ query: String) async throws -> [City] {
        try Task.checkCancellation()
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return availableCities }
        return availableCities.filter { city in
            let fields = [city.name, city.countryName, city.countryCode ?? "", city.region ?? ""]
            return fields.contains {
                $0.range(of: normalized, options: [.caseInsensitive, .diacriticInsensitive],
                         locale: Locale(identifier: "ru_RU")) != nil
            }
        }
    }
}
