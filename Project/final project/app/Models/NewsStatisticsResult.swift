import Foundation

struct NewsStatisticsResult: Sendable, Equatable {
    let articles: Int
    let words: Int
    let characters: Int
}
