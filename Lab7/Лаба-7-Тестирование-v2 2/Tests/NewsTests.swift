import XCTest
import SwiftData
@testable import NewsLabCore

private struct StubTransport: HTTPTransport {
    let status: Int
    let body: String
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.host, "dummyjson.com")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.path, "/posts")
        let query = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems
        XCTAssertEqual(query?.first(where: { $0.name == "limit" })?.value, "30")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        return (Data(body.utf8), HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!)
    }
}

private struct FailingNews: NewsFetching {
    func fetchArticles() async throws -> [RemoteArticle] { throw URLError(.notConnectedToInternet) }
}
private struct FixedNews: NewsFetching {
    let articles: [RemoteArticle]
    func fetchArticles() async throws -> [RemoteArticle] { articles }
}
private struct CancelledTransport: HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) { throw URLError(.cancelled) }
}

@MainActor
final class NewsTests: XCTestCase {
    func testDecodeBodyAndDeduplicate() async throws {
        let json = #"{"posts":[{"id":1,"title":"Swift","body":"Full article text","userId":1,"tags":["technology"]},{"id":1,"title":"Duplicate","body":"Same ID","userId":1},{"id":3,"title":"News","body":"Another article","userId":2}]}"#
        let result = try await NewsAPIClient(transport: StubTransport(status: 200, body: json)).fetchArticles()
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].title, "Swift")
        XCTAssertEqual(result[0].body, "Full article text")
        XCTAssertEqual(result[1].id, "dummyjson:3")
    }

    func testHTTPErrorBeforeJSONDecoding() async {
        do {
            _ = try await NewsAPIClient(transport: StubTransport(status: 503, body: "unavailable")).fetchArticles()
            XCTFail("Expected HTTP error")
        } catch NewsAPIError.httpStatus(let status) { XCTAssertEqual(status, 503) }
        catch { XCTFail("Unexpected: \(error)") }
    }

    func testMalformedJSON() async {
        do {
            _ = try await NewsAPIClient(transport: StubTransport(status: 200, body: "{}")).fetchArticles()
            XCTFail("Expected decoding error")
        } catch NewsAPIError.invalidData {} catch { XCTFail("Unexpected: \(error)") }
    }

    func testEmptyResponse() async throws {
        let result = try await NewsAPIClient(transport: StubTransport(status: 200, body: #"{"posts":[]}"#)).fetchArticles()
        XCTAssertTrue(result.isEmpty)
    }

    func testTransportCancellationPropagates() async {
        do {
            _ = try await NewsAPIClient(transport: CancelledTransport()).fetchArticles()
            XCTFail("Expected cancellation")
        } catch let error as URLError { XCTAssertEqual(error.code, .cancelled) }
        catch { XCTFail("Unexpected: \(error)") }
    }

    func testStatisticsCountsUnicodeAndWhitespace() async throws {
        var progress: [Double] = []
        let result = try await NewsStatisticsService().calculate(texts: ["Привет, мир!", "a\nb", "👨‍👩‍👧‍👦"]) { progress.append($0) }
        XCTAssertEqual(result, NewsStatisticsResult(articles: 3, words: 5, characters: 16))
        XCTAssertEqual(progress.last, 1)
        XCTAssertEqual(progress, progress.sorted())
    }

    func testEmptyStatistics() async throws {
        let result = try await NewsStatisticsService().calculate(texts: []) { _ in }
        XCTAssertEqual(result, NewsStatisticsResult(articles: 0, words: 0, characters: 0))
    }

    func testStatisticsCancellation() async {
        let task = Task {
            try Task.checkCancellation()
            return try await NewsStatisticsService().calculate(texts: [String(repeating: "word ", count: 100_000)]) { _ in }
        }
        task.cancel()
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch is CancellationError {} catch { XCTFail("Unexpected: \(error)") }
    }

    private func container() throws -> ModelContainer {
        try ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
    private func article(title: String = "Remote") -> RemoteArticle {
        RemoteArticle(id: "dummyjson:42", title: title, body: "Full article text", authorID: 1, tags: ["technology"])
    }

    func testMergeUpdatesWithoutDuplicatesAndPreservesLocalArticles() throws {
        let storage = try container()
        let repository = NewsRepository(context: storage.mainContext)
        try repository.save(item: nil, title: "Local", text: "My text", source: "Me", category: "Общее")
        try repository.merge([article(), article()])
        try repository.merge([article(title: "Updated")])
        let saved = try repository.fetch()
        XCTAssertEqual(saved.count, 2)
        XCTAssertEqual(saved.first(where: { $0.remoteID == "dummyjson:42" })?.title, "Updated")
        XCTAssertEqual(saved.first(where: { $0.remoteID == nil })?.text, "My text")
    }

    func testOfflineRefreshKeepsSavedFeed() async throws {
        let storage = try container()
        let repository = NewsRepository(context: storage.mainContext)
        try repository.merge([article()])
        let model = NewsFeedViewModel(repository: repository, newsService: FailingNews())
        await model.load()
        XCTAssertEqual(model.items.count, 1)
        XCTAssertNotNil(model.networkMessage)
        XCTAssertFalse(model.isRefreshing)
    }

    func testRefreshPersistsAndInvalidatesStatistics() async throws {
        let storage = try container()
        let repository = NewsRepository(context: storage.mainContext)
        let model = NewsFeedViewModel(repository: repository, newsService: FixedNews(articles: [article()]))
        await model.refresh()
        await model.refresh()
        XCTAssertEqual(model.items.count, 1)
        XCTAssertEqual(try repository.fetch().count, 1)
        XCTAssertEqual(model.statistics.texts, [article().body])
        XCTAssertFalse(model.isRefreshing)
    }

    func testCancelledRefreshDoesNotShowFailure() async throws {
        let storage = try container()
        let model = NewsFeedViewModel(repository: NewsRepository(context: storage.mainContext), newsService: NewsAPIClient(transport: CancelledTransport()))
        await model.refresh()
        XCTAssertNil(model.networkMessage)
        XCTAssertFalse(model.isRefreshing)
    }

    func testSearchCaseInsensitive() async throws {
        let result = try await NewsSearchService().search(documents: [NewsSearchDocument(title: "Swift", text: "News"), NewsSearchDocument(title: "Other", text: "text")], query: " swift ")
        XCTAssertEqual(result.indices, [0])
    }
}
