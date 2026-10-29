import Foundation

nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}

nonisolated struct NetworkRequest<Response: Decodable & Sendable>: Sendable {
    let path: String
    let method: HTTPMethod
    var queryItems: [URLQueryItem] = []
    var body: Data?
}
