import Foundation


struct TicketmasterCity: Identifiable, Hashable {
    let name: String
    let country: String
    let countryCode: String
    let aliases: [String]

    var id: String { "\(countryCode)|\(name)" }
    var displayTitle: String { "\(name), \(country)" }

    func matches(_ query: String) -> Bool {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return true }
        return ([name, country, countryCode] + aliases).contains {
            $0.localizedStandardContains(cleaned)
        }
    }
}

enum TicketmasterCities {
    static let suggestions: [TicketmasterCity] = [
        .init(name: "New York", country: "США", countryCode: "US", aliases: ["Нью-Йорк", "NYC"]),
        .init(name: "Los Angeles", country: "США", countryCode: "US", aliases: ["Лос-Анджелес", "LA"]),
        .init(name: "Chicago", country: "США", countryCode: "US", aliases: ["Чикаго"]),
        .init(name: "San Francisco", country: "США", countryCode: "US", aliases: ["Сан-Франциско"]),
        .init(name: "Miami", country: "США", countryCode: "US", aliases: ["Майами"]),
        .init(name: "Toronto", country: "Канада", countryCode: "CA", aliases: ["Торонто"]),
        .init(name: "Vancouver", country: "Канада", countryCode: "CA", aliases: ["Ванкувер"]),
        .init(name: "Montreal", country: "Канада", countryCode: "CA", aliases: ["Монреаль"]),
        .init(name: "London", country: "Великобритания", countryCode: "GB", aliases: ["Лондон"]),
        .init(name: "Manchester", country: "Великобритания", countryCode: "GB", aliases: ["Манчестер"]),
        .init(name: "Birmingham", country: "Великобритания", countryCode: "GB", aliases: ["Бирмингем"]),
        .init(name: "Dublin", country: "Ирландия", countryCode: "IE", aliases: ["Дублин"]),
        .init(name: "Berlin", country: "Германия", countryCode: "DE", aliases: ["Берлин"]),
        .init(name: "Hamburg", country: "Германия", countryCode: "DE", aliases: ["Гамбург"]),
        .init(name: "Munich", country: "Германия", countryCode: "DE", aliases: ["Мюнхен", "München"]),
        .init(name: "Cologne", country: "Германия", countryCode: "DE", aliases: ["Кёльн", "Köln"]),
        .init(name: "Paris", country: "Франция", countryCode: "FR", aliases: ["Париж"]),
        .init(name: "Lyon", country: "Франция", countryCode: "FR", aliases: ["Лион"]),
        .init(name: "Marseille", country: "Франция", countryCode: "FR", aliases: ["Марсель"]),
        .init(name: "Amsterdam", country: "Нидерланды", countryCode: "NL", aliases: ["Амстердам"]),
        .init(name: "Rotterdam", country: "Нидерланды", countryCode: "NL", aliases: ["Роттердам"]),
        .init(name: "Brussels", country: "Бельгия", countryCode: "BE", aliases: ["Брюссель"]),
        .init(name: "Vienna", country: "Австрия", countryCode: "AT", aliases: ["Вена", "Wien"]),
        .init(name: "Prague", country: "Чехия", countryCode: "CZ", aliases: ["Прага", "Praha"]),
        .init(name: "Warsaw", country: "Польша", countryCode: "PL", aliases: ["Варшава", "Warszawa"]),
        .init(name: "Krakow", country: "Польша", countryCode: "PL", aliases: ["Краков", "Kraków"]),
        .init(name: "Stockholm", country: "Швеция", countryCode: "SE", aliases: ["Стокгольм"]),
        .init(name: "Copenhagen", country: "Дания", countryCode: "DK", aliases: ["Копенгаген"]),
        .init(name: "Oslo", country: "Норвегия", countryCode: "NO", aliases: ["Осло"]),
        .init(name: "Helsinki", country: "Финляндия", countryCode: "FI", aliases: ["Хельсинки"]),
        .init(name: "Madrid", country: "Испания", countryCode: "ES", aliases: ["Мадрид"]),
        .init(name: "Barcelona", country: "Испания", countryCode: "ES", aliases: ["Барселона"]),
        .init(name: "Rome", country: "Италия", countryCode: "IT", aliases: ["Рим", "Roma"]),
        .init(name: "Milan", country: "Италия", countryCode: "IT", aliases: ["Милан", "Milano"]),
        .init(name: "Sydney", country: "Австралия", countryCode: "AU", aliases: ["Сидней"]),
        .init(name: "Melbourne", country: "Австралия", countryCode: "AU", aliases: ["Мельбурн"]),
        .init(name: "Auckland", country: "Новая Зеландия", countryCode: "NZ", aliases: ["Окленд"]),
        .init(name: "Mexico City", country: "Мексика", countryCode: "MX", aliases: ["Мехико", "Ciudad de México"])
    ]

    static let supportedCountryCodes: Set<String> = [
        "US", "CA", "MX", "AU", "NZ", "GB", "IE", "DE", "FR", "NL", "BE", "AT",
        "CZ", "PL", "SE", "DK", "NO", "FI", "ES", "IT", "CH", "BR", "CL", "PE",
        "ZA", "TR", "AE"
    ]
}
