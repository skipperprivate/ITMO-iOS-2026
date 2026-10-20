import Foundation
import Observation

@MainActor
@Observable
final class RecipeDetailViewModel {
    var isUploading = false
    var message: String?

    var showMessage: Bool {
        get { message != nil }
        set { if !newValue { message = nil } }
    }

    func upload(_ recipe: Recipe) async {
        isUploading = true
        defer { isUploading = false }

        let body = RecipeUploadBody(title: recipe.title, ingredients: recipe.ingredientList,
                                    steps: recipe.stepList, category: recipe.category.rawValue)
        do {
            let response = try await RecipeUploadAPI.upload(body)
            message = "Сервер принял рецепт «\(response.title)», id: \(response.id)"
        } catch {
            message = error.localizedDescription
        }
    }
}
