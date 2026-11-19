import Foundation

struct JSONHTTPClient: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send<Response: Decodable & Sendable>(
        _ request: URLRequest,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw APIError.map(error)
        }

        try Task.checkCancellation()

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            throw APIError.map(error)
        }
    }
}
