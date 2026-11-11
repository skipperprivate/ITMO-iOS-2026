import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.91, green: 0.34, blue: 0.20)
    static let background = Color(uiColor: .systemGroupedBackground)

    static let gradient = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.56, blue: 0.31),
            Color(red: 0.86, green: 0.22, blue: 0.18)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
