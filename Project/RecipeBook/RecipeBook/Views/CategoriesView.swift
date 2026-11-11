import SwiftUI

struct CategoriesView: View {
    let repository: RecipeRepositoryProtocol
    @State private var recipes: [Recipe] = []

    private var categories: [String] {
        Array(Set(recipes.map(\.cuisine))).sorted()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Категории").font(.largeTitle.bold())
                Text("Выберите кухню и найдите подходящий рецепт.")
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink {
                            List(recipes.filter { $0.cuisine == category }) { recipe in
                                NavigationLink(recipe.name) {
                                    RecipeDetailView(viewModel: RecipeDetailViewModel(
                                        recipeID: recipe.id, repository: repository))
                                }
                            }
                            .navigationTitle(category)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Image(systemName: "fork.knife")
                                    .font(.title2).foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(AppTheme.gradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 13))
                                Text(category)
                                    .font(.headline).foregroundStyle(.primary)
                                Text("Смотреть рецепты")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.background)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }.padding()
        }
        .background(AppTheme.background)
        .navigationTitle("")
        .task {
            if recipes.isEmpty {
                recipes = (try? await repository.fetchRecipes()) ?? []
            }
        }
    }
}
