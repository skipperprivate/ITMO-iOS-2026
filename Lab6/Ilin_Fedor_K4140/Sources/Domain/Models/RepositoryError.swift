import Foundation

nonisolated enum RepositoryError: Error, Equatable, Sendable {
    case offline
    case timedOut
    case serviceUnavailable
    case rateLimited
    case requestRejected
    case invalidData
    case storageFailed
    case favoritesLimitReached
    case unknown

    static func from(_ error: any Error) -> RepositoryError {
        error as? RepositoryError ?? .unknown
    }

    var isRetryable: Bool {
        switch self {
        case .offline, .timedOut, .serviceUnavailable, .rateLimited, .invalidData, .storageFailed, .unknown: true
        case .requestRejected, .favoritesLimitReached: false
        }
    }
}
