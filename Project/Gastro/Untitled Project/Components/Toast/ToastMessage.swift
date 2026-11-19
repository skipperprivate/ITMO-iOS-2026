import Foundation

struct ToastMessage: Equatable, Identifiable {
    let id = UUID()
    let text: String
}
