import Foundation
import Testing
@testable import MiniTwitter

struct TwitterAPIClientTests {
    @Test("GET формирует запрос и разбирает твиты из JSON")
    func fetchPostsDecodesResponse() async throws {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        let client = TwitterAPIClient(baseURL: URL(string: "https://success.test")!, session: session)

        let page = try await client.fetchPosts(page: 2, pageSize: 1)

        #expect(page.page == 2)
        #expect(page.pageSize == 1)
        #expect(page.total == 3)
        #expect(page.hasNextPage)
        #expect(page.items.count == 1)
        let post = try #require(page.items.first)
        #expect(post.id == UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        #expect(post.authorUsername == "anna")
        #expect(post.authorDisplayName == "Анна")
        #expect(post.text == "Тестовый твит")
        #expect(post.publishedAt == Date(timeIntervalSince1970: 0))
        #expect(post.likes == 7)
    }

    @Test("HTTP 500 преобразуется в TwitterAPIError.http(500)")
    func fetchPostsReportsServerError() async {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        let client = TwitterAPIClient(baseURL: URL(string: "https://server-error.test")!, session: session)

        await #expect(throws: TwitterAPIError.http(500)) {
            try await client.fetchPosts(page: 2, pageSize: 1)
        }
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [PostsURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

private final class PostsURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url,
              request.httpMethod == "GET",
              url.path == "/api/posts",
              request.value(forHTTPHeaderField: "Accept") == "application/json",
              let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              query.count == 2,
              query.contains(URLQueryItem(name: "page", value: "2")),
              query.contains(URLQueryItem(name: "pageSize", value: "1")),
              ["success.test", "server-error.test"].contains(url.host ?? "") else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        let isError = url.host == "server-error.test"
        let body = isError ? "Internal Server Error" : """
        {
            "page": 2,
            "pageSize": 1,
            "total": 3,
            "items": [{
                "id": "11111111-1111-1111-1111-111111111111",
                "authorUsername": "anna",
                "authorDisplayName": "Анна",
                "text": "Тестовый твит",
                "publishedAt": "1970-01-01T00:00:00Z",
                "likes": 7
            }]
        }
        """
        let response = HTTPURLResponse(url: url, statusCode: isError ? 500 : 200,
                                       httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}
