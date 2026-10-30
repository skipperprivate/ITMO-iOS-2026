//
//  Endpoint.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}

// Typed description of a request: the response type travels with the endpoint.
nonisolated struct Endpoint<Response: Decodable & Sendable>: Sendable {
    var scheme: String = "https"
    var host: String
    var path: String
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var timeout: TimeInterval?

    func makeRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
            // URLComponents leaves "+" as is, and servers decode it as a space.
            components.percentEncodedQuery = components.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
        }
        guard let url = components.url else {
            throw NetworkError.invalidRequest("\(host)\(path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        if let timeout {
            request.timeoutInterval = timeout
        }
        return request
    }
}
