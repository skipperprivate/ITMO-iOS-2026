import Foundation

nonisolated protocol TwitterAPI: Sendable {
    func fetchPosts(page: Int, pageSize: Int) async throws -> PostsPage
    func likePost(id: UUID) async throws -> LikeResponse
}

nonisolated enum TwitterAPIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case decoding
    case offline
    case timeout
    case http(Int)
    case transport

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Не удалось сформировать адрес запроса."
        case .invalidResponse: "Сервер вернул неожиданный ответ."
        case .decoding: "Не удалось прочитать данные сервера."
        case .offline: "Нет подключения к интернету. Сохранённые твиты доступны."
        case .timeout: "Сервер не ответил вовремя."
        case .http(401), .http(403): "Сервер отказал в доступе."
        case .http(404): "Запись на сервере не найдена."
        case .http(429): "Слишком много запросов. Попробуйте позже."
        case .http(let status): "Ошибка сервера (HTTP \(status))."
        case .transport: "Не удалось соединиться с сервером."
        }
    }
}

nonisolated struct TwitterAPIClient: TwitterAPI {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: "https://test.play-trace.com")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchPosts(page: Int, pageSize: Int) async throws -> PostsPage {
        guard page > 0, pageSize > 0 else { throw TwitterAPIError.invalidURL }
        var components = URLComponents(url: baseURL.appendingPathComponent("api/posts"),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        guard let url = components?.url else { throw TwitterAPIError.invalidURL }
        let result: PostsPage = try await send(url: url, method: "GET")
        guard result.page == page, result.pageSize == pageSize, result.total >= 0,
              result.items.count <= result.pageSize,
              result.items.allSatisfy({ $0.likes >= 0 }) else {
            throw TwitterAPIError.invalidResponse
        }
        return result
    }

    func likePost(id: UUID) async throws -> LikeResponse {
        let url = baseURL.appendingPathComponent("api/posts/\(id.uuidString)/like")
        let result: LikeResponse = try await send(url: url, method: "POST")
        guard result.postId == id, result.likes >= 0 else { throw TwitterAPIError.invalidResponse }
        return result
    }

    @concurrent
    private func send<Response: Decodable & Sendable>(url: URL, method: String) async throws -> Response {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            try Task.checkCancellation()
            guard let response = response as? HTTPURLResponse else { throw TwitterAPIError.invalidResponse }
            guard (200..<300).contains(response.statusCode) else {
                throw TwitterAPIError.http(response.statusCode)
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let value = try container.decode(String.self)
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: value) { return date }
                formatter.formatOptions = [.withInternetDateTime]
                guard let date = formatter.date(from: value) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date")
                }
                return date
            }
            return try decoder.decode(Response.self, from: data)
        } catch is DecodingError {
            throw TwitterAPIError.decoding
        } catch let error as URLError {
            switch error.code {
            case .cancelled: throw CancellationError()
            case .notConnectedToInternet, .networkConnectionLost: throw TwitterAPIError.offline
            case .timedOut: throw TwitterAPIError.timeout
            default: throw TwitterAPIError.transport
            }
        }
    }
}
