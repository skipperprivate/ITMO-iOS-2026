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
    private let repository: NewsRepository

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(item: Item?, repository: NewsRepository) {
        self.item = item
        self.repository = repository
        title = item?.title ?? ""
        text = item?.text ?? ""
        source = item?.source ?? "Редакция"
        category = item?.category ?? "Общее"
    }

    // Черновик не изменяет модель до нажатия «Сохранить».
    func save() -> Bool {
        guard canSave else { return false }
        let cleanSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try repository.save(item: item,
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                                source: cleanSource.isEmpty ? "Редакция" : cleanSource,
                                category: category)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
