import Foundation
import SwiftData

@main
enum ConcurrencyChecks {
    static func require(_ condition: Bool, _ message: String) {
        precondition(condition, message)
    }

    @MainActor
    static func main() async throws {
        let phase = CommandLine.arguments[1]
        if phase == "live" {
            let page = try await TwitterAPIClient().fetchPosts(page: 1, pageSize: 2)
            require(page.items.count <= 2 && page.total >= page.items.count, "Некорректный GET")
            print("PASS: реальный GET и парсинг, total = \(page.total)")
            return
        }

        let directory = URL(fileURLWithPath: CommandLine.arguments[2])
        let suite = "MiniTwitter.Checks." + directory.lastPathComponent
        let configuration = ModelConfiguration(url: directory.appendingPathComponent("tweets.store"))
        let container = try ModelContainer(for: Tweet.self, configurations: configuration)
        let provider = TweetRepositoryProvider(metadataSuite: suite, api: NetworkFixtures.client())
        let repository = await provider.repository(for: container)
        let sameRepository = await provider.repository(for: container)
        require(repository === sameRepository, "Ожидается общий актор")

        switch phase {
        case "prepare":
            try await checkPrepare(container: container, provider: provider, repository: repository, suite: suite)

        case "reopen":
            try await checkReopen(repository: repository)

        case "verify-delete":
            try await checkVerifyDelete(repository: repository, suite: suite)

        default:
            preconditionFailure("Неизвестная фаза")
        }
    }

    @MainActor
    static func checkReopen(repository: TweetCacheRepository) async throws {
        let saved = try await repository.loadCachedTweets()
        require(saved.tweets.count == 28 && saved.lastServerSync != nil, "Данные не сохранились")
        require(saved.tweets.contains { $0.text == "Сохранено между процессами" }, "Update не сохранился")
        let favorite = saved.tweets.first { $0.serverID == NetworkFixtures.id(0) }!
        require(favorite.isFavorite && favorite.isLiked && favorite.likes == 11, "Отметки не сохранились")

        let page = try await NetworkFixtures.client().fetchPosts(page: 1, pageSize: 25)
        async let mergeA = repository.merge(page.items)
        async let mergeB = repository.merge(page.items)
        _ = try await (mergeA, mergeB)
        let merged = try await repository.loadCachedTweets()
        require(merged.tweets.count == 28, "Конкурентный merge создал дубликаты")
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<12 {
                group.addTask {
                    _ = try await repository.createTweet(text: "Параллельный твит \(index)")
                }
            }
            try await group.waitForAll()
        }
        let concurrent = try await repository.loadCachedTweets()
        require(concurrent.tweets.count == 40, "Конкурентная запись потеряла данные")
        let syncDate = concurrent.lastServerSync
        for tweet in concurrent.tweets where tweet.serverID == nil {
            _ = try await repository.delete(id: tweet.id)
        }
        let deleted = try await repository.loadCachedTweets()
        require(deleted.tweets.count == 26 && deleted.lastServerSync == syncDate, "Delete нарушил кэш")
        print("PASS: данные после перезапуска, конкурентный merge, 12 записей и Delete")
    }

    @MainActor
    static func checkVerifyDelete(repository: TweetCacheRepository, suite: String) async throws {
        let saved = try await repository.loadCachedTweets()
        require(saved.tweets.count == 26 && saved.tweets.allSatisfy { $0.serverID != nil },
                "Удаление не сохранилось")
        require(saved.tweets.contains { $0.isFavorite && $0.isLiked }, "Избранное потеряно")
        UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite)
        print("PASS: удаление и избранное сохраняются между процессами")
    }

    @MainActor
    static func checkPrepare(container: ModelContainer, provider: TweetRepositoryProvider,
                             repository: TweetCacheRepository, suite: String) async throws {
        let legacy = try await repository.loadCachedTweets()
        require(legacy.tweets.count == 1 && legacy.tweets[0].text == "Твит из предыдущей версии",
                "Миграция потеряла старый твит")
        require(legacy.tweets[0].serverID == nil && !legacy.tweets[0].isFavorite
                && !legacy.tweets[0].isLiked && legacy.tweets[0].likes == 0, "Неверные defaults миграции")
        require(legacy.lastUpdate != nil && legacy.lastServerSync == nil, "Перепутаны метаданные")
        try await checkNetwork()
        try await checkCancellation(suite: suite + ".cancel")

        let viewModel = TweetsViewModel()
        await viewModel.loadCache(using: container, provider: provider)
        require(viewModel.tweets.count == 26 && viewModel.canLoadMore
                && viewModel.networkError == nil, "Первая страница")
        await viewModel.loadMore()
        require(viewModel.tweets.count == 27 && !viewModel.canLoadMore, "Пагинация")
        await viewModel.refresh()
        require(viewModel.tweets.count == 27, "Повторный GET создал дубликаты")

        try await checkRemoteTweet(viewModel: viewModel, repository: repository)

        let syncDate = viewModel.lastServerSync
        try await viewModel.createTweet(text: "Проверка создания")
        let created = viewModel.tweets.first { $0.text == "Проверка создания" }!
        try await viewModel.update(id: created.id, text: "Сохранено между процессами")
        require(viewModel.tweets.count == 28 && viewModel.lastServerSync == syncDate,
                "Локальный CRUD изменил дату GET")
        do {
            try await viewModel.createTweet(text: "  \n ")
            preconditionFailure("Пустой твит должен быть отклонён")
        } catch TweetCacheError.emptyText {
            print("PASS: пустой твит отклонён")
        }
        require(!viewModel.isSaving, "Ошибка оставила блокировку")

        await checkOfflineAndPostFailure(container: container, suite: suite, syncDate: syncDate)
        print("PASS: миграция, GET/POST, JSON, ошибки, отмена, пагинация, избранное, лайки и локальный CRUD")
    }

    @MainActor
    static func checkRemoteTweet(viewModel: TweetsViewModel, repository: TweetCacheRepository) async throws {
        let remote = viewModel.tweets.first { $0.serverID == NetworkFixtures.id(0) }!
        await viewModel.toggleFavorite(id: remote.id)
        viewModel.filter = .favorites
        require(viewModel.visibleTweets.count == 1, "Фильтр избранного")
        async let firstLike: Void = viewModel.like(remote)
        async let secondLike: Void = viewModel.like(remote)
        _ = await (firstLike, secondLike)
        await viewModel.like(remote)
        let requests = StubURLProtocol.recorder.snapshot()
        require(requests.filter { $0.httpMethod == "POST" && $0.url?.host == "good.test" }.count == 2,
                "Повторный лайк был отправлен: ожидается один POST клиента в checkNetwork и один из VM")
        await viewModel.refresh()
        let updated = viewModel.tweets.first { $0.id == remote.id }!
        require(updated.isFavorite && updated.isLiked && updated.likes == 11,
                "Обновление потеряло избранное или откатило лайк")
        do {
            try await viewModel.update(id: remote.id, text: "Недопустимая правка")
            preconditionFailure("Серверный твит должен быть read-only")
        } catch TweetCacheError.readOnly {
            print("PASS: серверный твит нельзя изменить")
        }
        do {
            _ = try await repository.delete(id: remote.id)
            preconditionFailure("Серверный твит нельзя удалить")
        } catch TweetCacheError.readOnly {
            print("PASS: серверный твит нельзя удалить")
        }

    }

    @MainActor
    static func checkOfflineAndPostFailure(container: ModelContainer, suite: String, syncDate: Date?) async {
        let offline = TweetsViewModel()
        await offline.loadCache(using: container,
                                provider: TweetRepositoryProvider(
                                    metadataSuite: suite, api: NetworkFixtures.client("offline.test")
                                ))
        require(offline.tweets.count == 28 && offline.canEdit && offline.networkError != nil,
                "Ошибка GET скрыла кэш")
        require(offline.lastServerSync == syncDate, "Неуспешный GET изменил дату синхронизации")

        let failure = TweetsViewModel()
        await failure.loadCache(using: container,
                                provider: TweetRepositoryProvider(
                                    metadataSuite: suite, api: NetworkFixtures.client("post-error.test")
                                ))
        let unliked = failure.tweets.first { $0.serverID == NetworkFixtures.id(1) }!
        await failure.like(unliked)
        require(failure.errorMessage != nil && !failure.isLiked(unliked), "Ошибка POST учтена как успех")
        require(StubURLProtocol.recorder.snapshot().filter {
            $0.url?.host == "post-error.test" && $0.httpMethod == "POST"
        }.count == 1, "POST автоматически повторился")
    }

    @MainActor
    static func checkNetwork() async throws {
        let client = NetworkFixtures.client()
        let page = try await client.fetchPosts(page: 1, pageSize: 2)
        require(page.items.count == 2 && page.hasNextPage, "Парсинг страницы")
        require(page.items[0].authorDisplayName == nil && page.items[1].authorDisplayName != nil, "null имя")
        require(page.items[0].publishedAt > page.items[1].publishedAt, "Парсинг дат")
        let like = try await client.likePost(id: NetworkFixtures.id(0))
        require(like.postId == NetworkFixtures.id(0) && like.likes == 11, "Парсинг ответа POST")
        let post = StubURLProtocol.recorder.snapshot().last!
        require(post.httpMethod == "POST" && post.httpBody == nil && post.httpBodyStream == nil, "Формат POST")
        require(post.value(forHTTPHeaderField: "Accept") == "application/json", "Заголовок Accept")
        let empty = try await NetworkFixtures.client("empty.test").fetchPosts(page: 1, pageSize: 25)
        require(empty.items.isEmpty && !empty.hasNextPage, "Пустая страница")

        let errors: [(String, TwitterAPIError)] = [
            ("offline.test", .offline), ("timeout.test", .timeout), ("http.test", .http(500)),
            ("malformed.test", .decoding), ("bad-date.test", .decoding),
            ("missing-field.test", .decoding), ("bad-page.test", .invalidResponse)
        ]
        for (host, expected) in errors {
            do {
                _ = try await NetworkFixtures.client(host).fetchPosts(page: 1, pageSize: 25)
                preconditionFailure("Ожидалась ошибка \(host)")
            } catch let error as TwitterAPIError {
                require(error == expected, "Неверная ошибка \(host): \(error)")
            }
        }
        do {
            _ = try await NetworkFixtures.client("wrong-id.test").likePost(id: NetworkFixtures.id(0))
            preconditionFailure("Ответ другого поста должен быть отклонён")
        } catch TwitterAPIError.invalidResponse {
            print("PASS: ответ другого поста отклонён")
        }
        do {
            _ = try await NetworkFixtures.client("cancelled.test").fetchPosts(page: 1, pageSize: 25)
            preconditionFailure("Ожидалась отмена")
        } catch is CancellationError {
            print("PASS: отмена запроса обработана")
        }
    }

    @MainActor
    static func checkCancellation(suite: String) async throws {
        defer { UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite) }
        let container = try ModelContainer(for: Tweet.self,
                                          configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let provider = TweetRepositoryProvider(metadataSuite: suite, api: SlowAPI())
        let viewModel = TweetsViewModel()
        let loading = Task { await viewModel.loadCache(using: container, provider: provider) }
        try await Task.sleep(for: .milliseconds(200))
        require(viewModel.isRefreshing && viewModel.canEdit, "Во время сети локальные данные должны быть доступны")
        loading.cancel()
        await loading.value
        require(viewModel.networkError == nil && !viewModel.isRefreshing
                && viewModel.lastServerSync == nil, "Обработка отмены")
        await viewModel.loadCache(using: container,
                           provider: TweetRepositoryProvider(metadataSuite: suite, api: NetworkFixtures.client()))
        require(viewModel.tweets.count == 25 && viewModel.networkError == nil, "Повтор после отмены")
    }
}
