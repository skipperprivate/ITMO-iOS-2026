import Foundation

nonisolated struct VkusVillRecipe: Decodable, Identifiable, Sendable {
    struct Ingredient: Decodable, Sendable {
        let name: String
        let quantity: String?
        let ids: [String]?

        var productIDs: [Int] { (ids ?? []).compactMap(Int.init).filter { $0 > 0 } }
    }

    struct Step: Decodable, Sendable {
        let stepNumber: Int
        let text: String
    }

    struct CookingTime: Decodable, Sendable {
        let name: String
    }

    let id: Int
    let name: String
    let url: URL?
    let image: URL?
    let description: String?
    let portions: Int?
    let cookingTime: CookingTime?
    let ingredients: [Ingredient]?
    let steps: [Step]?

    var sourceURL: URL? { Self.officialURL(url) }
    var photoURL: URL? { Self.officialURL(image) }

    private static func officialURL(_ url: URL?) -> URL? {
        guard let url, url.scheme == "https", url.host == "vkusvill.ru" else { return nil }
        return url
    }
}
