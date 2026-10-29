import Foundation
import SwiftData

@Model
nonisolated final class Tweet {
    @Attribute(.unique) var id: UUID
    var name: String
    var username: String
    var text: String
    var createdAt: Date
    var avatarColor: String

    init() {
        id = UUID(uuidString: "99999999-9999-9999-9999-999999999999")!
        name = "Вы"
        username = "@you"
        text = "Твит из предыдущей версии"
        createdAt = .now
        avatarColor = "blue"
    }
}

@main
struct LegacyStore {
    @MainActor
    static func main() throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1])
        let configuration = ModelConfiguration(url: directory.appendingPathComponent("tweets.store"))
        let container = try ModelContainer(for: Tweet.self, configurations: configuration)
        container.mainContext.insert(Tweet())
        try container.mainContext.save()
        UserDefaults(suiteName: "MiniTwitter.Checks." + directory.lastPathComponent)?
            .set(Date(timeIntervalSince1970: 1789999000), forKey: "tweetsCacheLastUpdate")
        print("PASS: создана база предыдущей версии для проверки миграции")
    }
}
