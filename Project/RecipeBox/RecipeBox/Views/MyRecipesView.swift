//
//  MyRecipesView.swift
//  RecipeBox
//
//  Created by nktmahov on 13.10.26.
//

import SwiftUI
import SwiftData

struct MyRecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserRecipe.updatedAt, order: .reverse)
    private var recipes: [UserRecipe]
    @State private var isCreatingRecipe = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink {
                        UserRecipeDetailView(recipe: recipe)
                    } label: {
                        UserRecipeRow(
                            title: recipe.title,
                            description: recipe.recipeDescription,
                            imageData: recipe.imageData
                        )
                    }
                }
                .onDelete(perform: delete)
            }
            .overlay {
                if recipes.isEmpty {
                    ContentUnavailableView(
                        "Рецептов нет",
                        systemImage: "book.closed",
                        description: Text("Создайте первый рецепт кнопкой +")
                    )
                }
            }
            .navigationTitle("Мои рецепты")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Создать рецепт", systemImage: "plus") {
                        isCreatingRecipe = true
                    }
                }
            }
            .sheet(isPresented: $isCreatingRecipe) {
                NavigationStack {
                    RecipeEditorView(recipe: nil)
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
    }
}
