import Foundation

protocol NetworkClient: Sendable {
    func send<Response: Decodable & Sendable>(request: NetworkRequest<Response>) async throws -> Response
}
