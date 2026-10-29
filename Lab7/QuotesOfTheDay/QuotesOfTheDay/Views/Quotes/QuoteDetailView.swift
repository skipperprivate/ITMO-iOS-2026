import SwiftUI

struct QuoteDetailView: View {

    let quoteID: Int

    @StateObject private var viewModel = QuoteDetailViewModel()

    var body: some View {
        VStack(spacing: 24) {

            if viewModel.isLoading {
                ProgressView()

            } else if let quote = viewModel.quote {

                Text("“\(quote.quote)”")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                Text(quote.author)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("ID: \(quote.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .padding()
        .navigationTitle("Цитата")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadQuote(id: quoteID)
        }
    }
}

#Preview {
    QuoteDetailView(quoteID: 1)
}
