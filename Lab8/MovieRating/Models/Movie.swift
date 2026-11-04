import Foundation


nonisolated struct Movie: Equatable {
    let id: Int
    let title: String
    let originalTitle: String
    let year: Int
    let genre: String
    let rating: Double
    let overview: String
    let posterURL: URL?
}
