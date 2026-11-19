import Foundation

nonisolated enum RecipeRequests {
    static func list() -> NetworkRequest<RecipesResponse> {
        NetworkRequest(
            path: "recipes",
            method: .get,
            queryItems: [URLQueryItem(name: "limit", value: "0")]
        )
    }

    static func details(id: Int) -> NetworkRequest<RecipeResponse> {
        NetworkRequest(path: "recipes/\(id)", method: .get)
    }

    static func publish(draft: RecipeDraft) throws -> NetworkRequest<PublishRecipeResponse> {
        let body = PublishRecipeRequestBody(
            name: draft.title,
            ingredients: draft.ingredients,
            instructions: draft.steps,
            cookTimeMinutes: draft.cookingTimeMinutes
        )
        return NetworkRequest(
            path: "recipes/add",
            method: .post,
            body: try JSONEncoder().encode(body)
        )
    }
}
