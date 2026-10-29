import Foundation

struct QuotesResponse: Codable {
    let quotes: [Quote]
    let total: Int
    let skip: Int
    let limit: Int
}
