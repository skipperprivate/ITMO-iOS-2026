import Combine
import Foundation

@MainActor
protocol HomeRouter {
    func showRecipes()

    func showProfile()
}
