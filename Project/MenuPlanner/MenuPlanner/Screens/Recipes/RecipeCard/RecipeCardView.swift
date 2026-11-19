import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AppColors.warmSoft
                .frame(height: 102)
                .overlay {
                    RecipeImageView(data: recipe.photoData)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .topTrailing) {
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.warm)
                            .padding(8)
                            .background(AppColors.surface, in: Circle())
                            .padding(6)
                    }
                }

            Text(recipe.name)
                .font(AppFonts.strong)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 24, alignment: .leading)

            Text("\(recipe.durationMinutes) мин / \(RecipeFormatting.count(recipe.ingredients.count, one: "продукт", few: "продукта", many: "продуктов"))")
                .font(AppFonts.small)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 182, alignment: .topLeading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
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

    RecipeCardView(recipe: recipe)
        .frame(width: 170)
        .padding(16)
        .background(AppColors.background)
}

