import Combine
import Foundation

@MainActor
class MyPostsViewModel: ObservableObject {
    @Published private(set) var posts: [News] = []
    @Published private(set) var errorMessage: String?

    private let storage: any NewsStorage

    init(storage: any NewsStorage) {
        self.storage = storage

        do {
            posts = try storage.load()
        } catch {
            errorMessage = "Не удалось прочитать мои посты."
        }
    }

    convenience init() {
        self.init(storage: FileNewsStorage(filename: "myPosts.json"))
    }

    func add(_ post: APIPost) throws {
        let item = News(
            id: (posts.map(\.id).max() ?? 0) + 1,
            title: post.title,
            text: post.body
        )
        let updatedPosts = [item] + posts

        try storage.save(updatedPosts)
        posts = updatedPosts
        errorMessage = nil
    }
}