import Foundation

struct LoadedRecipe: Sendable {
    let title: String
    let ingredients: String
    let steps: String
    let category: MealType
}

struct MealListResponse: Decodable {
    let meals: [MealShort]?
}

struct MealShort: Decodable {
    let id: String

    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
    }
}

struct MealDetailResponse: Decodable {
    let meals: [MealDetail]?
}

struct MealDetail: Decodable {
    let name: String
    let category: String
    let instructions: String
    let ingredients: [String]

    init(from decoder: Decoder) throws {
        let json = try [String: String?](from: decoder).compactMapValues { $0 }

        func value(_ key: String) -> String {
            (json[key] ?? "").trimmingCharacters(in: .whitespaces)
        }

        name = value("strMeal")
        category = value("strCategory")
        instructions = value("strInstructions")

        ingredients = (1...20).compactMap { i -> String? in
            let ingredient = value("strIngredient\(i)")
            let measure = value("strMeasure\(i)")
            if ingredient.isEmpty { return nil }
            return measure.isEmpty ? ingredient : "\(ingredient) — \(measure)"
        }
    }
}

enum RecipeAPI {
    static let baseURL = "https://www.themealdb.com/api/json/v1/1/"

    static let categories: [MealType: [String]] = [
        .breakfast: ["Breakfast"],
        .lunch: ["Chicken", "Pasta", "Vegetarian"],
        .dinner: ["Beef", "Seafood", "Lamb", "Pork"],
        .snack: ["Starter", "Side", "Dessert"]
    ]

    static func fetchRandom(for type: MealType? = nil) async throws -> LoadedRecipe {
        let detail: MealDetailResponse

        if let type {
            let category = categories[type]?.randomElement() ?? "Breakfast"
            let list: MealListResponse = try await get("filter.php", query: ["c": category])
            guard let short = list.meals?.randomElement() else { throw NetworkError.emptyResponse }
            detail = try await get("lookup.php", query: ["i": short.id])
        } else {
            detail = try await get("random.php")
        }

        guard let meal = detail.meals?.first else { throw NetworkError.emptyResponse }
        return convert(meal, type: type)
    }

    static func fetchOnePerCategory() async -> [LoadedRecipe] {
        await withTaskGroup(of: LoadedRecipe?.self) { group in
            for type in MealType.allCases {
                group.addTask { try? await fetchRandom(for: type) }
            }

            var result: [LoadedRecipe] = []
            for await recipe in group {
                if let recipe { result.append(recipe) }
            }
            return result
        }
    }

    static func get<T: Decodable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        let url = try NetworkClient.makeURL(baseURL + path, query: query)
        return try await NetworkClient.get(url)
    }

    static func convert(_ meal: MealDetail, type: MealType?) -> LoadedRecipe {
        let steps = meal.instructions
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.lowercased().hasPrefix("step") }

        let found = categories.first(where: { $0.value.contains(meal.category) })?.key

        return LoadedRecipe(
            title: meal.name,
            ingredients: meal.ingredients.joined(separator: "\n"),
            steps: steps.joined(separator: "\n"),
            category: type ?? found ?? .lunch
        )
    }
}
