import SwiftUI

struct RecipeDetailView: View {
    @StateObject private var vm: RecipeDetailViewModel

    init(viewModel: RecipeDetailViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if let recipe = vm.recipe {
                VStack(alignment: .leading, spacing: 20) {
                    AsyncRecipeImage(url: recipe.image, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(recipe.name).font(.largeTitle.bold())
                        Text(recipe.cuisineText).font(.headline).foregroundStyle(AppTheme.accent)
                    }.padding(.horizontal)

                    HStack {
                        InfoItem(icon: "clock", title: "Время", value: "\(recipe.totalTime) мин")
                        InfoItem(icon: "person.2", title: "Порции", value: "\(recipe.servings)")
                        InfoItem(icon: "flame", title: "Ккал", value: "\(recipe.caloriesPerServing)")
                    }.padding(.horizontal)

                    Button {
                        vm.toggleFavorite()
                    } label: {
                        Label(vm.isFavorite ? "В избранном" : "Добавить в избранное",
                              systemImage: vm.isFavorite ? "heart.fill" : "heart")
                            .font(.headline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(AppTheme.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }.padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ингредиенты").font(.title2.bold())
                        ForEach(recipe.ingredients, id: \.self) { item in
                            Label(item, systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.primary)
                        }
                    }.padding(.horizontal)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Приготовление").font(.title2.bold())
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline).foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(AppTheme.accent).clipShape(Circle())
                                Text(step)
                            }
                        }
                    }.padding(.horizontal)
                }.padding(.vertical)
            } else {
                ProgressView("Загрузка...")
                    .frame(maxWidth: .infinity, minHeight: 500)
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Рецепт")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
    }
}

private struct InfoItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(AppTheme.accent)
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 13)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
