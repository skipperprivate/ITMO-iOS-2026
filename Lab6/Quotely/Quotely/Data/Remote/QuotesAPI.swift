//
//  QuotesAPI.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 26.09.2026.
//

import Foundation
import OSLog

struct QuotesAPI {
    private let timeout: TimeInterval = 30

    private let logger = Logger(subsystem: "com.itmo.study.Quotely", category: "Network")
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    struct RemoteQuote: Decodable {
        let id: Int
        let quote: String
        let author: String
    }

    struct Page: Decodable {
        let quotes: [RemoteQuote]
        let total: Int
    }

    struct Post: Decodable {
        let id: Int
        let title: String
        let body: String
        let userId: Int
    }

    private struct NewPost: Encodable {
        let title: String
        let body: String
        // Учебный пользователь DummyJSON; автор цитаты передаётся в title.
        let userId = 1
    }

    private struct ServerError: Decodable {
        let message: String
    }

    func fetchPage(limit: Int = 20, skip: Int = 0) async throws -> Page {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dummyjson.com"
        components.path = "/quotes"
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "skip", value: String(skip))
        ]

        guard let url = components.url else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await send(request)
    }

    func publish(_ quote: Quote) async throws -> Post {
        guard let url = URL(string: "https://dummyjson.com/posts/add") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(NewPost(title: quote.author, body: quote.text))
        } catch {
            throw APIError.encoding
        }
        return try await send(request)
    }

    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        var request = request
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let label = "\(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")"
        logger.notice("Отправка: \(label, privacy: .public)")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            logger.error("\(label, privacy: .public): сбой соединения, код \(error.code.rawValue)")
            if error.code == .cancelled { throw CancellationError() }
            throw mapToAPIError(error.code)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            logger.error("\(label, privacy: .public): непредвиденная ошибка — \(error.localizedDescription, privacy: .public)")
            throw APIError.unknown
        }

        try Task.checkCancellation()

        guard let response = response as? HTTPURLResponse else {
            logger.error("\(label, privacy: .public): ответ не является HTTP")
            throw APIError.invalidResponse
        }
        logger.notice("Ответ: \(label, privacy: .public), HTTP \(response.statusCode), \(data.count) байт")

        guard (200..<300).contains(response.statusCode) else {
            logger.error("\(label, privacy: .public): неуспешный статус \(response.statusCode)")
            let message = try? JSONDecoder().decode(ServerError.self, from: data).message
            throw APIError.http(status: response.statusCode, message: message)
        }

        guard !data.isEmpty else {
            logger.error("\(label, privacy: .public): тело ответа пустое")
            throw APIError.invalidResponse
        }

        do {
            let result = try JSONDecoder().decode(Response.self, from: data)
            logger.notice("Успех: \(label, privacy: .public), JSON разобран")
            return result
        } catch {
            logger.error("\(label, privacy: .public): ошибка разбора JSON — \(error.localizedDescription, privacy: .public)")
            throw APIError.decoding
        }
    }

    private func mapToAPIError(_ code: URLError.Code) -> APIError {
        switch code {
        case .notConnectedToInternet, .dataNotAllowed:
            return .noInternet
        case .timedOut:
            return .timedOut
        default:
            return .connectionFailed
        }
    }
}
