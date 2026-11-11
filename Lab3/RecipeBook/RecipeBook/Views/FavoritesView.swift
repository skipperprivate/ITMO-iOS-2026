import SwiftUI

struct FavoritesView: View {
    let repository: RecipeRepositoryProtocol

    @State private var favorites: [Recipe] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Загрузка...")
            } else if let errorMessage {
                ContentUnavailableView(
                    "Не удалось загрузить",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if favorites.isEmpty {
                ContentUnavailableView(
                    "Избранное пусто",
                    systemImage: "heart",
                    description: Text(
                        "Нажмите на сердечко у рецепта, чтобы сохранить его."
                    )
                )
            } else {
                List(favorites) { recipe in
                    NavigationLink {
                        RecipeDetailView(
                            viewModel: RecipeDetailViewModel(
                                recipeID: recipe.id,
                                repository: repository
                            )
                        )
                    } label: {
                        HStack(spacing: 12) {
                            AsyncRecipeImage(
                                url: recipe.image,
                                height: 72
                            )
                            .frame(width: 88)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )

                            VStack(alignment: .leading, spacing: 5) {
                                Text(recipe.name)
                                    .font(.headline)

                                Text(recipe.cuisineText)
                                    .foregroundStyle(.secondary)

                                Text(recipe.difficultyText)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.accent)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Избранное")
        .onAppear {
            Task {
                await loadFavorites()
            }
        }
        .refreshable {
            await loadFavorites()
        }
    }

    private func loadFavorites() async {
        isLoading = true
        errorMessage = nil

        do {
            let recipes = try await repository.fetchRecipes()
            let favoriteIDs = try repository.favoriteIDs()

            favorites = recipes.filter {
                favoriteIDs.contains($0.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
