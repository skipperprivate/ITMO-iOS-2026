import Foundation
import Observation

@MainActor
@Observable
final class FeedbackViewModel {

    private let repository: FeedbackRepository

    var title = ""
    var message = ""

    var isSending = false
    var errorMessage: String?
    var isSuccess = false

    init(repository: FeedbackRepository) {
        self.repository = repository
    }

    var canSubmit: Bool {
        !title.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        &&
        !message.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        &&
        !isSending
    }

    func submit() async {
        guard canSubmit else { return }

        isSending = true
        errorMessage = nil
        isSuccess = false

        defer {
            isSending = false
        }

        do {
            try await repository.sendFeedback(
                title: title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                message: message.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            )

            try Task.checkCancellation()

            isSuccess = true
            title = ""
            message = ""

        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
