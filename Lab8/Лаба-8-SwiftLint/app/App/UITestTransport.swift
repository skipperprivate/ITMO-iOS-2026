#if DEBUG
import Foundation

// Только для UI-тестов: реальный клиент декодирует контролируемые HTTP-ответы.
actor UITestTransport: HTTPTransport {
    private var shouldFail: Bool
    init(failFirstRequest: Bool) { shouldFail = failFirstRequest }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if shouldFail {
            shouldFail = false
            throw URLError(.notConnectedToInternet)
        }
        let json = #"{"posts":[{"id":101,"title":"Тестовая новость","body":"Полный текст тестовой новости.","userId":1,"tags":["technology"]}]}"#
        guard let url = request.url,
              let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
            throw URLError(.badURL)
        }
        return (Data(json.utf8), response)
    }
}
#endif
