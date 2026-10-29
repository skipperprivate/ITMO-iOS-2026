import SwiftUI
import SwiftData

struct FavoritesView: View {

    @Query(
        filter: #Predicate<SavedQuote> { quote in
            quote.isFavorite == true
        },
        sort: \SavedQuote.createdAt,
        order: .reverse
    )
    private var favorites: [SavedQuote]

    var body: some View {
        NavigationStack {
            List {
                ForEach(favorites) { quote in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("“\(quote.text)”")
                            .font(.headline)

                        Text(quote.author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteQuotes)
            }
            .navigationTitle("Избранное")
        }
    }

    private func deleteQuotes(at offsets: IndexSet) {
        for index in offsets {
            favorites[index].isFavorite = false
        }
    }
}

#Preview {
    FavoritesView()
}
