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
        case .requestFailed(let error): "Ошибка соединения: \(error.localizedDescription)"
        case .invalidResponse: "Некорректный ответ сервера"
        case .badStatus(let code): "Сервер вернул ошибку \(code)"
        case .noData: "Сервер не прислал данных"
        case .decodingFailed: "Не удалось разобрать ответ"
        case .emptyResponse: "Сервер не прислал рецептов"
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
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
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
        print(request.httpMethod ?? "", http.statusCode, request.url?.absoluteString ?? "")
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.badStatus(http.statusCode)
        }
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        return data
    }
}
