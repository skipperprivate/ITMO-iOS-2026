import Foundation
 
protocol NewsRemoteDataSource: Sendable {
    func fetchNews() async throws -> [PostDTO]
}
 
enum NetworkError: LocalizedError, Sendable {
 
    case invalidURL
    case invalidResponse
    case httpError(Int)
 
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL"
 
        case .invalidResponse:
            return "Сервер вернул некорректный ответ"
 
        case .httpError(let code):
            return "Ошибка сервера. Код: \(code)"
        }
    }
}
 
struct DummyJSONNewsRemoteDataSource: NewsRemoteDataSource {
 
    func fetchNews() async throws -> [PostDTO] {
 
        guard let url = URL(
            string: "https://dummyjson.com/posts?limit=20"
        ) else {
            throw NetworkError.invalidURL
        }
 
        let (data, response) = try await URLSession.shared.data(from: url)
 
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
 
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
 
        let responseDTO = try JSONDecoder().decode(
            PostsResponseDTO.self,
            from: data
        )
 
        return responseDTO.posts
    }
}
