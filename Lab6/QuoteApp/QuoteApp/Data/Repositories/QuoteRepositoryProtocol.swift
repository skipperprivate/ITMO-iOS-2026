//
//  QuoteRepositoryProtocol.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation

protocol QuoteRepositoryProtocol {
    func fetchRandomQuote() async throws -> Quote
    func fetchQuotes(offset: Int, limit: Int) async throws -> [Quote]
}

class QuoteRepository: QuoteRepositoryProtocol {
    private let network: NetworkClientProtocol
    
    init(network: NetworkClientProtocol) {
        self.network = network
    }
    
    func fetchRandomQuote() async throws -> Quote {
        let dto: QuoteDTO = try await network.request(Endpoint(path: "/quotes/random"))
        return dto.toDomain()
    }
    
    func fetchQuotes(offset: Int, limit: Int) async throws -> [Quote] {
        let dto: QuoteListDTO = try await network.request(
            Endpoint(path: "/quotes", queryItems: [
                URLQueryItem(name: "skip", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)")])
        )
        return dto.quotes.map { $0.toDomain() }
    }
}
