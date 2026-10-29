import SwiftUI

struct QuotesView: View {

    @StateObject private var viewModel = QuotesViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.quotes) { quote in
                NavigationLink {
                    QuoteDetailView(quoteID: quote.id)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("“\(quote.quote)”")
                            .font(.headline)
                            .lineLimit(3)

                        Text(quote.author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .task {
                    await viewModel.loadMoreIfNeeded(
                        currentQuote: quote
                    )
                }
            }
            .navigationTitle("Все цитаты")
            .task {
                if viewModel.quotes.isEmpty {
                    await viewModel.loadQuotes()
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.quotes.isEmpty {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    QuotesView()
}
