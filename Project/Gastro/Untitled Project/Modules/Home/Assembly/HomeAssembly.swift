import SwiftUI

@MainActor
protocol HomeAssembly {
    associatedtype Content: View

    func build(repository: any RecipeRepository, navigator: any AppNavigating) -> Content
}
