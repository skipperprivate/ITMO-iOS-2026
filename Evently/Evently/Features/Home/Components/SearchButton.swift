import SwiftUI

struct SearchButton: View {

    var body: some View {
        NavigationLink(value: AppRoute.search) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                Text("Поиск мероприятий")
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
    }
}
