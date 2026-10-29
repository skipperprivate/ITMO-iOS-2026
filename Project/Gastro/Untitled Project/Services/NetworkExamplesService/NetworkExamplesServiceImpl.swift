import Foundation

actor NetworkExamplesServiceImpl: NetworkExamplesService {
    private let networkClient: any NetworkClient

    init(networkClient: any NetworkClient) {
        self.networkClient = networkClient
    }

    func perform(_ example: NetworkExample) async throws -> String {
        if example == .publish {
            let draft = RecipeDraft(
                title: "Учебный рецепт",
                ingredients: ["Яйца — 2", "Молоко — 50 мл"],
                steps: ["Смешать ингредиенты", "Приготовить на сковороде"],
                cookingTimeMinutes: 10
            )
            let response = try await networkClient.send(request: RecipeRequests.publish(draft: draft))
            return "Рецепт «\(response.name)» принят. ID: \(response.id). DummyJSON не сохраняет его на сервере."
        }
        // These are real POST requests; DummyJSON generates the requested HTTP status.
        let request = NetworkRequest<NetworkExampleResponse>(
            path: "http/\(example.rawValue)",
            method: .post,
            body: Data("{}".utf8)
        )
        let response = try await networkClient.send(request: request)
        return response.message
    }
}
