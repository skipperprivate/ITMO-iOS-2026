import Combine
import Foundation

enum AppRoute: Hashable {
    case recipes
    case networkExamples
    case profile
    case recipe(UUID)
    case remoteRecipe(Int)
    case newRecipe
    case editRecipe(UUID)
}

@MainActor
protocol AppNavigating: AnyObject {
    func showRecipes()

    func showNetworkExamples()

    func showProfile()

    func showRecipe(id: UUID)

    func showRemoteRecipe(id: Int)

    func showNewRecipe()

    func editRecipe(id: UUID)

    func goBack()
}

@MainActor
final class AppNavigation: ObservableObject, AppNavigating {
    @Published var path: [AppRoute] = []

    func showRecipes() {
        path.append(.recipes)
    }

    func showNetworkExamples() {
        path.append(.networkExamples)
    }

    func showProfile() {
        path.append(.profile)
    }

    func showRecipe(id: UUID) {
        path.append(.recipe(id))
    }

    func showRemoteRecipe(id: Int) {
        path.append(.remoteRecipe(id))
    }

    func showNewRecipe() {
        path.append(.newRecipe)
    }

    func editRecipe(id: UUID) {
        path.append(.editRecipe(id))
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
