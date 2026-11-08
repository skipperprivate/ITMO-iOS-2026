import Foundation
import OSLog

nonisolated protocol NetworkClientProtocol: Sendable {
    // Throws NetworkError, or CancellationError if the calling task was cancelled.
    func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response
}

nonisolated final class NetworkClient: NetworkClientProtocol, Sendable {
    typealias ErrorMessageParser = @Sendable (Data) -> String?

    private let session: URLSession
    private let retryPolicy: RetryPolicy
    private let limiter: ConcurrencyLimiter
    private let errorMessageParser: ErrorMessageParser
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Weatherly", category: "Network")

    // The limit is shared by every caller of this client, so screens loading at once can't flood the server.
    init(
        session: URLSession = .weatherly,
        retryPolicy: RetryPolicy = .default,
        maxConcurrentRequests: Int = 4,
        errorMessageParser: @escaping ErrorMessageParser = { _ in nil }
    ) {
        self.session = session
        self.retryPolicy = retryPolicy
        self.limiter = ConcurrencyLimiter(limit: maxConcurrentRequests)
        self.errorMessageParser = errorMessageParser
    }

    func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let request = try endpoint.makeRequest()
        var attempt = 1
        while true {
            try Task.checkCancellation()
            do {
                // Only the HTTP exchange holds a slot; backoff sleeps and decoding don't.
                let data = try await limiter.run { try await perform(request) }
                return try await Self.decode(Response.self, from: data)
            } catch let error as NetworkError {
                guard let delay = retryPolicy.delay(afterAttempt: attempt, failedWith: error) else {
                    logger.error("\(request.logDescription, privacy: .private) failed after \(attempt) attempt(s): \(error.localizedDescription, privacy: .public)")
                    throw error
                }
                logger.notice("\(request.logDescription, privacy: .private) attempt \(attempt) failed: \(error.localizedDescription, privacy: .public); retrying in \(delay, format: .fixed(precision: 2))s")
                // Throws CancellationError, so a cancelled task stops waiting immediately.
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                attempt += 1
            }
        }
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError {
            throw NetworkError(error)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw NetworkError.transport(.unknown)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        logger.debug("\(request.logDescription, privacy: .private) → \(http.statusCode) (\(data.count) bytes)")

        switch http.statusCode {
        case 200..<300:
            guard !data.isEmpty else { throw NetworkError.invalidResponse }
            return data
        case 429:
            throw NetworkError.rateLimited(retryAfter: http.retryAfter)
        default:
            throw NetworkError.httpStatus(code: http.statusCode, message: errorMessageParser(data))
        }
    }

    // Decoding a 10-day forecast is the heaviest step, so it runs off the caller's actor.
    @concurrent
    private static func decode<Response: Decodable>(_ type: Response.Type, from data: Data) async throws -> Response {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error.summary)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }
}

nonisolated extension URLSession {
    // No HTTP cache: freshness is the repositories' job, a stale forecast here would be invisible.
    static let weatherly: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
}

private nonisolated extension URLRequest {
    var logDescription: String {
        "\(httpMethod ?? "GET") \(url?.absoluteString ?? "<nil>")"
    }
}

private nonisolated extension HTTPURLResponse {
    // Retry-After is either delta-seconds or an HTTP-date (RFC 9110).
    var retryAfter: TimeInterval? {
        guard let value = value(forHTTPHeaderField: "Retry-After")?.trimmingCharacters(in: .whitespaces) else {
            return nil
        }
        if let seconds = TimeInterval(value) {
            return max(0, seconds)
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: value).map { max(0, $0.timeIntervalSinceNow) }
    }
}

private nonisolated extension DecodingError {
    var summary: String {
        func path(_ context: Context) -> String {
            context.codingPath.map { $0.intValue.map { "[\($0)]" } ?? $0.stringValue }.joined(separator: ".")
        }
        switch self {
        case .keyNotFound(let key, let context):
            return "missing key '\(key.stringValue)' at '\(path(context))'"
        case .valueNotFound(_, let context):
            return "null value at '\(path(context))'"
        case .typeMismatch(_, let context):
            return "type mismatch at '\(path(context))'"
        case .dataCorrupted(let context):
            return "corrupted data at '\(path(context))': \(context.debugDescription)"
        @unknown default:
            return localizedDescription
        }
    }
}
