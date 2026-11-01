//
//  MealDBService.swift
//  RecipeBox
//
//  Created by nktmahov on 07.10.26.
//

import Foundation

struct MealDBService {
    // swiftlint:disable:next force_unwrapping
    private let baseURL = URL(string: "https://www.themealdb.com/api/json/v1/1/")!

    func searchRecipes(query: String) async throws -> [APIRecipe] {
        try await request(endpoint: "search.php", queryItems: [
            URLQueryItem(name: "s", value: query)
        ])
    }

    func recipes(startingWith letter: String = "a") async throws -> [APIRecipe] {
        try await request(endpoint: "search.php", queryItems: [
            URLQueryItem(name: "f", value: letter)
        ])
    }

    func randomRecipe() async throws -> APIRecipe {
        guard let recipe = try await request(endpoint: "random.php").first else {
            throw MealDBError.noRecipes
        }
        return recipe
    }

    private func request(
        endpoint: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> [APIRecipe] {
        var components = URLComponents(
            url: baseURL.appending(path: endpoint),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw MealDBError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw MealDBError.invalidResponse
        }

        let responseBody = try JSONDecoder().decode(MealResponse.self, from: data)
        return responseBody.meals?.filter(\.hasUsableImage) ?? []
    }
}

private struct MealResponse: Decodable {
    let meals: [APIRecipe]?
}
