import Foundation

// Значения, которые можно безопасно передавать между actors.
struct RemoteArticle: Sendable, Equatable {
    let id: String
    let title: String
    let body: String
    let authorID: Int
    let tags: [String]
}

struct NewPost: Encodable, Sendable {
    let title: String
    let body: String
    // Учебный пользователь API; авторизация в этой лабораторной не реализуется.
    let userId: Int
}

struct CreatedPost: Sendable {
    let id: Int
    let title: String
    let body: String
    let authorID: Int
}
