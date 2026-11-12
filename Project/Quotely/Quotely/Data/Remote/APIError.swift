//
//  APIError.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 15.10.2026.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noInternet
    case timedOut
    case connectionFailed
    case http(status: Int, message: String?)
    case encoding
    case decoding
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "error.invalid_url")
        case .invalidResponse:
            return String(localized: "error.invalid_response")
        case .noInternet:
            return String(localized: "error.no_internet")
        case .timedOut:
            return String(localized: "error.timed_out")
        case .connectionFailed:
            return String(localized: "error.connection_failed")
        case let .http(status, message):
            let details = message ?? String(localized: "error.http.default_details")
            if status >= 500 {
                return String(
                    format: String(localized: "error.http.server"),
                    status,
                    details
                )
            }
            return String(format: String(localized: "error.http.client"), status, details)
        case .encoding:
            return String(localized: "error.encoding")
        case .decoding:
            return String(localized: "error.decoding")
        case .unknown:
            return String(localized: "error.unknown")
        }
    }
}
