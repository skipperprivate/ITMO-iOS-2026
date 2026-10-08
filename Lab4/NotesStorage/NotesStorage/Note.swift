import Foundation
import SwiftData

@Model
class Note {
    var text: String

    init(text: String) {
        self.text = text
    }
}
