import Foundation

nonisolated enum FeedSort: String, Sendable {
    case latest
    case popular
}

nonisolated struct PostsPage: Decodable, Sendable {
    let page: Int
    let pageSize: Int
    let total: Int
    let items: [RemotePost]

    var hasNextPage: Bool {
        !items.isEmpty && page < (total / pageSize + (total % pageSize == 0 ? 0 : 1))
    }
}

nonisolated struct RemotePost: Decodable, Sendable {
    let id: UUID
    let authorUsername: String
    let authorDisplayName: String?
    let text: String
    let publishedAt: Date
    let likes: Int
    let views: Int
}

nonisolated struct LikeResponse: Decodable, Sendable {
    let postId: UUID
    let likes: Int
}
