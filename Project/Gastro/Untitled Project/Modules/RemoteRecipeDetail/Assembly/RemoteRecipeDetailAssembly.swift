import SwiftUI

@MainActor
protocol RemoteRecipeDetailAssembly {
    associatedtype Content: View

    func build(
        id: Int,
        recipeService: any RecipeService,
        navigator: any AppNavigating
    ) -> Content
}
