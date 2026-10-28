import Foundation
import Observation

@MainActor
@Observable
final class NewsFeedViewModel {
    private(set) var items: [Item] = []
    var errorMessage: String?
    let repository: NewsRepository
    // Живёт вместе с лентой
    let statistics = NewsStatisticsViewModel()

    init(repository: NewsRepository) { self.repository = repository }

    func reload() {
        do { items = try repository.fetch() }
        catch { errorMessage = error.localizedDescription }
    }

    func delete(offsets: IndexSet) {
        do {
            try repository.delete(offsets.map { items[$0] })
            reload()
        } catch { errorMessage = error.localizedDescription }
    }

    func prepareStatistics() {
        statistics.updateTexts(items.map { $0.text })
    }

    func searchDocuments() -> [NewsSearchDocument] {
        items.map { (title: $0.title, text: $0.text) }
    }
}
