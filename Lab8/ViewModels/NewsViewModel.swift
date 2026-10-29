import Foundation
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var news: [News] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var hasMorePosts = false

    @Published var showFavorites: Bool {
        didSet {
            defaults.set(showFavorites, forKey: "showFavorites")
        }
    }

    private let client = NewsAPIClient()
    private let storage: any NewsStorage
    private let defaults: UserDefaults

    private let chunkSize = 10
    private var nextOffset = 0

    var visibleNews: [News] {
        if showFavorites {
            return news.filter { item in
                item.isFavorite
            }
        }

        return news
    }

    init(storage: any NewsStorage, defaults: UserDefaults) {
        self.storage = storage
        self.defaults = defaults

        showFavorites = defaults.bool(forKey: "showFavorites")
        loadNews()
    }

    convenience init() {
        self.init(
            storage: FileNewsStorage(),
            defaults: .standard
        )
    }

    func refreshNews() async {
        await loadNewsFromAPI(reset: true)
    }

    func loadNextChunk() async {
        if !hasMorePosts || showFavorites {
            return
        }

        await loadNewsFromAPI(reset: false)
    }

    func loadMoreIfNeeded(currentItem: News) {
        if isLoading || !hasMorePosts || showFavorites {
            return
        }

        if errorMessage != nil {
            return
        }

        guard let index = news.firstIndex(where: { item in
            item.id == currentItem.id
        }) else {
            return
        }

        let remainingPosts = news.count - index - 1

        if remainingPosts > chunkSize {
            return
        }

        Task {
            await loadNextChunk()
        }
    }

    private func loadNewsFromAPI(reset: Bool) async {
        if isLoading {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            var offset = reset ? 0 : nextOffset
            let chunksToLoad = reset ? 2 : 1

            var receivedPosts: [APIPost] = []
            var morePostsAvailable = true

            for _ in 0..<chunksToLoad {
                let posts = try await client.fetchPosts(
                    start: offset,
                    limit: chunkSize
                )

                try Task.checkCancellation()

                receivedPosts.append(contentsOf: posts)
                offset += posts.count

                morePostsAvailable = posts.count == chunkSize

                if !morePostsAvailable {
                    break
                }
            }

            var updatedNews: [News] = reset ? [] : news

            for post in receivedPosts {
                let oldNews = news.first { item in
                    item.id == post.id
                }

                let item = News(
                    id: post.id,
                    title: post.title,
                    text: post.body,
                    isFavorite: oldNews?.isFavorite ?? false
                )

                if let index = updatedNews.firstIndex(where: { newsItem in
                    newsItem.id == item.id
                }) {
                    updatedNews[index] = item
                } else {
                    updatedNews.append(item)
                }
            }

            news = updatedNews
            nextOffset = offset
            hasMorePosts = morePostsAvailable

            saveNews()
        } catch {
            if Task.isCancelled {
                return
            }

            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite(_ item: News) {
        if let index = news.firstIndex(where: { newsItem in
            newsItem.id == item.id
        }) {
            news[index].isFavorite.toggle()
            saveNews()
        }
    }

    private func loadNews() {
        do {
            news = try storage.load()
        } catch {
            errorMessage = "Не удалось прочитать сохранённые новости."
        }
    }

    private func saveNews() {
        do {
            try storage.save(news)
        } catch {
            errorMessage = "Не удалось сохранить новости."
        }
    }
}
