protocol FeedbackRepository {
    func sendFeedback(
        title: String,
        message: String
    ) async throws
}
