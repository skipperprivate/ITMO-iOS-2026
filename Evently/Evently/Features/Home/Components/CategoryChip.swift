import SwiftUI

struct CategoryChip: View {

    let category: EventCategoryRu
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: category.iconName)
                    .font(.system(size: 13, weight: .semibold))

                Text(category.rawValue)
                    .font(.system(
                        size: 14,
                        weight: .semibold
                    ))
            }
            .foregroundStyle(
                isSelected
                ? Color.black
                : Color.white
            )
            .padding(.horizontal, 16)
            .frame(height: 42)
            .background(
                isSelected
                ? Color.white
                : Color.white.opacity(0.09)
            )
            .clipShape(
                Capsule()
            )
        }
        .buttonStyle(.plain)
    }
}
