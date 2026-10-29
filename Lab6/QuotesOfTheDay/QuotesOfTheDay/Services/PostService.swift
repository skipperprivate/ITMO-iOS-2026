import Foundation

final class PostService {

    func sendQuote(_ quote: Quote) async throws -> Post {

        guard let url = URL(
            string: "https://dummyjson.com/posts/add"
        ) else {
            throw URLError(.badURL)
        }

        let post = Post(
            id: nil,
            title: quote.author,
            body: quote.quote,
            userId: 1
        )

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = try JSONEncoder().encode(post)

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            Post.self,
            from: data
        )
    }
}
