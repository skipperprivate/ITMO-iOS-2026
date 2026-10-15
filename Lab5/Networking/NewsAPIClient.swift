import Foundation

class NewsAPIClient {
    func fetchPosts() async throws -> [APIPost] {
        //throw URLError(.notConnectedToInternet)
        let userId = Int.random(in: 1...10)

        let url = URL(
            string: "https://jsonplaceholder.typicode.com/posts?userId=\(userId)"
        )!
        
        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            [APIPost].self,
            from: data
        )
    }
}
