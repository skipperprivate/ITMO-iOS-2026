import SwiftUI

@MainActor
protocol RecipeListAssembly {
    associatedtype Content: View

    func build(
        repository: any RecipeRepository,
        recipeService: any RecipeService,
        navigator: any AppNavigating
    ) -> Content
}
