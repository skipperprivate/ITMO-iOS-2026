import Foundation

nonisolated struct VkusVillProduct: Codable, Identifiable {
    struct Price: Codable {
        let current: Decimal?
    }

    struct Weight: Codable {
        let value: Double
        let unit: String
    }

    struct Photo: Codable {
        let small: URL?
    }

    let id: Int
    let name: String
    let price: Price?
    let unit: String?
    let weight: Weight?
    let url: URL?
    let images: [Photo]?

    var displayName: String {
        name.replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
    }

    var photoURL: URL? { images?.first?.small }

    var pageURL: URL? {
        guard let url, url.scheme == "https", url.host == "vkusvill.ru" else { return nil }
        return url
    }

    var priceText: String? {
        price?.current?.formatted(.currency(code: "RUB").locale(Locale(identifier: "ru_RU")))
    }

    var cartUnit: String { sellsByWeight ? "кг" : "шт." }
    private var sellsByWeight: Bool { unit?.lowercased() == "кг" }

    @MainActor
    func suggestedQuantity(for items: [ShoppingItem]) -> Double? {
        let converter = UnitConverter()
        var total = 0.0

        for item in items {
            let required = converter.normalize(quantity: item.quantity, unit: item.unit)
            switch (sellsByWeight, required.unit) {
            case (true, .gram):
                total += required.quantity / 1_000
            case (false, .piece):
                guard unit == "шт" || unit == "шт." else { return nil }
                total += required.quantity
            case (false, .gram):
                guard let weight, weight.value.isFinite, weight.value > 0 else { return nil }
                let grams: Double
                switch weight.unit {
                case "кг": grams = weight.value * 1_000
                case "г": grams = weight.value
                default: return nil
                }
                total += required.quantity / grams
            case (false, .milliliter):
                guard let milliliters = packageVolume else { return nil }
                total += required.quantity / milliliters
            default:
                return nil
            }
        }

        let quantity = sellsByWeight ? ceil(total * 100 - 0.000_001) / 100 : ceil(total - 0.000_001)
        return (0.01...40).contains(quantity) ? quantity : nil
    }

    private var packageVolume: Double? {
        let pattern = #/([0-9]+(?:[.,][0-9]+)?)\s*(мл|л)\.?\s*$/#
        guard let match = displayName.lowercased().firstMatch(of: pattern),
              let value = Double(match.1.replacingOccurrences(of: ",", with: ".")), value > 0 else { return nil }
        return match.2 == "л" ? value * 1_000 : value
    }
}
