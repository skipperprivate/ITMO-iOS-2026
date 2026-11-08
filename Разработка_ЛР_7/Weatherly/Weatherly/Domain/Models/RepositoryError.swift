//
//  RepositoryError.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

// What went wrong from the app's point of view; transport details stay in the Data layer.
nonisolated enum RepositoryError: Error, Equatable, Sendable {
    case offline
    case timedOut
    case serviceUnavailable
    case rateLimited
    case requestRejected
    case invalidData
    case unknown

    // Callers catch CancellationError before this: a cancelled load is not a failure to show.
    static func from(_ error: any Error) -> RepositoryError {
        error as? RepositoryError ?? .unknown
    }

    // Worth offering "try again" right away; a rejected request would fail the same way.
    var isRetryable: Bool {
        switch self {
        case .offline, .timedOut, .serviceUnavailable, .rateLimited, .invalidData, .unknown: true
        case .requestRejected: false
        }
    }
}
