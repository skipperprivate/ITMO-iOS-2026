import Foundation
import SwiftData

@Model
nonisolated final class Tweet {
    @Attribute(.unique)
    var id: UUID
    var name: String
    var username: String
    var text: String
    var createdAt: Date
    var avatarColor: String
    var serverID: UUID?
    var likes: Int = 0
    var isFavorite: Bool = false
    var isLiked: Bool = false

    init(
        name: String,
        username: String,
        text: String,
        avatarColor: String,
        id: UUID = UUID(),
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.text = text
        self.createdAt = createdAt
        self.avatarColor = avatarColor
    }

    var relativeTime: String {
        createdAt.formatted(.relative(presentation: .numeric))
    }
}
