// POST /recipes/add echoes the submitted fields and assigns a demonstration ID.
// Decode only the fields required for publication confirmation.
nonisolated struct PublishRecipeResponse: Decodable, Sendable {
    let id: Int
    let name: String
}
