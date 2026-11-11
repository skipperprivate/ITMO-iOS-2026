import SwiftUI

struct RecipeCard<Destination: View>: View {

    let recipe: Recipe
    let isFavorite: Bool
    let onFavorite: () -> Void
    let destination: () -> Destination

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                NavigationLink {
                    destination()
                } label: {
                    AsyncRecipeImage(url: recipe.image, height: 180)
                }
                .buttonStyle(.plain)

                Button {
                    onFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? AppTheme.accent : .primary)
                        .frame(width: 42, height: 42)
                        .background(.ultraThinMaterial)
                        .accessibilityIdentifier("favoriteButton_\(recipe.id)")
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(10)
                .contentShape(Circle())
                .zIndex(1)
            }
            .frame(height: 180)

            NavigationLink {
                destination()
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(recipe.cuisineText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Label("\(recipe.totalTime) мин", systemImage: "clock")
                        Spacer()
                        Text(recipe.difficultyText)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 280)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
