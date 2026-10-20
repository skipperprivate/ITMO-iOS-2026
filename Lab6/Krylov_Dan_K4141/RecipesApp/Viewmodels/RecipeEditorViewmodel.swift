import Foundation
import SwiftData
import Observation

struct EditableLine: Identifiable {
    let id = UUID()
    var text = ""
}

@Observable
final class RecipeEditorViewModel {
    var title: String
    var category: MealType
    var ingredients: [EditableLine]
    var steps: [EditableLine]
    private let recipe: Recipe?

    var isEditing: Bool { recipe != nil }
    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    init(recipe: Recipe? = nil) {
        self.recipe = recipe
        title = recipe?.title ?? ""
        category = recipe?.category ?? .lunch
        ingredients = Self.makeLines(recipe?.ingredientList)
        steps = Self.makeLines(recipe?.stepList)
    }

    func addIngredient() { ingredients.append(EditableLine()) }
    func addStep() { steps.append(EditableLine()) }

    func removeIngredients(at offsets: IndexSet) {
        for i in offsets.sorted(by: >) { ingredients.remove(at: i) }
    }

    func removeSteps(at offsets: IndexSet) {
        for i in offsets.sorted(by: >) { steps.remove(at: i) }
    }

    func save(context: ModelContext) {
        let ingredientsText = ingredients.map(\.text).joined(separator: "\n")
        let stepsText = steps.map(\.text).joined(separator: "\n")

        if let recipe {
            recipe.title = title
            recipe.category = category
            recipe.ingredients = ingredientsText
            recipe.steps = stepsText
        } else {
            let newRecipe = Recipe(title: title, ingredients: ingredientsText,
                                   steps: stepsText, category: category)
            context.insert(newRecipe)
        }
    }

    private static func makeLines(_ texts: [String]?) -> [EditableLine] {
        let lines = (texts ?? []).map { EditableLine(text: $0) }
        return lines.isEmpty ? [EditableLine()] : lines
    }
}
