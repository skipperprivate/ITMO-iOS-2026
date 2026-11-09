import Foundation

protocol NewsFetching: Sendable {
    func fetchArticles() async throws -> [RemoteArticle]
}

protocol NewsPublishing: Sendable {
    func create(_ post: NewPost) async throws -> CreatedPost
}

// Формирование запросов, JSON и проверка HTTP находятся только в сервисе.
// Actor также выносит декодирование JSON с MainActor.
actor NewsAPIClient: NewsFetching, NewsPublishing {
    private let transport: any HTTPTransport

    init(transport: any HTTPTransport = URLSessionTransport()) {
        self.transport = transport
    }

    func fetchArticles() async throws -> [RemoteArticle] {
        let request = try makeRequest(path: "/posts", method: "GET", query: [
            URLQueryItem(name: "limit", value: "30")
        ])
        let payload: PostsResponse = try await send(request)
        var seen = Set<Int>()
        // Некорректный ответ не подменяется успешной пустой лентой.
        return try payload.posts.compactMap { post in
            try validate(post)
            guard seen.insert(post.id).inserted else { return nil }
            return RemoteArticle(id: "dummyjson:\(post.id)", title: post.title,
                                 body: post.body, authorID: post.userId, tags: post.tags ?? [])
        }
    }

    func create(_ post: NewPost) async throws -> CreatedPost {
        let clean = NewPost(title: post.title.trimmingCharacters(in: .whitespacesAndNewlines),
                            body: post.body.trimmingCharacters(in: .whitespacesAndNewlines),
                            userId: post.userId)
        guard !clean.title.isEmpty, !clean.body.isEmpty, clean.userId > 0 else {
            throw NewsAPIError.invalidInput
        }
        var request = try makeRequest(path: "/posts/add", method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(clean)
        let response: PostDTO = try await send(request)
        try validate(response)
        // Используем распарсенный ответ сервера, а не входной черновик.
        return CreatedPost(id: response.id, title: response.title,
                           body: response.body, authorID: response.userId)
    }

    private func makeRequest(path: String, method: String,
                             query: [URLQueryItem] = []) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dummyjson.com"
        components.path = path
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { throw NewsAPIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        try Task.checkCancellation()
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .cancelled: throw error
            case .notConnectedToInternet, .networkConnectionLost: throw NewsAPIError.offline
            case .timedOut: throw NewsAPIError.timeout
            default: throw NewsAPIError.connection
            }
        }
        try Task.checkCancellation()
        guard let http = response as? HTTPURLResponse else { throw NewsAPIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw NewsAPIError.httpStatus(http.statusCode) }
        do {
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            try Task.checkCancellation()
            return decoded
        } catch is DecodingError {
            throw NewsAPIError.invalidData
        }
    }

    private func validate(_ post: PostDTO) throws {
        guard post.id > 0, post.userId > 0,
              !post.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !post.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NewsAPIError.invalidData
        }
    }
}

private struct PostsResponse: Decodable { let posts: [PostDTO] }
private struct PostDTO: Decodable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
    let tags: [String]?
}
