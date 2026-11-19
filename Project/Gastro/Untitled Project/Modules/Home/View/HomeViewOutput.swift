import Combine
import Foundation

@MainActor
protocol HomeViewOutput: ObservableObject {
    var state: HomeViewState { get }

    func load()

    func showRecipes()

    func showProfile()

    func clearError()
}
