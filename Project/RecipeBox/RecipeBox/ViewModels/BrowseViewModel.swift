//
//  BrowseViewModel.swift
//  RecipeBox
//
//  Created by nktmahov on 08.10.26.
//

import Foundation
import Observation

@Observable
final class BrowseViewModel {
    private(set) var recipes: [APIRecipe] = []
    private(set) var isLoading = false
    var searchText = ""
    var errorMessage: String?

    private let service = MealDBService()

    func loadInitialRecipes() async {
        guard recipes.isEmpty else {
            return
        }
        await load { try await service.recipes() }
    }

    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            await loadInitialRecipes()
            return
        }
        await load { try await service.searchRecipes(query: query) }
    }

    private func load(_ operation: () async throws -> [APIRecipe]) async {
        isLoading = true
        defer { isLoading = false }

        do {
            recipes = try await operation()
            if recipes.isEmpty {
                errorMessage = MealDBError.noRecipes.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
