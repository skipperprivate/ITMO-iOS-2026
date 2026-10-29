import Foundation

nonisolated final class RequestRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var requests: [URLRequest] = []

    func record(_ request: URLRequest) {
        lock.withLock { requests.append(request) }
    }

    func snapshot() -> [URLRequest] {
        lock.withLock { requests }
    }
}

nonisolated final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    static let recorder = RequestRecorder()

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.recorder.record(request)
        guard let url = request.url else { return }
        let host = url.host ?? ""
        let errors: [String: URLError.Code] = [
            "offline.test": .notConnectedToInternet,
            "timeout.test": .timedOut,
            "cancelled.test": .cancelled
        ]
        if let code = errors[host] {
            client?.urlProtocol(self, didFailWithError: URLError(code))
            return
        }

        let isPost = request.httpMethod == "POST"
        let status = host == "http.test" || (host == "post-error.test" && isPost) ? 500 : 200
        let data: Data
        if host == "malformed.test" {
            data = Data("not JSON".utf8)
        } else if isPost {
            let id = host == "wrong-id.test"
                ? UUID().uuidString : url.deletingLastPathComponent().lastPathComponent
            data = try! JSONSerialization.data(withJSONObject: ["postId": id, "likes": 11])
        } else {
            let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
            let page = Int(query.first { $0.name == "page" }?.value ?? "1") ?? 1
            let size = Int(query.first { $0.name == "pageSize" }?.value ?? "25") ?? 25
            let total = host == "empty.test" ? 0 : 26
            let start = min((page - 1) * size, total)
            let end = min(start + size, total)
            let items: [[String: Any]] = (start..<end).map { index in
                var post: [String: Any] = [
                    "id": NetworkFixtures.id(index).uuidString,
                    "authorUsername": "author\(index)",
                    "authorDisplayName": index == 0 ? NSNull() : "Автор \(index)" as Any,
                    "text": "Твит \(index)",
                    "publishedAt": index == 0 ? "2026-09-20T15:40:43.123456Z" : "2026-09-19T16:43:04Z",
                    "likes": 10,
                    "photos": [],
                    "expiresAt": NSNull()
                ]
                if host == "bad-date.test" { post["publishedAt"] = "yesterday" }
                if host == "missing-field.test" { post.removeValue(forKey: "text") }
                return post
            }
            data = try! JSONSerialization.data(withJSONObject: [
                "page": page, "pageSize": host == "bad-page.test" ? 0 : size,
                "total": total, "items": items
            ])
        }
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}

nonisolated enum NetworkFixtures {
    static func id(_ index: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index + 1))!
    }

    static func client(_ host: String = "good.test") -> TwitterAPIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return TwitterAPIClient(baseURL: URL(string: "https://\(host)")!, session: URLSession(configuration: config))
    }
}

actor SlowAPI: TwitterAPI {
    func fetchPosts(page: Int, pageSize: Int) async throws -> PostsPage {
        try await Task.sleep(for: .seconds(10))
        return PostsPage(page: page, pageSize: pageSize, total: 0, items: [])
    }

    func likePost(id: UUID) async throws -> LikeResponse {
        throw TwitterAPIError.http(500)
    }
}
