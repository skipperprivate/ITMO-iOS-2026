import Foundation
import SwiftData

@Model
final class SavedQuote {
    var id: Int
    var text: String
    var author: String

    var isFavorite: Bool = false
    var isInHistory: Bool = true

    var createdAt: Date = Date()

    init(
        id: Int,
        text: String,
        author: String,
        isFavorite: Bool = false,
        isInHistory: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.isFavorite = isFavorite
        self.isInHistory = isInHistory
        self.createdAt = createdAt
    }
}
