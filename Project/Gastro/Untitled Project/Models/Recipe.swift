import Foundation
import SwiftData

@Model
final class Recipe {
    @Attribute(.unique) var id: UUID
    var title: String
    var ingredients: [String]
    var steps: [String]
    var cookingTimeMinutes: Int?
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), draft: RecipeDraft, createdAt: Date = .now) {
        self.id = id
        title = draft.title
        ingredients = draft.ingredients
        steps = draft.steps
        cookingTimeMinutes = draft.cookingTimeMinutes
        self.createdAt = createdAt
        updatedAt = createdAt
    }
}
