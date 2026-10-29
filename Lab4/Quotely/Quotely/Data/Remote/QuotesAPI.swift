//
//  QuotesAPI.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 26.09.2026.
//

import Foundation

struct QuotesAPI {
    struct RemoteQuote: Decodable {
        let id: Int
        let quote: String
        let author: String
    }

    struct Page: Decodable {
        let quotes: [RemoteQuote]
        let total: Int
    }

    func fetchPage(limit: Int = 20, skip: Int = 0) async throws -> Page {
        var components = URLComponents(string: "https://dummyjson.com/quotes")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "skip", value: String(skip))
        ]

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        return try JSONDecoder().decode(Page.self, from: data)
    }
}
