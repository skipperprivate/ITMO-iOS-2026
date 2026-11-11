import Foundation

protocol RecipeAPIProtocol {
    func fetchRecipes() async throws -> [Recipe]
    func fetchRecipe(id: Int) async throws -> Recipe
    func addRecipeToServer(_ recipe: Recipe) async throws -> Recipe
}

enum APIError: LocalizedError {
    case invalidURL
    case serverError(Int)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Некорректный URL."
        case .serverError(let code): return "Ошибка сервера: \(code)."
        case .invalidData: return "Не удалось обработать ответ сервера."
        }
    }
}

final class RecipeAPI: RecipeAPIProtocol {
    private let session: URLSession
    private let baseURL = "https://dummyjson.com"

    init(session: URLSession = .shared) { self.session = session }

    func fetchRecipes() async throws -> [Recipe] {
        guard let url = URL(string: "\(baseURL)/recipes?limit=100") else {
            throw APIError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        try validate(response)
        guard let result = try? JSONDecoder().decode(RecipesResponse.self, from: data)
        else { throw APIError.invalidData }
        return result.recipes
    }

    func fetchRecipe(id: Int) async throws -> Recipe {
        guard let url = URL(string: "\(baseURL)/recipes/\(id)") else {
            throw APIError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        try validate(response)
        guard let recipe = try? JSONDecoder().decode(Recipe.self, from: data)
        else { throw APIError.invalidData }
        return recipe
    }
    
    func addRecipeToServer(_ recipe: Recipe) async throws -> Recipe {
        guard let url = URL(string: "\(baseURL)/recipes/add") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        
        do {
            request.httpBody = try encoder.encode(recipe)
        } catch {
            throw APIError.invalidData
        }

        let (data, response) = try await session.data(for: request)
        try validate(response)

        guard let newRecipe = try? JSONDecoder().decode(Recipe.self, from: data) else {
            throw APIError.invalidData
        }

        return newRecipe
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidData
        }
        guard 200..<300 ~= http.statusCode else {
            throw APIError.serverError(http.statusCode)
        }
    }
}
