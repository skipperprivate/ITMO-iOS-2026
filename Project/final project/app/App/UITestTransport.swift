#if DEBUG
import Foundation

actor UITestTransport: HTTPTransport {
    private var shouldFail: Bool
    init(failFirstRequest: Bool) { shouldFail = failFirstRequest }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if shouldFail {
            shouldFail = false
            throw URLError(.notConnectedToInternet)
        }
        guard let url = request.url else { throw URLError(.badURL) }
        let data: Data
        let statusCode: Int
        if request.httpMethod == "POST", url.path == "/posts/add" {
            guard let body = request.httpBody else { throw URLError(.badServerResponse) }
            let post = try JSONDecoder().decode(TestPost.self, from: body)
            data = try JSONEncoder().encode(TestPost(id: 251, title: post.title,
                                                    body: post.body, userId: post.userId))
            statusCode = 201
        } else if request.httpMethod == "GET", url.path == "/posts" {
            let json = #"{"posts":[{"id":101,"title":"Тестовая новость","body":"Полный текст тестовой новости.","userId":1,"tags":["technology"]}]}"#
            data = Data(json.utf8)
            statusCode = 200
        } else {
            throw URLError(.unsupportedURL)
        }
        guard let response = HTTPURLResponse(url: url, statusCode: statusCode,
                                             httpVersion: nil, headerFields: nil) else {
            throw URLError(.badURL)
        }
        return (data, response)
    }
}
private struct TestPost: Codable {
    var id: Int?
    let title: String
    let body: String
    let userId: Int
}
#endif
