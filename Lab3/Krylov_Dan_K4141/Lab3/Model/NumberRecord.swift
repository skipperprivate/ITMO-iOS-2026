import Foundation
import SwiftData

@Model
final class NumberRecord {
    var value: Int
    var createdAt: Date = Date()

    init(value: Int) {
        self.value = value
    }
}
