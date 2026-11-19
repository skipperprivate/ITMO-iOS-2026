nonisolated struct PublishRecipeRequestBody: Encodable, Sendable {
    let name: String
    let ingredients: [String]
    let instructions: [String]
    let cookTimeMinutes: Int?
}
