import Foundation

// Cancellation is never a NetworkError: the client rethrows it as CancellationError.
nonisolated enum NetworkError: Error, Equatable, Sendable {
    case invalidRequest(String)
    case notConnected
    case timedOut
    case cannotReachServer
    case secureConnectionFailed
    case rateLimited(retryAfter: TimeInterval?)
    case httpStatus(code: Int, message: String?)
    case invalidResponse
    case decodingFailed(String)
    case transport(URLError.Code)

    init(_ error: URLError) {
        switch error.code {
        case .notConnectedToInternet, .dataNotAllowed, .internationalRoamingOff, .callIsActive:
            self = .notConnected
        case .timedOut:
            self = .timedOut
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .networkConnectionLost, .resourceUnavailable:
            self = .cannotReachServer
        case .secureConnectionFailed, .serverCertificateUntrusted, .serverCertificateHasBadDate,
             .serverCertificateNotYetValid, .serverCertificateHasUnknownRoot, .clientCertificateRejected,
             .clientCertificateRequired, .appTransportSecurityRequiresSecureConnection:
            self = .secureConnectionFailed
        case .badServerResponse, .cannotParseResponse, .zeroByteResource, .cannotDecodeRawData,
             .cannotDecodeContentData:
            self = .invalidResponse
        default:
            self = .transport(error.code)
        }
    }

    // Worth another attempt: the same request may succeed a moment later.
    // Offline fails fast — retrying without a connection only delays the error.
    var isTransient: Bool {
        switch self {
        case .timedOut, .cannotReachServer, .rateLimited:
            true
        case .httpStatus(let code, _):
            code == 408 || (500...599).contains(code)
        case .invalidRequest, .notConnected, .secureConnectionFailed, .invalidResponse, .decodingFailed, .transport:
            false
        }
    }
}

nonisolated extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidRequest(let reason): "Invalid request: \(reason)"
        case .notConnected: "No internet connection"
        case .timedOut: "Request timed out"
        case .cannotReachServer: "Cannot reach server"
        case .secureConnectionFailed: "Secure connection failed"
        case .rateLimited(let retryAfter): "Rate limited" + (retryAfter.map { ", retry after \($0)s" } ?? "")
        case .httpStatus(let code, let message): "HTTP \(code)" + (message.map { ": \($0)" } ?? "")
        case .invalidResponse: "Invalid server response"
        case .decodingFailed(let details): "Decoding failed: \(details)"
        case .transport(let code): "Transport error \(code.rawValue)"
        }
    }
}
