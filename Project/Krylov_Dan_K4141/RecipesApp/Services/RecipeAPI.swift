import Foundation

struct LoadedRecipe: Sendable {
    let title: String
    let ingredients: String
    let steps: String
    let category: MealType
    var photo: Data?
    var photoDownloadFailed = false
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
    let photoURL: String

    init(from decoder: Decoder) throws {
        let decoded = try [String: String?](from: decoder)
        var json: [String: String] = [:]
        for (key, value) in decoded {
            if let value {
                json[key] = value
            }
        }

        func value(_ key: String) -> String {
            (json[key] ?? "").trimmingCharacters(in: .whitespaces)
        }

        name = value("strMeal")
        category = value("strCategory")
        instructions = value("strInstructions")
        photoURL = value("strMealThumb")

        var ingredientList: [String] = []
        for index in 1...20 {
            let ingredient = value("strIngredient\(index)")
            let measure = value("strMeasure\(index)")
            if !ingredient.isEmpty {
                if measure.isEmpty {
                    ingredientList.append(ingredient)
                } else {
                    ingredientList.append("\(ingredient) — \(measure)")
                }
            }
        }
        ingredients = ingredientList
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
        var recipe = convert(meal, type: type)
        if !meal.photoURL.isEmpty {
            do {
                recipe.photo = try await RecipePhotoLoader.load(from: meal.photoURL)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // Ошибка фотографии не должна мешать сохранению самого рецепта.
                recipe.photoDownloadFailed = true
            }
        }
        return recipe
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
        var steps: [String] = []
        for line in meal.instructions.components(separatedBy: .newlines) {
            let step = line.trimmingCharacters(in: .whitespaces)
            if !step.isEmpty && !step.lowercased().hasPrefix("step") {
                steps.append(step)
            }
        }

        var category = MealType.lunch
        if let type {
            category = type
        } else {
            for (mealType, serverCategories) in categories {
                if !serverCategories.contains(meal.category) {
                    continue
                }
                category = mealType
                break
            }
        }

        return LoadedRecipe(
            title: meal.name,
            ingredients: meal.ingredients.joined(separator: "\n"),
            steps: steps.joined(separator: "\n"),
            category: category
        )
    }
}
