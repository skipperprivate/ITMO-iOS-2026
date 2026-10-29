import Foundation

actor MockTweetsAPI: TwitterAPI {
    private var likes: [UUID: Int] = [:]

    func fetchPosts(page: Int, pageSize: Int) async throws -> PostsPage {
        try await Task.sleep(for: .milliseconds(200))
        let posts = Self.posts.map {
            RemotePost(id: $0.id, authorUsername: $0.authorUsername,
                       authorDisplayName: $0.authorDisplayName, text: $0.text,
                       publishedAt: $0.publishedAt, likes: likes[$0.id] ?? $0.likes)
        }
        let start = min((page - 1) * pageSize, posts.count)
        let end = min(start + pageSize, posts.count)
        return PostsPage(page: page, pageSize: pageSize, total: posts.count, items: Array(posts[start..<end]))
    }

    func likePost(id: UUID) async throws -> LikeResponse {
        try await Task.sleep(for: .milliseconds(200))
        guard let post = Self.posts.first(where: { $0.id == id }) else { throw TwitterAPIError.http(404) }
        let count = (likes[id] ?? post.likes) + 1
        likes[id] = count
        return LikeResponse(postId: id, likes: count)
    }

    nonisolated static var posts: [RemotePost] {
        [
            RemotePost(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                       authorUsername: "annasmirnova", authorDisplayName: "Анна Смирнова",
                       text: "Доброе утро! Сегодня отличный день, чтобы начать что-то новое.",
                       publishedAt: Date(timeIntervalSince1970: 1790000000), likes: 2),
            RemotePost(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                       authorUsername: "mariakim", authorDisplayName: "Мария Ким",
                       text: "Доброе утро! Сегодня отличный день, чтобы начать что-то новое.",
                       publishedAt: Date(timeIntervalSince1970: 1789999000), likes: 0)
        ]
    }
}
