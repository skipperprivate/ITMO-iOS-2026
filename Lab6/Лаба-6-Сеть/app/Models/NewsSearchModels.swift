import Foundation

struct NewsSearchDocument: Sendable {
    let title: String
    let text: String
}

struct NewsSearchResult: Sendable {
    let indices: [Int]
}
