import Combine
import Foundation

@MainActor
final class QuoteDetailViewModel: ObservableObject {

    @Published var quote: Quote?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = QuoteService()

    func loadQuote(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            quote = try await service.fetchQuote(id: id)
        } catch {
            errorMessage = "Не удалось загрузить цитату"
        }

        isLoading = false
    }
}
