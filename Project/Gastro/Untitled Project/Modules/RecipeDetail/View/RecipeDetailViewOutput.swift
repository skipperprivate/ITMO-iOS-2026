import Combine
import Foundation

@MainActor
protocol RecipeDetailViewOutput: ObservableObject {
    var state: RecipeDetailViewState { get }

    func load()

    func edit()

    func delete()

    func clearError()
}
