import Foundation

struct Quote: Codable, Identifiable {
    let id: Int
    let quote: String
    let author: String
}
