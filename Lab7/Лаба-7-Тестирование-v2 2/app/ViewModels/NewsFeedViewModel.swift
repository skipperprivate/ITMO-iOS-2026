import Foundation
import Observation

@MainActor
@Observable
final class NewsFeedViewModel {
    private(set) var items: [Item] = []
    private(set) var isRefreshing = false
    private(set) var hasRefreshError = false
    private(set) var networkMessage: String?
    private var didLoad = false
    private let newsService: any NewsFetching
    var errorMessage: String?
    let repository: NewsRepository
    // Живёт вместе с лентой
    let statistics = NewsStatisticsViewModel()

    init(repository: NewsRepository, newsService: any NewsFetching = NewsAPIClient()) {
        self.repository = repository
        self.newsService = newsService
    }

    func load() async {
        reload()
        guard !didLoad else { return }
        didLoad = true
        await refresh()
        if Task.isCancelled { didLoad = false }
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        networkMessage = nil
        defer { isRefreshing = false }
        hasRefreshError = false
        let articles: [RemoteArticle]
        do {
            articles = try await newsService.fetchArticles()
            try Task.checkCancellation()
        } catch {
            guard !Task.isCancelled, !(error is CancellationError),
                  (error as? URLError)?.code != .cancelled else { return }
            hasRefreshError = true
            let cacheMessage = items.isEmpty ? "Сохранённых публикаций пока нет." : "Показаны сохранённые публикации."
            networkMessage = "Не удалось загрузить ленту. \(error.localizedDescription) \(cacheMessage)"
            return
        }
        do {
            try repository.merge(articles)
            items = try repository.fetch()
            prepareStatistics()
            networkMessage = articles.isEmpty ? "Сервер вернул пустой список." : "Загружено публикаций: \(articles.count)."
        } catch {
            hasRefreshError = true
            networkMessage = "Данные получены, но не удалось обновить хранилище: \(error.localizedDescription)"
        }
    }

    func reload() {
        do {
            items = try repository.fetch()
            prepareStatistics()
        }
        catch { errorMessage = error.localizedDescription }
    }

    func delete(offsets: IndexSet) {
        do {
            try repository.delete(offsets.compactMap { items.indices.contains($0) ? items[$0] : nil })
            reload()
        } catch { errorMessage = error.localizedDescription }
    }

    func prepareStatistics() {
        statistics.updateTexts(items.map { $0.text })
    }

    func searchDocuments() -> [NewsSearchDocument] {
        items.map { NewsSearchDocument(title: $0.title, text: $0.text) }
    }
}
