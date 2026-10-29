import SwiftUI

@MainActor
protocol RecipeEditorAssembly {
    associatedtype Content: View

    func build(
        id: UUID?,
        repository: any RecipeRepository,
        recipeService: any RecipeService,
        navigator: any AppNavigating
    ) -> Content
}
