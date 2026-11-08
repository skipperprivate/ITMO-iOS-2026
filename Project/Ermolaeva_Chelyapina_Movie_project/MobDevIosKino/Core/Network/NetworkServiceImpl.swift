import Foundation
import OSLog

final class NetworkServiceImpl: NetworkService { // final = класс без наследования
    private let session: URLSession
    private let apiKey: String
    private static let logger = Logger(subsystem: "network", category: "service")
    private static let decoder = JSONDecoder()
    
    init(session: URLSession = .shared, apiKey: String
    ) {
        self.session = session
        self.apiKey = apiKey
    }
    
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let request = try buildRequest(for: endpoint)
        let (data, response) = try await performRequest(request)
        
        try validate(response)
        
        return try decode(data)
    }

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        return request
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as URLError {
            Self.logger.error("URLSession error: \(error.localizedDescription)")
            throw mapURLError(error)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            Self.logger.error("Unexpected network error: \(error)")
            throw NetworkError.unknown
        }
    }

    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .noConnection
        case .timedOut:
            return .timeout
        default:
            return .unknown
        }
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        guard (200...299).contains(http.statusCode) else {
            Self.logger.error("HTTP error: \(http.statusCode)")
            throw NetworkError.server(statusCode: http.statusCode)
        }
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, _) {
            Self.logger.error("Missing JSON key: \(key.stringValue)")
            throw NetworkError.decoding
        } catch DecodingError.typeMismatch(let type, let context) {
            Self.logger.error("Type mismatch: expected \(String(describing: type)), \(context.debugDescription)")
            throw NetworkError.decoding
        } catch {
            Self.logger.error("Decoding failed: \(error)")
            throw NetworkError.decoding
        }
    }
}
