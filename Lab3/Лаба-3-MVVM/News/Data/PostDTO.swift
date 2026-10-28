// описание данных в API

import Foundation

struct PostsResponseDTO: Decodable, Sendable {
    let posts: [PostDTO]
}

struct PostDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let body: String
}
