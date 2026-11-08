import SwiftUI

struct CityRow: View {
    let city: City
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .foregroundStyle(.primary)
                Text(city.locationDetails)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .accessibilityLabel("Выбранный город")
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
