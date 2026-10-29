import Foundation

nonisolated struct TweetDTO: Identifiable, Sendable {
    let id: UUID
    let name: String
    let username: String
    let text: String
    let createdAt: Date
    let avatarColor: String
    let serverID: UUID?
    let likes: Int
    let isFavorite: Bool
    let isLiked: Bool

    init(id: UUID = UUID(), name: String, username: String, text: String,
         createdAt: Date = .now, avatarColor: String, serverID: UUID? = nil,
         likes: Int = 0, isFavorite: Bool = false, isLiked: Bool = false) {
        self.id = id
        self.name = name
        self.username = username
        self.text = text
        self.createdAt = createdAt
        self.avatarColor = avatarColor
        self.serverID = serverID
        self.likes = likes
        self.isFavorite = isFavorite
        self.isLiked = isLiked
    }

    var relativeTime: String {
        createdAt.formatted(.relative(presentation: .numeric))
    }
}

nonisolated struct TweetCacheSnapshot: Sendable {
    let tweets: [TweetDTO]
    let lastUpdate: Date?
    let lastServerSync: Date?
    let revision: UInt64
}
