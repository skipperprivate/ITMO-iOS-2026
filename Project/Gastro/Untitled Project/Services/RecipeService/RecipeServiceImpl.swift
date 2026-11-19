import Foundation

actor RecipeServiceImpl: RecipeService {
    private let networkClient: any NetworkClient

    init(networkClient: any NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchRecipes() async throws -> [RemoteRecipe] {
        let response = try await networkClient.send(request: RecipeRequests.list())
        return response.recipes.map { $0.recipe }
    }

    func fetchRecipe(id: Int) async throws -> RemoteRecipe {
        let response = try await networkClient.send(request: RecipeRequests.details(id: id))
        return response.recipe
    }

    func publishRecipe(_ draft: RecipeDraft) async throws -> PublishedRecipe {
        let request = try RecipeRequests.publish(draft: draft)
        let response = try await networkClient.send(request: request)
        return PublishedRecipe(id: response.id, name: response.name)
    }
}
