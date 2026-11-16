import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    private var recipe: Recipe { viewModel.recipe }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecipeDetailViewModel
    @State private var isEditing = false
    @State private var isConfirmingDeletion = false

    init(recipe: Recipe) {
        _viewModel = State(initialValue: RecipeDetailViewModel(recipe: recipe))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                AppColors.warmSoft
                    .frame(height: 174)
                    .overlay {
                        RecipeImageView(data: recipe.photoData)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                Text(recipe.name)
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    Label {
                        Text("\(recipe.durationMinutes) мин")
                            .font(AppFonts.smallStrong)
                    } icon: {
                        Image("RecipeClock").renderingMode(.template)
                    }
                    .foregroundStyle(AppColors.secondaryText)

                    RecipeStepper(
                        title: RecipeFormatting.count(viewModel.servings, one: "порция", few: "порции", many: "порций"),
                        value: $viewModel.servings, range: 1...100
                    )
                    .font(AppFonts.strong)
                    .foregroundStyle(AppColors.primaryText)
                    .padding(8)
                    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 20))
                }

                Text("Ингредиенты")
                    .font(AppFonts.section)
                    .foregroundStyle(AppColors.primaryText)
                    .padding(.top, 4)

                VStack(spacing: 0) {
                    ForEach(recipe.ingredients) { ingredient in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(ingredient.ingredient.name)
                                .font(AppFonts.body)
                                .foregroundStyle(AppColors.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(viewModel.quantity(for: ingredient, recipe: recipe))
                                .font(AppFonts.smallStrong)
                                .foregroundStyle(AppColors.secondaryText)
                                .multilineTextAlignment(.trailing)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(minHeight: 34)
                    }
                }

                Label {
                    Text("Количество продуктов изменится вместе с порциями")
                        .font(AppFonts.micro)
                } icon: {
                    Image("RecipeLeaf").renderingMode(.template)
                }
                .foregroundStyle(AppColors.accent)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.accentSoft, in: RoundedRectangle(cornerRadius: 12))

                if !recipe.recipeDescription.isEmpty {
                    Text("Заметки")
                        .font(AppFonts.section)
                        .foregroundStyle(AppColors.primaryText)
                        .padding(.top, 8)
                    Text(recipe.recipeDescription)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .customTabBarHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFavorite(recipe, in: modelContext)
                } label: {
                    Image("RecipeHeart")
                        .renderingMode(.template)
                        .foregroundStyle(recipe.isFavorite ? AppColors.warm : AppColors.accent)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Действия", systemImage: "ellipsis") {
                    Button("Редактировать", systemImage: "pencil") { isEditing = true }
                    Button("Удалить рецепт", systemImage: "trash", role: .destructive) {
                        isConfirmingDeletion = true
                    }
                }
            }
        }
        .tint(AppColors.accent)
        .onAppear { viewModel.refresh(in: modelContext) }
        .sheet(isPresented: $isEditing, onDismiss: { viewModel.refresh(in: modelContext) }) {
            RecipeEditorView(recipe: recipe)
        }
        .confirmationDialog("Удалить рецепт?", isPresented: $isConfirmingDeletion, titleVisibility: .visible) {
            Button("Удалить рецепт", role: .destructive) {
                if viewModel.delete(recipe, in: modelContext) { dismiss() }
            }
            Button("Отмена", role: .cancel) { }
        }
        .alert("Не удалось сохранить изменения", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Понятно", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview("Карточка рецепта", traits: .sizeThatFitsLayout) {
    let recipe = Recipe(
        name: "Лосось с рисом",
        recipeDescription: "Запечённый лосось с рисом и свежим огурцом.",
        durationMinutes: 30,
        baseServings: 2,
        ingredients: [
            RecipeIngredient(ingredient: Ingredient(name: "Лосось"), quantity: 300, unit: .gram),
            RecipeIngredient(ingredient: Ingredient(name: "Рис"), quantity: 160, unit: .gram),
            RecipeIngredient(ingredient: Ingredient(name: "Огурец"), quantity: 1, unit: .piece)
        ],
        photoData: UIImage(named: "Salmon")?.pngData(),
        isFavorite: true
    )

    RecipeDetailView(recipe: recipe)
        .background(AppColors.background)
}

