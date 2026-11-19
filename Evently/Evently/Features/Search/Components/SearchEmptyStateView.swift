import SwiftUI

struct SearchEmptyStateView: View {

    let title: LocalizedStringResource
    let description: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(
                    size: 42,
                    weight: .regular
                ))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.system(
                    size: 20,
                    weight: .semibold
                ))
                .foregroundStyle(.white)

            Text(description)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }
}
