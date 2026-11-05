//
//  NetworkClient.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation
import OSLog

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let baseURL: String
    private let decoder: JSONDecoder
    
    private let log = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.quoteapp",
        category: "Network"
    )
    
    init(session: URLSession = .shared,
         baseURL: String = "https://dummyjson.com",
         decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.baseURL = baseURL
        self.decoder = decoder
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            log.error("Invalid path: \(endpoint.path, privacy: .public)")
            throw APIError.invalidURL
        }
        
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        
        guard let url = components.url else {
            log.error("Failed build URL")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        log.debug("\(endpoint.method.rawValue, privacy: .public) \(url.absoluteString, privacy: .public)")
        
        let data: Data
        let response: URLResponse
        let start = Date()
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            log.error("URLError \(urlError.code.rawValue): \(urlError.localizedDescription, privacy: .public)")
            throw Self.mapURLError(urlError)
        } catch  {
            throw APIError.transport(description: error.localizedDescription)
        }
        
        let duration = Date().timeIntervalSince(start)
        guard let http = response as? HTTPURLResponse else {
            log.error("Response is not HTTPURLResponse")
            throw APIError.noData
        }
                      
        let ms = String(format: "%.0f", duration * 1000)
        log.debug("\(http.statusCode) · \(data.count) B · \(ms, privacy: .public) ms")
        
        try Self.validate(statusCode: http.statusCode, data: data, headers: http, log: log)
        
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            let mapped = Self.mapDecodingError(decodingError)
            log.error("Decode failed: \(mapped.localizedDescription, privacy: .public)")
            throw mapped
        } catch {
            log.error("Decode \(String(describing: T.self), privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
            throw APIError.decodingFailed(path: "\(T.self)", reason: error.localizedDescription)
        }
    }
    
    private static func validate(statusCode: Int, data: Data, headers: HTTPURLResponse, log: Logger) throws {
        switch statusCode {
        case 200..<300:
            return
        case 400:
            throw APIError.badRequest(message: "Bad Request")
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 429:
            let retryAfter = headers.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            throw APIError.tooManyRequests(retryAfter: retryAfter)
        case 500..<600:
            throw APIError.serverError(status: statusCode)
        default:
            throw APIError.unexpectedStatus(status: statusCode)
        }
    }
    
    
    private static func mapURLError(_ error: URLError) -> APIError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternet
        case .timedOut:
            return .timeout
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return .transport(description: "Сервер недоступен")
        case .secureConnectionFailed, .serverCertificateUntrusted:
            return .transport(description: "Проблема с SSL-сертификатом")
        default:
            return .transport(description: error.localizedDescription)
        }
    }
    
    private static func mapDecodingError(_ error: DecodingError) -> APIError {
        switch error {
        case .keyNotFound(let key, let context):
            let path = (context.codingPath + [key]).map(\.stringValue).joined(separator: ".")
            return .decodingFailed(path: path, reason: "Обязательное поле отсутствует")
        case .typeMismatch(let type, let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return .decodingFailed(path: path.isEmpty ? "root" : path, reason: "Ожидался тип \(type)")
        case .valueNotFound(let type, let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return .decodingFailed(path: path.isEmpty ? "root" : path, reason: "Значение типа \(type) отсутствует")
        case .dataCorrupted(let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return .decodingFailed(path: path.isEmpty ? "root" : path, reason: context.debugDescription)
        @unknown default:
            return .decodingFailed(path: "unknown", reason: "Неизвестная ошибка парсинга")
        }
    }
}
