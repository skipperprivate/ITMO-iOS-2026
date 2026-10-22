import Foundation

protocol HTTPClientProtocol {

    func data(
        for request: URLRequest
    ) async throws -> (
        Data,
        HTTPURLResponse
    )
}
