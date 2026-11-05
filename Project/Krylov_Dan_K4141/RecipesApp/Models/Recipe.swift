import Foundation
import SwiftData

enum MealType: String, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breakfast:
            return "Завтрак"
        case .lunch:
            return "Обед"
        case .dinner:
            return "Ужин"
        case .snack:
            return "Перекус"
        }
    }

    var plural: String {
        switch self {
        case .breakfast:
            return "Завтраки"
        case .lunch:
            return "Обеды"
        case .dinner:
            return "Ужины"
        case .snack:
            return "Перекусы"
        }
    }

    var icon: String {
        switch self {
        case .breakfast:
            return "sunrise"
        case .lunch:
            return "sun.max"
        case .dinner:
            return "moon.stars"
        case .snack:
            return "carrot"
        }
    }
}

@Model
final class Recipe {
    var title: String
    var ingredients: String
    var steps: String
    var categoryRaw: String = MealType.lunch.rawValue
    var createdAt = Date.now
    var isFavorite: Bool = false
    @Attribute(.externalStorage) var photo: Data?
    var stepPhotos: [Data] = []

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

    func stepPhoto(at index: Int) -> Data? {
        if index < 0 || index >= stepPhotos.count {
            return nil
        }
        if stepPhotos[index].isEmpty {
            return nil
        }
        return stepPhotos[index]
    }

    private static func lines(_ text: String) -> [String] {
        var result: [String] = []
        for line in text.components(separatedBy: "\n") {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if !trimmedLine.isEmpty {
                result.append(trimmedLine)
            }
        }
        return result
    }
}
