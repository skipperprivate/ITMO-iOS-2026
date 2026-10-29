import Combine
import Foundation

@MainActor
final class QuotesViewModel: ObservableObject {

    @Published var quotes: [Quote] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: QuoteServiceProtocol

    private let limit = 10
    private var skip = 0
    private var total = 0

    init(service: QuoteServiceProtocol) {
        self.service = service
    }

    init() {
        self.service = QuoteService()
    }

    func loadQuotes() async {
        guard isLoading == false else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.fetchQuotes(
                limit: limit,
                skip: skip
            )

            quotes.append(contentsOf: response.quotes)

            total = response.total
            skip += response.quotes.count

        } catch {
            errorMessage = "Не удалось загрузить цитаты"
        }

        isLoading = false
    }

    func loadMoreIfNeeded(currentQuote: Quote) async {
        guard currentQuote.id == quotes.last?.id else {
            return
        }

        guard quotes.count < total else {
            return
        }

        await loadQuotes()
    }
}
