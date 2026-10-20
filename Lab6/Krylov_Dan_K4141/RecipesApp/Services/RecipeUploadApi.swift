import Foundation

struct RecipeUploadBody: Encodable {
    let title: String
    let ingredients: [String]
    let steps: [String]
    let category: String
}

struct RecipeUploadResponse: Decodable {
    let id: Int
    let title: String
}

enum RecipeUploadAPI {
    private static let address = "https://jsonplaceholder.typicode.com/posts"

    static func upload(_ body: RecipeUploadBody) async throws -> RecipeUploadResponse {
        let url = try NetworkClient.makeURL(address)
        return try await NetworkClient.post(url, body: body)
    }
}
