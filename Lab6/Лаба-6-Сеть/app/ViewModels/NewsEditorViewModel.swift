import Foundation
import Observation

@MainActor
@Observable
final class NewsEditorViewModel {
    let item: Item?
    var title: String
    var text: String
    var source: String
    var category: String
    var errorMessage: String?
    private(set) var isSubmitting = false
    private(set) var acceptedPost: CreatedPost?
    private let repository: NewsRepository
    private let publisher: any NewsPublishing
    private let submissionID = UUID()
    private var acceptedSource = ""
    private var acceptedCategory = ""

    var canSave: Bool {
        !isSubmitting && item?.remoteID == nil
        && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var fieldsAreLocked: Bool { isSubmitting || acceptedPost != nil }
    private var cleanSource: String {
        let value = source.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Редакция" : value
    }

    init(item: Item?, repository: NewsRepository, publisher: any NewsPublishing = NewsAPIClient()) {
        self.item = item
        self.repository = repository
        self.publisher = publisher
        title = item?.title ?? ""
        text = item?.text ?? ""
        source = item?.source ?? "Редакция"
        category = item?.category ?? "Общее"
    }

    // Локальное сохранение осталось доступно и без интернета.
    func save() -> Bool {
        guard canSave, acceptedPost == nil else { return false }
        errorMessage = nil
        do {
            try repository.save(item: item,
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                                source: cleanSource, category: category)
            return true
        } catch {
            errorMessage = "Не удалось сохранить на устройстве: \(error.localizedDescription)"
            return false
        }
    }

    func submit() async -> Bool {
        guard item == nil, canSave else { return false }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        if acceptedPost == nil {
            let draft = NewPost(title: title, body: text, userId: 1)
            let sourceSnapshot = cleanSource
            let categorySnapshot = category
            do {
                let response = try await publisher.create(draft)
                acceptedPost = response
                acceptedSource = sourceSnapshot
                acceptedCategory = categorySnapshot
            } catch {
                guard !Task.isCancelled, !(error is CancellationError),
                      (error as? URLError)?.code != .cancelled else { return false }
                errorMessage = "Не удалось отправить публикацию: \(error.localizedDescription) Текст остался в редакторе."
                return false
            }
        }
        guard let acceptedPost else { return false }
        do {
            try repository.saveSubmitted(acceptedPost, submissionID: submissionID,
                                         source: acceptedSource, category: acceptedCategory)
            return true
        } catch {
            // Повтор кнопки повторяет только локальное сохранение, не POST.
            errorMessage = "Сервер принял публикацию №\(acceptedPost.id), но сохранить её на устройстве не удалось. Повторите сохранение: \(error.localizedDescription)"
            return false
        }
    }
}
