import SwiftUI

@MainActor
protocol RecipeDetailAssembly {
    associatedtype Content: View

    func build(id: UUID, repository: any RecipeRepository, navigator: any AppNavigating) -> Content
}
