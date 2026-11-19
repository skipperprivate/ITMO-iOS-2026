import Foundation

nonisolated struct RemoteRecipe: Sendable {
    let id: Int
    let name: String
    let ingredients: [String]
    let instructions: [String]
    let image: URL?
    let prepTimeMinutes: Int?
    let cookTimeMinutes: Int?

    var totalTimeMinutes: Int? {
        guard prepTimeMinutes != nil || cookTimeMinutes != nil else { return nil }
        return (prepTimeMinutes ?? 0) + (cookTimeMinutes ?? 0)
    }
}
