import Foundation
import SwiftData

// Одна публикация, в SwiftData сохраняется её между запусками.
@Model
final class Item {
    var timestamp: Date
    var title: String = "Без заголовка"
    var text: String = ""
    var source: String = "Редакция"
    var category: String = "Общее"

    init(timestamp: Date = Date(), title: String = "Без заголовка", text: String = "",
         source: String = "Редакция", category: String = "Общее") {
        self.timestamp = timestamp
        self.title = title
        self.text = text
        self.source = source
        self.category = category
    }
}
