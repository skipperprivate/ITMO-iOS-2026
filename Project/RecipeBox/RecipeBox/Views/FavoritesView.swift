//
//  FavoritesView.swift
//  RecipeBox
//
//  Created by nktmahov on 13.10.26.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteRecipe.savedAt, order: .reverse)
    private var favorites: [FavoriteRecipe]

    var body: some View {
        NavigationStack {
            List {
                ForEach(favorites) { favorite in
                    NavigationLink {
                        RecipeDetailView(recipe: favorite.apiRecipe)
                    } label: {
                        RecipeRow(
                            title: favorite.title,
                            imageURL: favorite.imageURLString.flatMap(URL.init(string:)),
                            subtitle: favorite.category
                        )
                    }
                }
                .onDelete(perform: delete)
            }
            .overlay {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "Рецептов нет",
                        systemImage: "heart",
                        description: Text("Понравившиеся рецепты будут отображены тут")
                    )
                }
            }
            .navigationTitle("Понравившиеся")
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(favorites[index])
        }
    }
}
