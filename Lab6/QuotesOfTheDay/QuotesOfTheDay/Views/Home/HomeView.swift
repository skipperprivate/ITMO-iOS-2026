import SwiftUI
import SwiftData

struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                if viewModel.isLoading {
                    ProgressView()
                } else if let quote = viewModel.quote {

                    Text("“\(quote.quote)”")
                        .font(.title2)
                        .multilineTextAlignment(.center)

                    Text(quote.author)
                        .font(.headline)

                } else if let errorMessage = viewModel.errorMessage {

                    Text(errorMessage)

                } else {

                    Text("Цитата пока не загружена")
                }

                Button("Новая цитата") {
                    Task {
                        await viewModel.loadQuote()
                        
                        if let quote = viewModel.quote {
                                    saveToHistory(quote)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                
                Button("Отправить цитату") {
                    Task {
                        await viewModel.sendQuote()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.quote == nil)
                
                if let postMessage = viewModel.postMessage {
                    Text(postMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Button("Добавить в избранное") {
                    saveToFavorites()
                }
                .disabled(viewModel.quote == nil)
            }
            .padding()
            .navigationTitle("Цитата дня")
        }
        .task {
            await viewModel.loadQuote()
            
            if let quote = viewModel.quote {
                    saveToHistory(quote)
            }
        }
    }
    
    private func saveToFavorites() {
        guard let quote = viewModel.quote else {
            return
        }

        let quoteID = quote.id

        let descriptor = FetchDescriptor<SavedQuote>(
            predicate: #Predicate { savedQuote in
                savedQuote.id == quoteID
            }
        )

        do {
            let existingQuotes = try modelContext.fetch(descriptor)

            if let existingQuote = existingQuotes.first {
                existingQuote.isFavorite = true
            } else {
                let savedQuote = SavedQuote(
                    id: quote.id,
                    text: quote.quote,
                    author: quote.author,
                    isFavorite: true
                )

                modelContext.insert(savedQuote)
            }
        } catch {
            print("Ошибка сохранения в избранное: \(error)")
        }
    }
    
    private func saveToHistory(_ quote: Quote) {
        let savedQuote = SavedQuote(
            id: quote.id,
            text: quote.quote,
            author: quote.author,
            isFavorite: false
        )

        modelContext.insert(savedQuote)
    }
}
