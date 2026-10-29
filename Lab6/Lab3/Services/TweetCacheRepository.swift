import Foundation
import SwiftData

nonisolated struct CacheMetadata {
    private let defaults: UserDefaults
    private let key = "tweetsCacheLastUpdate"
    private let syncKey = "tweetsLastServerSync"

    init(suiteName: String?) {
        defaults = suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    var lastUpdate: Date? { defaults.object(forKey: key) as? Date }
    var lastServerSync: Date? { defaults.object(forKey: syncKey) as? Date }

    func markCacheUpdated(serverSync: Bool) {
        let now = Date.now
        defaults.set(now, forKey: key)
        if serverSync { defaults.set(now, forKey: syncKey) }
    }
}

nonisolated enum TweetCacheError: LocalizedError {
    case tweetNotFound
    case emptyText
    case notReady
    case readOnly

    var errorDescription: String? {
        switch self {
        case .tweetNotFound: "Твит уже удалён. Откройте ленту повторно."
        case .emptyText: "Введите текст твита."
        case .notReady: "Дождитесь завершения текущей операции."
        case .readOnly: "Серверные твиты нельзя редактировать или удалять."
        }
    }
}

@ModelActor
actor TweetCacheRepository {
    private var metadataSuite: String?
    private var revision: UInt64 = 0
    private var metadata: CacheMetadata { CacheMetadata(suiteName: metadataSuite) }

    init(modelContainer: ModelContainer, metadataSuite: String?) {
        assert(!Thread.isMainThread)
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = false
        self.modelContainer = modelContainer
        self.modelExecutor = BackgroundModelExecutor(modelContext: context)
        self.metadataSuite = metadataSuite
    }

    func loadCachedTweets() throws -> TweetCacheSnapshot {
        try Task.checkCancellation()
        return try snapshot()
    }

    func merge(_ posts: [RemotePost]) throws -> TweetCacheSnapshot {
        try commit(serverSync: true) {
            let existing = try modelContext.fetch(FetchDescriptor<Tweet>())
            var byServerID: [UUID: Tweet] = [:]
            for tweet in existing {
                if let serverID = tweet.serverID { byServerID[serverID] = tweet }
            }
            for post in posts {
                let tweet: Tweet
                if let cached = byServerID[post.id] {
                    tweet = cached
                } else {
                    tweet = Tweet(name: "", username: "", text: "", avatarColor: "blue")
                    tweet.serverID = post.id
                    modelContext.insert(tweet)
                    byServerID[post.id] = tweet
                }
                tweet.name = post.authorDisplayName ?? post.authorUsername
                tweet.username = post.authorUsername.hasPrefix("@") ? post.authorUsername : "@" + post.authorUsername
                tweet.text = post.text
                tweet.createdAt = post.publishedAt
                tweet.likes = max(tweet.likes, post.likes)
            }
        }
    }

    func createTweet(text: String) throws -> TweetCacheSnapshot {
        let text = try validated(text)
        return try commit {
            modelContext.insert(Tweet(name: "Вы", username: "@you", text: text, avatarColor: "blue"))
        }
    }

    func update(id: UUID, text: String) throws -> TweetCacheSnapshot {
        let text = try validated(text)
        return try commit {
            let tweet = try findTweet(id: id)
            guard tweet.serverID == nil else { throw TweetCacheError.readOnly }
            tweet.text = text
        }
    }

    func delete(id: UUID) throws -> TweetCacheSnapshot {
        try commit {
            let tweet = try findTweet(id: id)
            guard tweet.serverID == nil else { throw TweetCacheError.readOnly }
            modelContext.delete(tweet)
        }
    }

    func toggleFavorite(id: UUID) throws -> TweetCacheSnapshot {
        try commit {
            try findTweet(id: id).isFavorite.toggle()
        }
    }

    func recordLike(_ response: LikeResponse) throws -> TweetCacheSnapshot {
        try commit {
            let serverID = response.postId
            let descriptor = FetchDescriptor<Tweet>(predicate: #Predicate { $0.serverID == serverID })
            guard let tweet = try modelContext.fetch(descriptor).first else {
                throw TweetCacheError.tweetNotFound
            }
            tweet.likes = max(tweet.likes, response.likes)
            tweet.isLiked = true
        }
    }

    private func findTweet(id: UUID) throws -> Tweet {
        let descriptor = FetchDescriptor<Tweet>(predicate: #Predicate { $0.id == id })
        guard let tweet = try modelContext.fetch(descriptor).first else {
            throw TweetCacheError.tweetNotFound
        }
        return tweet
    }

    private func validated(_ text: String) throws -> String {
        let result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !result.isEmpty else { throw TweetCacheError.emptyText }
        return result
    }

    private func commit(serverSync: Bool = false, _ mutation: () throws -> Void) throws -> TweetCacheSnapshot {
        try Task.checkCancellation()
        do {
            try mutation()
            let tweets = try snapshot().tweets
            try modelContext.save()
            metadata.markCacheUpdated(serverSync: serverSync)
            revision += 1
            return TweetCacheSnapshot(tweets: tweets, lastUpdate: metadata.lastUpdate,
                                      lastServerSync: metadata.lastServerSync, revision: revision)
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private func snapshot() throws -> TweetCacheSnapshot {
        assert(!Thread.isMainThread)
        let descriptor = FetchDescriptor<Tweet>(
            sortBy: [SortDescriptor(\Tweet.createdAt, order: .reverse)]
        )
        let tweets = try modelContext.fetch(descriptor).map {
            TweetDTO(id: $0.id, name: $0.name, username: $0.username, text: $0.text,
                     createdAt: $0.createdAt, avatarColor: $0.avatarColor, serverID: $0.serverID,
                     likes: $0.likes, isFavorite: $0.isFavorite, isLiked: $0.isLiked)
        }
        return TweetCacheSnapshot(tweets: tweets, lastUpdate: metadata.lastUpdate,
                                  lastServerSync: metadata.lastServerSync, revision: revision)
    }
}
