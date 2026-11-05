import Foundation

enum NetworkError: LocalizedError {
    case requestFailed(Error)
    case invalidResponse
    case badStatus(Int)
    case noData
    case decodingFailed
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .requestFailed(let error):
            return "Ошибка соединения: \(error.localizedDescription)"
        case .invalidResponse:
            return "Некорректный ответ сервера"
        case .badStatus(let code):
            return "Сервер вернул ошибку \(code)"
        case .noData:
            return "Сервер не прислал данных"
        case .decodingFailed:
            return "Не удалось разобрать ответ"
        case .emptyResponse:
            return "Сервер не прислал рецептов"
        }
    }
}

enum NetworkClient {
    static func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data = try await send(request)
        return try JSONParser.decode(data)
    }

    static func post<Body: Encodable, T: Decodable>(_ url: URL, body: Body) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONParser.encode(body)

        let data = try await send(request)
        return try JSONParser.decode(data)
    }

    static func makeURL(_ address: String, query: [String: String] = [:]) throws -> URL {
        var components = URLComponents(string: address)
        if !query.isEmpty {
            var items: [URLQueryItem] = []
            for (name, value) in query {
                items.append(URLQueryItem(name: name, value: value))
            }
            components?.queryItems = items
        }
        guard let url = components?.url else { throw URLError(.badURL) }
        return url
    }

    private static func send(_ request: URLRequest) async throws -> Data {
        let result: (Data, URLResponse)
        do {
            result = try await URLSession.shared.data(for: request)
        } catch {
            throw NetworkError.requestFailed(error)
        }
        let (data, response) = result

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.badStatus(http.statusCode)
        }
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        return data
    }
}
