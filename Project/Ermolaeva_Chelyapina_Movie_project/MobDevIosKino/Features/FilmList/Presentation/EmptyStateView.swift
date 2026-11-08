import SwiftUI

struct EmptyStateView: View {
    let accent: Color
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "film.stack")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(accent)
                .frame(width: 110, height: 110)
                .background(
                    accent.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: 30)
                )

            Text("Ничего не найдено")
                .font(.title3.weight(.semibold))

            Text("Попробуйте изменить параметры поиска")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onReset) {
                Text("Сбросить фильтры")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        accent.opacity(0.10),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
