protocol NewsRepository: Sendable {
    func getNews() async throws -> [NewsArticle]
}
