import SwiftUI

struct AvatarCell: View {

    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            avatarImage
        }
        .buttonStyle(.plain)
    }

    private var avatarImage: some View {
        Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .padding(8)
            .frame(width: 52, height: 52)
            .foregroundStyle(Color(.curlyDarkGreen))
            .background(backgroundColor)
            .clipShape(Circle())
            .overlay(borderOverlay)
    }

    private var backgroundColor: Color {
        isSelected
            ? Color(.curlyGreen).opacity(0.35)
            : Color(.curlySurface)
    }

    private var borderOverlay: some View {
        Circle()
            .stroke(borderColor, lineWidth: 1.5)
    }

    private var borderColor: Color {
        isSelected
            ? Color(.curlyGreen)
            : Color(.curlyDarkGreen).opacity(0.15)
    }
}
