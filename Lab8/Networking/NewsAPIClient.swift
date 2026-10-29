import Foundation

struct NewsAPIClient {
    func fetchPosts(start: Int, limit: Int) async throws -> [APIPost] {
        guard let url = URL(
            string: "https://jsonplaceholder.typicode.com/posts?_start=\(start)&_limit=\(limit)"
        ) else {
            throw NewsAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse else {
            throw NewsAPIError.invalidResponse
        }

        guard response.statusCode == 200 else {
            throw NewsAPIError.serverError(response.statusCode)
        }

        do {
            return try JSONDecoder().decode([APIPost].self, from: data)
        } catch {
            throw NewsAPIError.invalidData
        }
    }

    func createPost(title: String, text: String) async throws -> APIPost {
        guard let url = URL(
            string: "https://jsonplaceholder.typicode.com/posts"
        ) else {
            throw NewsAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let post = CreatePostRequest(
            title: title,
            body: text,
            userId: 1
        )

        request.httpBody = try JSONEncoder().encode(post)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw NewsAPIError.invalidResponse
        }

        guard response.statusCode == 201 else {
            throw NewsAPIError.serverError(response.statusCode)
        }

        do {
            return try JSONDecoder().decode(APIPost.self, from: data)
        } catch {
            throw NewsAPIError.invalidData
        }
    }
}
