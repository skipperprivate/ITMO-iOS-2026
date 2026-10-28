import SwiftUI

struct NewsCardView: View {
    let item: Item
    let showDates: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.category.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.tint)
            Text(item.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            Text(item.text)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundStyle(.secondary)
            HStack {
                Text(item.source)
                if showDates {
                    Text("·")
                    Text(item.timestamp, format: .dateTime.day().month().hour().minute())
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}
