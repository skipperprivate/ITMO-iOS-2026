import Combine
import Foundation
import SwiftData

nonisolated enum FeedFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case favorites = "Избранное"

    var id: Self { self }
}

@MainActor
final class TweetsViewModel: ObservableObject {
    @Published private(set) var tweets: [TweetDTO] = []
    @Published private(set) var lastCacheUpdate: Date?
    @Published private(set) var lastServerSync: Date?
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var isSaving = false
    @Published private(set) var isReady = false
    @Published private(set) var canLoadMore = false
    @Published private(set) var networkError: String?
    @Published private(set) var confirmedLikes: [UUID: Int] = [:]
    @Published var filter: FeedFilter = .all
    @Published var errorMessage: String?

    private var repository: TweetCacheRepository?
    private var api: any TwitterAPI = TwitterAPIClient()
    private var nextPage = 1
    private var retryPage = 1
    private var revision: UInt64 = 0
    private let pageSize = 25

    var canEdit: Bool { isReady && !isLoading && !isSaving }
    var visibleTweets: [TweetDTO] {
        filter == .favorites ? tweets.filter(\.isFavorite) : tweets
    }

    func loadCache(using container: ModelContainer, provider: TweetRepositoryProvider) async {
        guard !isLoading, !isSaving, !isRefreshing else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            api = provider.api
            let repository = await provider.repository(for: container)
            self.repository = repository
            let snapshot = try await repository.loadCachedTweets()
            try Task.checkCancellation()
            apply(snapshot)
            isReady = true
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Не удалось загрузить кэш: \(error.localizedDescription)"
            return
        }

        isLoading = false
        await refresh()
    }

    func refresh() async {
        await fetchPage(1)
    }

    func loadMore() async {
        guard canLoadMore else { return }
        await fetchPage(nextPage)
    }

    func retry() async {
        await fetchPage(retryPage)
    }

    func createTweet(text: String) async throws {
        try await perform { try await $0.createTweet(text: text) }
    }

    func update(id: UUID, text: String) async throws {
        try await perform { try await $0.update(id: id, text: text) }
    }

    func delete(id: UUID) async {
        do {
            try await perform { try await $0.delete(id: id) }
        } catch is CancellationError {
        } catch {
            errorMessage = "Не удалось удалить твит: \(error.localizedDescription)"
        }
    }

    func toggleFavorite(id: UUID) async {
        do {
            try await perform { try await $0.toggleFavorite(id: id) }
        } catch is CancellationError {
        } catch {
            errorMessage = "Не удалось изменить избранное: \(error.localizedDescription)"
        }
    }

    func isLiked(_ tweet: TweetDTO) -> Bool {
        tweet.isLiked || confirmedLikes[tweet.id] != nil
    }

    func displayedLikes(_ tweet: TweetDTO) -> Int {
        max(tweet.likes, confirmedLikes[tweet.id] ?? 0)
    }

    func like(_ tweet: TweetDTO) async {
        guard canEdit, let repository, let serverID = tweet.serverID, !isLiked(tweet) else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            let response = try await api.likePost(id: serverID)
            confirmedLikes[tweet.id] = response.likes
            let snapshot = try await repository.recordLike(response)
            apply(snapshot)
        } catch is CancellationError {
        } catch {
            if confirmedLikes[tweet.id] != nil {
                errorMessage = "Сервер принял лайк, но сохранить его на устройстве не удалось. \(error.localizedDescription)"
            } else {
                errorMessage = "Не удалось подтвердить лайк. \(error.localizedDescription) При обрыве связи сервер мог учесть запрос. Обновите ленту перед повторной попыткой."
            }
        }
    }

    private func fetchPage(_ page: Int) async {
        guard let repository, isReady, !isRefreshing else { return }
        isRefreshing = true
        networkError = nil
        defer { isRefreshing = false }

        do {
            let response = try await api.fetchPosts(page: page, pageSize: pageSize)
            try Task.checkCancellation()
            let snapshot = try await repository.merge(response.items)
            apply(snapshot)
            nextPage = page + 1
            canLoadMore = response.hasNextPage
        } catch is CancellationError {
        } catch {
            retryPage = page
            networkError = error.localizedDescription
        }
    }

    private func perform(
        _ operation: (TweetCacheRepository) async throws -> TweetCacheSnapshot
    ) async throws {
        guard canEdit, let repository else { throw TweetCacheError.notReady }
        isSaving = true
        defer { isSaving = false }
        let snapshot = try await operation(repository)
        apply(snapshot)
    }

    private func apply(_ snapshot: TweetCacheSnapshot) {
        guard snapshot.revision >= revision else { return }
        revision = snapshot.revision
        tweets = snapshot.tweets
        lastCacheUpdate = snapshot.lastUpdate
        lastServerSync = snapshot.lastServerSync
    }
}
