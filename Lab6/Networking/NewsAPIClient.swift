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

        let newPost = CreatePostRequest(
            title: title,
            body: text,
            userId: 1
        )

       
        request.httpBody = try JSONEncoder().encode(newPost)

       
        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NewsAPIError.invalidResponse
        }

        
        guard httpResponse.statusCode == 201 else {
            throw NewsAPIError.serverError(httpResponse.statusCode)
        }

        
        do {
            return try JSONDecoder().decode(
                APIPost.self,
                from: data
            )
        } catch {
            throw NewsAPIError.invalidData
        }
    }
}
