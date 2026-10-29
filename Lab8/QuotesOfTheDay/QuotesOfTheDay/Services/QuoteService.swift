import Foundation

protocol QuoteServiceProtocol {
    func fetchRandomQuote() async throws -> Quote
    func fetchQuotes(limit: Int, skip: Int) async throws -> QuotesResponse
    func fetchQuote(id: Int) async throws -> Quote
}

final class QuoteService: QuoteServiceProtocol {

    nonisolated init() {}

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

    func fetchQuotes(limit: Int, skip: Int) async throws -> QuotesResponse {

        guard let url = URL(
            string: "https://dummyjson.com/quotes?limit=\(limit)&skip=\(skip)"
        ) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

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
            QuotesResponse.self,
            from: data
        )
    }

    func fetchQuote(id: Int) async throws -> Quote {

        guard let url = URL(
            string: "https://dummyjson.com/quotes/\(id)"
        ) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

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
            Quote.self,
            from: data
        )
    }
}
