import Foundation
import SwiftData

enum MealType: String, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breakfast: "Завтрак"
        case .lunch: "Обед"
        case .dinner: "Ужин"
        case .snack: "Перекус"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: "sunrise"
        case .lunch: "sun.max"
        case .dinner: "moon.stars"
        case .snack: "carrot"
        }
    }
}

@Model
final class Recipe {
    var title: String
    var ingredients: String
    var steps: String
    var categoryRaw: String = MealType.lunch.rawValue
    var createdAt: Date = Date.now

    var category: MealType {
        get { MealType(rawValue: categoryRaw) ?? .lunch }
        set { categoryRaw = newValue.rawValue }
    }

    var ingredientList: [String] { Recipe.lines(ingredients) }
    var stepList: [String] { Recipe.lines(steps) }

    init(title: String, ingredients: String, steps: String, category: MealType) {
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
        categoryRaw = category.rawValue
    }

    private static func lines(_ text: String) -> [String] {
        text.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
