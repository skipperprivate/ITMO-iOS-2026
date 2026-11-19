import Foundation

struct FeedbackAPIClient: Sendable {
    private let httpClient: JSONHTTPClient

    init(session: URLSession = .shared) {
        self.httpClient = JSONHTTPClient(session: session)
    }

    func send(title: String, message: String) async throws -> FeedbackResponseDTO {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw APIError.invalidURL
        }

        let dto = FeedbackRequestDTO(title: title, body: message, userId: 1)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = NetworkConfiguration.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(dto)

        return try await httpClient.send(request)
    }
}
