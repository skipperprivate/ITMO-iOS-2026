import Foundation

struct Question: Identifiable {
    let id = UUID()
    let topic: String
    var answers: [Answer]
    var selectedIndex: Int?
}
