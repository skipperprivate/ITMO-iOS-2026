import SwiftUI

struct RecipeSwipeCard: View {
    let recipe: RecipeRowState
    let isFavorite: Bool
    let onOpen: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Рецепт от Gastro")
                .font(.caption)
                .foregroundStyle(.secondary)

            recipeImage
            recipeDescription
            actions
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.035), radius: 18, y: 8)
    }

    private var recipeImage: some View {
        AsyncImage(url: recipe.image) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Color.green.opacity(0.08)
                Image(systemName: "fork.knife")
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(.green)
            }
        }
        .frame(width: 170, height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 58))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityHidden(true)
    }

    private var recipeDescription: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.headline)
                .lineLimit(3)
            Text(recipe.ingredientSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            if let minutes = recipe.cookingTimeMinutes {
                Label("\(minutes) мин", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actions: some View {
        HStack {
            Button(action: onOpen) {
                Label("Посмотреть рецепт", systemImage: "book.fill")
                    .font(.subheadline.weight(.medium))
                    .padding(14)
                    .background(Color.green.opacity(0.06), in: Capsule())
            }
            .accessibilityIdentifier("recipes.openCard")
            Spacer(minLength: 4)
            Button(action: onFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .padding(14)
                    .background(Color.green.opacity(0.06), in: Circle())
            }
            .accessibilityLabel("В избранное")
        }
        .foregroundStyle(.green)
        .buttonStyle(.plain)
    }
}
