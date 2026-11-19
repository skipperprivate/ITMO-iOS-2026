import Foundation

final class RemoteFeedbackRepository: FeedbackRepository {

    private let apiClient: FeedbackAPIClient

    init(apiClient: FeedbackAPIClient) {
        self.apiClient = apiClient
    }

    func sendFeedback(
        title: String,
        message: String
    ) async throws {
        _ = try await apiClient.send(
            title: title,
            message: message
        )
    }
}
