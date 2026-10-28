import Foundation
import Combine

@MainActor
final class NewsFeedViewModel: ObservableObject {
    @Published private(set) var articles: [NewsArticle] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let getNewsUseCase: any GetNewsUseCase
    
    init(getNewsUseCase: any GetNewsUseCase) {
        self.getNewsUseCase = getNewsUseCase
    }
    
    func loadNews() async {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        
        do {
            articles = try await getNewsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}
