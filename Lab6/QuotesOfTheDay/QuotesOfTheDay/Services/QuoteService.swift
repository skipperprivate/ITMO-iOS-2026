import Foundation

final class QuoteService {

    func fetchRandomQuote() async throws -> Quote {

        guard let url = URL(
            string: "https://dummyjson.com/quotes/random"
        ) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let quote = try JSONDecoder().decode(
            Quote.self,
            from: data
        )

        return quote
    }
}
