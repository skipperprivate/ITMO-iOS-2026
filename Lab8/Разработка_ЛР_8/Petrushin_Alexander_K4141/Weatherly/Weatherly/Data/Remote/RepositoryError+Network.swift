//
//  RepositoryError+Network.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

nonisolated extension RepositoryError {
    init(_ error: NetworkError) {
        switch error {
        case .notConnected: self = .offline
        case .timedOut: self = .timedOut
        case .rateLimited: self = .rateLimited
        case .cannotReachServer, .secureConnectionFailed, .transport: self = .serviceUnavailable
        case .httpStatus(let code, _): self = (500...599).contains(code) ? .serviceUnavailable : .requestRejected
        case .invalidRequest: self = .requestRejected
        case .invalidResponse, .decodingFailed: self = .invalidData
        }
    }

    // Repositories expose only RepositoryError and CancellationError.
    static func translating<Value>(_ operation: () async throws -> Value) async throws -> Value {
        do {
            return try await operation()
        } catch let error as NetworkError {
            throw RepositoryError(error)
        } catch is OpenMeteoMappingError {
            throw RepositoryError.invalidData
        }
    }
}
