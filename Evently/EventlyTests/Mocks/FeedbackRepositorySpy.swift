@testable import Evently

struct FeedbackCall {
    let title: String?
    let message: String?
    let count: Int
}

actor FeedbackRepositorySpy: FeedbackRepository {
    private(set) var receivedTitle: String?
    private(set) var receivedMessage: String?
    private(set) var callCount = 0

    func sendFeedback(title: String, message: String) async throws {
        callCount += 1
        receivedTitle = title
        receivedMessage = message
    }

    func recordedCall() -> FeedbackCall {
        FeedbackCall(
            title: receivedTitle,
            message: receivedMessage,
            count: callCount
        )
    }
}
