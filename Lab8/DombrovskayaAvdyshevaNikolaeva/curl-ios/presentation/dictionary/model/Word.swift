import Foundation

struct Word: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
}
