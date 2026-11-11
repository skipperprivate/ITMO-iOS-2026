import SwiftUI

struct FeatureCard: View {
    let bgColor: Color
    let textColor: Color
    let title: String
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgColor)

                Text(title)
                    .font(.subTitleSerif)
                    .fontWeight(.semibold)
                    .foregroundStyle(textColor)
                    .padding(16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
        }
        .buttonStyle(.plain)
    }
}
