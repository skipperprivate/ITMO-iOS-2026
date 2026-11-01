//
//  HomeView.swift
//  RecipeBox
//
//  Created by nktmahov on 12.10.26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let randomRecipe = viewModel.randomRecipe {
                    Section {
                        NavigationLink {
                            RecipeDetailView(recipe: randomRecipe)
                        } label: {
                            RecipeRow(
                                title: randomRecipe.title,
                                imageURL: randomRecipe.imageURL,
                                subtitle: "Случайный рецепт"
                            )
                        }

                        Button("Показать другой", systemImage: "dice") {
                            Task {
                                await viewModel.generateRandomRecipe()
                            }
                        }
                        .disabled(viewModel.isLoading)
                    } header: {
                        Text("Что приготовить?")
                    }
                }

                Section("Рекомендации") {
                    ForEach(viewModel.recommendations) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            RecipeRow(
                                title: recipe.title,
                                imageURL: recipe.imageURL,
                                subtitle: [recipe.category, recipe.area]
                                    .compactMap { $0 }
                                    .joined(separator: " • ")
                            )
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.recommendations.isEmpty {
                    ProgressView("Загружаем рецепты…")
                }
            }
            .navigationTitle("RecipeBox")
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.generateRandomRecipe()
            }
            .alert(
                "Не удалось загрузить рецепты",
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
