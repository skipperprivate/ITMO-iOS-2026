//
//  HomeViewModel.swift
//  RecipeBox
//
//  Created by nktmahov on 08.10.26.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    private(set) var recommendations: [APIRecipe] = []
    private(set) var randomRecipe: APIRecipe?
    private(set) var isLoading = false
    var errorMessage: String?

    private let service = MealDBService()

    func load() async {
        guard recommendations.isEmpty else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            async let loadedRecommendations = service.recipes()
            async let loadedRandomRecipe = service.randomRecipe()

            recommendations = Array(try await loadedRecommendations.prefix(8))
            randomRecipe = try await loadedRandomRecipe
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generateRandomRecipe() async {
        isLoading = true
        defer { isLoading = false }

        do {
            randomRecipe = try await service.randomRecipe()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
