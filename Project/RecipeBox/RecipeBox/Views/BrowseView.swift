//
//  BrowseView.swift
//  RecipeBox
//
//  Created by nktmahov on 12.10.26.
//

import SwiftUI

struct BrowseView: View {
    @State private var viewModel = BrowseViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.recipes) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    RecipeRow(
                        title: recipe.title,
                        imageURL: recipe.imageURL,
                        subtitle: [recipe.category, recipe.area]
                            .compactMap { $0 }
                            .joined(separator: " - ")
                    )
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.recipes.isEmpty {
                    ContentUnavailableView(
                        "Рецепты не найдены",
                        systemImage: "fork.knife",
                        description: Text("Попробуйте изменить поисковый запрос.")
                    )
                }
            }
            .navigationTitle("Рецепты")
            .searchable(text: $viewModel.searchText, prompt: "Название блюда")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.search()
                }
            }
            .task {
                await viewModel.loadInitialRecipes()
            }
            .alert(
                "Ошибка",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("ОК") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
