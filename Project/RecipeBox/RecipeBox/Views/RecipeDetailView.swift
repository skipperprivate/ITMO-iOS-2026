//
//  RecipeDetailView.swift
//  RecipeBox
//
//  Created by nktmahov on 14.10.26.
//

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteRecipe]

    let recipe: APIRecipe

    private var favorite: FavoriteRecipe? {
        favorites.first { favorite in
            favorite.apiID == recipe.id
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                RemoteRecipeImage(imageURL: recipe.imageURL, height: 280)
                RecipeMetadataView(
                    title: recipe.title,
                    category: recipe.category,
                    area: recipe.area
                )

                if !recipe.ingredients.isEmpty {
                    IngredientListView(ingredients: recipe.ingredients)
                }

                RecipeInstructionsView(instructions: recipe.instructions)
            }
            .padding(.bottom)
        }
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Label(
                        favorite == nil ? "В понравившиеся" : "Удалить из понравившихся",
                        systemImage: favorite == nil ? "heart" : "heart.fill"
                    )
                }
            }
        }
    }

    private func toggleFavorite() {
        if let favorite {
            modelContext.delete(favorite)
        } else {
            modelContext.insert(FavoriteRecipe(recipe: recipe))
        }
    }
}
