import Foundation
import Observation
import SwiftData

struct EditableLine: Identifiable {
    let id = UUID()
    var text = ""
    var photo: Data?
}

@Observable
class RecipeEditorViewModel {
    var title: String
    var category: MealType
    var ingredients: [EditableLine]
    var steps: [EditableLine]
    var photo: Data?
    var photoAddress = ""
    var isLoadingPhoto = false
    var photoError: String?
    private let recipe: Recipe?

    var showPhotoError: Bool {
        get {
            return photoError != nil
        }
        set {
            if !newValue {
                photoError = nil
            }
        }
    }

    var isEditing: Bool {
        return recipe != nil
    }
    var canSave: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        return !trimmedTitle.isEmpty
    }

    init(recipe: Recipe? = nil) {
        self.recipe = recipe
        title = recipe?.title ?? ""
        category = recipe?.category ?? .lunch
        ingredients = Self.makeLines(recipe?.ingredientList)
        steps = Self.makeLines(recipe?.stepList)
        for index in steps.indices {
            steps[index].photo = recipe?.stepPhoto(at: index)
        }
        photo = recipe?.photo
    }

    @MainActor
    func loadPhotoFromURL(session: URLSession = .shared) async {
        isLoadingPhoto = true
        photoError = nil
        defer {
            isLoadingPhoto = false
        }

        do {
            let downloadedPhoto = try await RecipePhotoLoader.load(from: photoAddress, session: session)
            photo = downloadedPhoto
        } catch {
            // Старое фото сохраняем, если загрузка нового не удалась.
            photoError = error.localizedDescription
        }
    }

    func addIngredient() {
        ingredients.append(EditableLine())
    }
    func addStep() {
        steps.append(EditableLine())
    }

    func removeIngredients(at offsets: IndexSet) {
        // Удаляем с конца, чтобы индексы оставшихся строк не сдвигались.
        for index in offsets.sorted(by: >) {
            ingredients.remove(at: index)
        }
    }

    func removeSteps(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            steps.remove(at: index)
        }
    }

    func save(context: ModelContext) {
        var ingredientTexts: [String] = []
        for ingredient in ingredients {
            ingredientTexts.append(ingredient.text)
        }
        let ingredientsText = ingredientTexts.joined(separator: "\n")

        // Текст и фото добавляем вместе, чтобы сохранить их соответствие.
        var stepTexts: [String] = []
        var stepPhotos: [Data] = []
        for step in steps {
            if step.text.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            stepTexts.append(step.text)
            stepPhotos.append(step.photo ?? Data())
        }
        let stepsText = stepTexts.joined(separator: "\n")

        if let recipe {
            recipe.title = title
            recipe.category = category
            recipe.ingredients = ingredientsText
            recipe.steps = stepsText
            recipe.photo = photo
            recipe.stepPhotos = stepPhotos
        } else {
            let newRecipe = Recipe(
                title: title,
                ingredients: ingredientsText,
                steps: stepsText,
                category: category
            )
            newRecipe.photo = photo
            newRecipe.stepPhotos = stepPhotos
            context.insert(newRecipe)
        }
    }

    private static func makeLines(_ texts: [String]?) -> [EditableLine] {
        var lines: [EditableLine] = []
        if let texts {
            for text in texts {
                lines.append(EditableLine(text: text))
            }
        }
        if lines.isEmpty {
            lines.append(EditableLine())
        }
        return lines
    }
}
