import SwiftUI

struct TypingFeatureCard: View {
    let icon: String
    let title: String
    var isMain: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isMain ? .white : Color(hex: "4A5B48"))
                    .frame(width: 40, height: 40)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(isMain ? .white : Color(hex: "4A5B48"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isMain ? .white.opacity(0.8) : Color(hex: "4A5B48").opacity(0.5))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(isMain ? Color(hex: "728C6A") : Color(hex: "EDE9E1"))
            .cornerRadius(30)
        }
    }
}
