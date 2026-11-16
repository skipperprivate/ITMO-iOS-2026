import SwiftUI

struct RecipeStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 4) {
                stepButton("minus", enabled: value > range.lowerBound) {
                    value -= 1
                }
                stepButton("plus", enabled: value < range.upperBound) {
                    value += 1
                }
            }
        }
    }

    private func stepButton(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 44, height: 44)
                .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(RecipePressStyle())
        .disabled(!enabled)
    }
}

struct RecipePressStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(AppColors.accent)
            .background(configuration.isPressed ? AppColors.accentSoft : AppColors.background,
                        in: RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .opacity(isEnabled ? 1 : 0.35)
            .animation(configuration.isPressed ? nil : .easeOut(duration: 0.18), value: configuration.isPressed)
    }
}
