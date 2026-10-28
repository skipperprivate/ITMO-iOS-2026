// Сейчас это избыточно, но потом тут будет уже бизнес логика
// например получене новостей, удаление источника и тд

protocol GetNewsUseCase: Sendable {
    func execute() async throws -> [NewsArticle]
}

struct DefaultGetNewsUseCase: GetNewsUseCase {
    private let repository: any NewsRepository
    
    init(repository: any NewsRepository) {
        self.repository = repository
    }
    func execute() async throws -> [NewsArticle] {
        try await repository.getNews()
    }
}
