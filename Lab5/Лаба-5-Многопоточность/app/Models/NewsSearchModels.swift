import Foundation

// Передаём значения, а не SwiftData-модели: их контекст остаётся на MainActor.
typealias NewsSearchDocument = (title: String, text: String)
typealias NewsSearchResult = (indices: [Int], ranInBackground: Bool)

