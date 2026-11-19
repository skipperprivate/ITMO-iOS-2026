import Foundation

nonisolated struct FeedbackRequestDTO: Encodable, Sendable {
    let title: String
    let body: String
    let userId: Int
}

nonisolated struct FeedbackResponseDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}
