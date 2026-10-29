import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var quote: Quote?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var postMessage: String?

    private let service = QuoteService()
    private let postService = PostService()

    func loadQuote() async {
        isLoading = true
        errorMessage = nil

        do {
            quote = try await service.fetchRandomQuote()
        } catch {
            errorMessage = "Не удалось загрузить цитату"
        }

        isLoading = false
    }

    func sendQuote() async {
        guard let quote else {
            return
        }

        do {
            let post = try await postService.sendQuote(quote)

            postMessage = "Цитата отправлена. ID: \(post.id ?? 0)"
        } catch {
            postMessage = "Не удалось отправить цитату"
        }
    }
}
