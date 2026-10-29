import SwiftUI
import SwiftData

struct HistoryView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<SavedQuote> { quote in
            quote.isInHistory == true
        },
        sort: \SavedQuote.createdAt,
        order: .reverse
    )
    private var history: [SavedQuote]

    var body: some View {
        NavigationStack {
            List {
                ForEach(history) { quote in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("“\(quote.text)”")
                            .font(.headline)

                        Text(quote.author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(quote.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteHistory)
            }
            .navigationTitle("История")
        }
    }

    private func deleteHistory(at offsets: IndexSet) {
        for index in offsets {
            let quote = history[index]

            quote.isInHistory = false

            if quote.isFavorite == false {
                modelContext.delete(quote)
            }
        }
    }
}

#Preview {
    HistoryView()
}
