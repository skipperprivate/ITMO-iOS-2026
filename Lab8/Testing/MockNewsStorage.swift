#if DEBUG

@MainActor
final class MockNewsStorage: NewsStorage {
    var news: [News]
    var readError: Error?

    private(set) var saveCount = 0

    init(news: [News] = []) {
        self.news = news
    }

    func load() throws -> [News] {
        if let error = readError {
            throw error
        }

        return news
    }

    func save(_ news: [News]) throws {
        self.news = news
        saveCount += 1
    }
}

#endif
