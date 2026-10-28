import Foundation
import Observation

@MainActor
@Observable
final class NewsFeedViewModel {
    private(set) var items: [Item] = []
    var errorMessage: String?
    let repository: NewsRepository

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

}
