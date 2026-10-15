import Foundation
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var news: [News] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var showFavorites: Bool {
        didSet {
            UserDefaults.standard.set(
                showFavorites,
                forKey: "showFavorites"
            )
        }
    }

    private let client = NewsAPIClient()
    
    private var fileURL: URL {
        let folder = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return folder.appendingPathComponent("news.json")
    }

    var visibleNews: [News] {
        if showFavorites {
            return news.filter { item in
                item.isFavorite
            }
        }

        return news
    }

   
    init() {
        showFavorites = UserDefaults.standard.bool(
            forKey: "showFavorites"
        )

        loadNews()
    }

   
    func refreshNews() async {
        if isLoading {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let posts = try await client.fetchPosts()

            try Task.checkCancellation()

            var updatedNews: [News] = []

            for post in posts {
                let oldNews = news.first { item in
                    item.id == post.id
                }

                let item = News(
                    id: post.id,
                    title: post.title,
                    text: post.body,
                    isFavorite: oldNews?.isFavorite ?? false
                )

                updatedNews.append(item)
            }

            news = updatedNews
            saveNews()
        } catch {
            if Task.isCancelled {
                return
            }

            errorMessage = "Не удалось загрузить новости."
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
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)

            news = try JSONDecoder().decode(
                [News].self,
                from: data
            )
        } catch {
            errorMessage = "Не удалось прочитать сохранённые новости."
        }
    }

    
    private func saveNews() {
        do {
            let data = try JSONEncoder().encode(news)

            try data.write(
                to: fileURL,
                options: .atomic
            )
        } catch {
            errorMessage = "Не удалось сохранить новости."
        }
    }
}
