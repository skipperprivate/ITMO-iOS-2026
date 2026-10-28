import Foundation
import Combine

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var title = ""
    @Published var text = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let client = NewsAPIClient()

    func sendPost() async {
        if isLoading {
            return
        }

        errorMessage = nil
        successMessage = nil

        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if cleanTitle.isEmpty || cleanText.isEmpty {
            errorMessage = "Заполни заголовок и текст."
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let post = try await client.createPost(
                title: cleanTitle,
                text: cleanText
            )

            try Task.checkCancellation()

            successMessage = "Сервер принял пост. ID: \(post.id)."
            title = ""
            text = ""
        } catch {
            if Task.isCancelled {
                return
            }

            errorMessage = error.localizedDescription
        }
    }
}
