import SwiftData
import SwiftUI

@MainActor
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        AppContentView(modelContext: modelContext)
    }
}

@MainActor
private struct AppContentView: View {
    @StateObject private var navigation = AppNavigation()
    @StateObject private var dependencies: AppDependencies

    init(modelContext: ModelContext) {
        _dependencies = StateObject(wrappedValue: AppDependencies(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            HomeAssemblyImpl().build(repository: dependencies.recipeRepository, navigator: navigation)
                .navigationDestination(for: AppRoute.self, destination: destination)
        }
        .tint(Color("AccentColor"))
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
            case .recipes:
                RecipeListAssemblyImpl().build(
                    repository: dependencies.recipeRepository,
                    recipeService: dependencies.recipeService,
                    navigator: navigation
                )
            case .networkExamples:
                NetworkExamplesAssemblyImpl().build(service: dependencies.networkExamplesService, navigator: navigation)
            case .profile:
                ProfileAssemblyImpl().build(sessionStore: dependencies.profileSessionStore, navigator: navigation)
            case .recipe(let id):
                RecipeDetailAssemblyImpl().build(
                    id: id,
                    repository: dependencies.recipeRepository,
                    navigator: navigation
                )
            case .remoteRecipe(let id):
                RemoteRecipeDetailAssemblyImpl().build(
                    id: id,
                    recipeService: dependencies.recipeService,
                    navigator: navigation
                )
            case .newRecipe:
                RecipeEditorAssemblyImpl().build(
                    id: nil,
                    repository: dependencies.recipeRepository,
                    recipeService: dependencies.recipeService,
                    navigator: navigation
                )
            case .editRecipe(let id):
                RecipeEditorAssemblyImpl().build(
                    id: id,
                    repository: dependencies.recipeRepository,
                    recipeService: dependencies.recipeService,
                    navigator: navigation
                )
        }
    }
}
