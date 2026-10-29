import Foundation

actor NetworkClientImpl: NetworkClient {
    private enum Constants {
        static let jsonContentType = "application/json"
        static let acceptHeader = "Accept"
        static let contentTypeHeader = "Content-Type"
        static let requestLogFormat = "[Recipe API] %@ %@"
        static let responseLogFormat = "[Recipe API] HTTP %ld, %ld bytes"
        static let emptyLogValue = ""
    }

    private let session: URLSession
    private let baseURL: URL
    private let decoder = JSONDecoder()

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send<Response: Decodable & Sendable>(
        request: NetworkRequest<Response>
    ) async throws
        -> Response
    {
        try Task.checkCancellation()
        let urlRequest = try makeURLRequest(from: request)
        let (data, response) = try await perform(urlRequest)
        try validate(response, dataSize: data.count)
        return try decode(data)
    }

    private func makeURLRequest<Response>(from request: NetworkRequest<Response>) throws -> URLRequest {
        let url = try makeURL(path: request.path, queryItems: request.queryItems)
        var urlRequest = URLRequest(url: url, timeoutInterval: 30)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.setValue(Constants.jsonContentType, forHTTPHeaderField: Constants.acceptHeader)
        if request.body != nil {
            urlRequest.setValue(Constants.jsonContentType, forHTTPHeaderField: Constants.contentTypeHeader)
        }
        return urlRequest
    }

    private func makeURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        let endpoint = baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        #if DEBUG
        print(
            String(
                format: Constants.requestLogFormat,
                request.httpMethod ?? Constants.emptyLogValue,
                request.url?.absoluteString ?? Constants.emptyLogValue
            )
        )
        #endif

        do {
            let result = try await session.data(for: request)
            try Task.checkCancellation()
            return result
        } catch let error as URLError {
            if error.code == .cancelled || Task.isCancelled {
                throw CancellationError()
            }
            throw NetworkError.transport(error.code)
        }
    }

    private func validate(_ response: URLResponse, dataSize: Int) throws {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        #if DEBUG
        print(String(format: Constants.responseLogFormat, response.statusCode, dataSize))
        #endif
        guard (200..<300).contains(response.statusCode) else {
            throw NetworkError.httpStatus(response.statusCode)
        }
    }

    private func decode<Response: Decodable>(_ data: Data) throws -> Response {
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
}
