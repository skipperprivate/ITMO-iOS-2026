import Foundation

// Базовая реализация сетевого сервиса
// После Лекции по теме планируется доработка обработки ошибок, отмены запросов и конфигурации URLSession

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
}

final class NetworkServiceImpl : NetworkService { // final = класс без наследования
    private let session: URLSession
    private let apiKey: String
    
    
    init(session: URLSession = .shared, apiKey: String
    ) {
        self.session = session
        self.apiKey = apiKey
    }
    
    func request<T: Decodable>(endpoint : Endpoint) async throws -> T {
        
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.setValue(
            apiKey,
            forHTTPHeaderField: "X-API-KEY"
        )
        
        // Асинхронное выполнение HTTP-запроса
        let (data, response) = try await session.data(for: request)
        
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode
        else {
            throw NetworkError.invalidResponse
        }
        
        
        return try JSONDecoder().decode( // "возьми полученные data и сформируй из них T"
            T.self,
            from: data
        )
    }
}
