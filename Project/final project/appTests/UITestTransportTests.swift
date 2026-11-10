#if !SWIFT_PACKAGE
@testable import app
import XCTest

@MainActor
final class UITestTransportTests: XCTestCase {
    func testTransportSupportsLoadingAndPublishing() async throws {
        let client = NewsAPIClient(transport: UITestTransport(failFirstRequest: false))
        let articles = try await client.fetchArticles()
        XCTAssertEqual(articles.count, 1)
        XCTAssertEqual(articles.first?.id, "dummyjson:101")

        let post = try await client.create(NewPost(title: "Мой заголовок", body: "Мой текст", userId: 1))
        XCTAssertEqual(post.id, 251)
        XCTAssertEqual(post.title, "Мой заголовок")
        XCTAssertEqual(post.body, "Мой текст")
        XCTAssertEqual(post.authorID, 1)
    }
}
#endif
