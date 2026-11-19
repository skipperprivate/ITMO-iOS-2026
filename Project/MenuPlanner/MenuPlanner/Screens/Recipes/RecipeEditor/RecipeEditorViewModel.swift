import Foundation
import Observation
import SwiftData

enum RecipeEditorField: Hashable {
    case name, duration, servings, ingredients, instructions
    case ingredientName(UUID)
    case ingredientQuantity(UUID)
}

enum RecipeValidationError: LocalizedError {
    case nameRequired
    case invalidParameters
    case ingredientsRequired
    case invalidIngredient

    var errorDescription: String? {
        switch self {
        case .nameRequired: "Укажи название рецепта."
        case .invalidParameters: "Время приготовления и количество порций должны быть больше нуля."
        case .ingredientsRequired: "Добавь хотя бы один ингредиент."
        case .invalidIngredient: "У каждого ингредиента должны быть название и количество больше нуля."
        }
    }
}

@MainActor
@Observable
final class RecipeEditorViewModel {
    let recipe: Recipe?
    let importedRecipe: VkusVillRecipe?
    var name: String
    var instructions: String
    var durationMinutes: Int
    var baseServings: Int
    var ingredients: [RecipeIngredientDraft]
    var photoData: Data?
    var isLoadingPhoto = false
    var remotePhotoFailed = false
    var errorMessage: String?
    var hasAttemptedSave = false

    init(recipe: Recipe? = nil, importedRecipe: VkusVillRecipe? = nil) {
        self.recipe = recipe
        self.importedRecipe = importedRecipe
        name = recipe?.name ?? ""
        instructions = recipe?.recipeDescription ?? ""
        durationMinutes = recipe?.durationMinutes ?? 15
        baseServings = recipe?.baseServings ?? 2
        photoData = recipe?.photoData
        ingredients = recipe?.ingredients.map {
            RecipeIngredientDraft(
                name: $0.ingredient.name,
                quantity: String($0.quantity),
                unit: $0.unit
            )
        } ?? [RecipeIngredientDraft()]

        if let importedRecipe {
            name = importedRecipe.name
            instructions = RecipeImportMapper.instructions(from: importedRecipe)
            durationMinutes = RecipeImportMapper.duration(from: importedRecipe.cookingTime?.name) ?? 15
            baseServings = importedRecipe.portions.flatMap { (1...100).contains($0) ? $0 : nil } ?? 2
            let importedIngredients = RecipeImportMapper.ingredients(from: importedRecipe)
            if !importedIngredients.isEmpty { ingredients = importedIngredients }
        }
    }

    var canSave: Bool {
        (try? validate()) != nil && !isLoadingPhoto
    }

    var validationErrors: [RecipeEditorField: String] {
        var errors: [RecipeEditorField: String] = [:]
        for field in [RecipeEditorField.name, .duration, .servings, .ingredients] {
            errors[field] = error(for: field)
        }
        for row in ingredients {
            errors[.ingredientName(row.id)] = row.nameError
            errors[.ingredientQuantity(row.id)] = row.quantityError
        }
        return errors
    }

    var firstInvalidField: RecipeEditorField? {
        for field in [RecipeEditorField.name, .duration, .servings, .ingredients] {
            if error(for: field) != nil { return field }
        }
        for row in ingredients {
            if row.nameError != nil { return .ingredientName(row.id) }
            if row.quantityError != nil { return .ingredientQuantity(row.id) }
        }
        return nil
    }

    func validationMessage(for field: RecipeEditorField) -> String? {
        hasAttemptedSave ? error(for: field) : nil
    }

    private func error(for field: RecipeEditorField) -> String? {
        switch field {
        case .name:
            return name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Укажи название рецепта" : nil
        case .duration:
            return (1...1_440).contains(durationMinutes) ? nil : "Укажи время от 1 до 1440 минут"
        case .servings:
            return (1...100).contains(baseServings) ? nil : "Укажи от 1 до 100 порций"
        case .ingredients:
            return ingredients.isEmpty ? "Добавь хотя бы один ингредиент" : nil
        case .ingredientName(let id):
            return ingredients.first { $0.id == id }?.nameError
        case .ingredientQuantity(let id):
            return ingredients.first { $0.id == id }?.quantityError
        case .instructions:
            return nil
        }
    }

    func removeIngredient(id: UUID) {
        ingredients.removeAll { $0.id == id }
    }

    func loadImportedPhoto() async {
        guard let url = importedRecipe?.photoURL,
                photoData == nil,
                !isLoadingPhoto
        else {
            return
        }
        
        isLoadingPhoto = true
        
        defer {
            isLoadingPhoto = false
        }
        
        do {
            let data = try await VkusVillCatalog().recipePhoto(from: url)
            try Task.checkCancellation()
            photoData = data
        } catch {
            if !Task.isCancelled { remotePhotoFailed = true }
        }
    }

    func validate() throws {
        switch firstInvalidField {
        case .name: throw RecipeValidationError.nameRequired
        case .duration, .servings: throw RecipeValidationError.invalidParameters
        case .ingredients: throw RecipeValidationError.ingredientsRequired
        case .ingredientName, .ingredientQuantity: throw RecipeValidationError.invalidIngredient
        default: return
        }
    }

    @discardableResult
    func save(in context: ModelContext) throws -> Recipe {
        hasAttemptedSave = true
        try validate()

        var productsByName: [String: Ingredient] = [:]
        for ingredient in try context.fetch(FetchDescriptor<Ingredient>()) {
            productsByName[normalizedName(ingredient.name)] = ingredient
        }

        let rows = ingredients.map { row in
            let name = row.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = normalizedName(name)
            let ingredient = productsByName[key] ?? Ingredient(name: name)
            ingredient.addVkusVillProductSuggestions(row.suggestedProductIDs)
            productsByName[key] = ingredient
            return RecipeIngredient(
                ingredient: ingredient,
                quantity: row.parsedQuantity!,
                unit: row.unit
            )
        }

        let savedRecipe: Recipe
        if let recipe {
            let previousRows = recipe.ingredients
            recipe.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            recipe.recipeDescription = instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            recipe.durationMinutes = durationMinutes
            recipe.updateBaseServings(to: baseServings)
            recipe.photoData = photoData
            recipe.isBuiltIn = false
            recipe.ingredients = rows
            for row in previousRows { context.delete(row) }
            savedRecipe = recipe
        } else {
            savedRecipe = Recipe(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                recipeDescription: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
                durationMinutes: durationMinutes,
                baseServings: baseServings,
                ingredients: rows,
                photoData: photoData,
                sourceURL: importedRecipe?.sourceURL
            )
            context.insert(savedRecipe)
        }

        do { try context.save() } catch {
            context.rollback()
            throw error
        }
        return savedRecipe
    }

    private func normalizedName(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "ru_RU"))
    }
}
