import Foundation
import SwiftData

@Model
final class NumberEntry {
    @Attribute(.unique) var id: UUID
    var value: Int
    var date: Date
    
    init(value: Int, date: Date = Date()) {
        self.id = UUID()
        self.value = value
        self.date = date
    }
}
