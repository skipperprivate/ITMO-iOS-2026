import SwiftUI

struct RecipeListRow: View {
    let recipe: RecipeRowState
    let isFavorite: Bool
    let onOpen: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onOpen) {
                recipeDescription
            }
            .buttonStyle(.plain)

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(isFavorite ? "Убрать из избранного" : "В избранное")
        }
    }

    private var recipeDescription: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(recipe.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(recipe.ingredientSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }
}
