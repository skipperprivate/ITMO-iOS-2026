import SwiftUI

struct OfflineView: View {
    let onRetry: () -> Void
    let onShowViewedFacts: () -> Void

    private let accent = Color(
        red: 0.72,
        green: 0.48,
        blue: 0.57
    )

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Иконка отсутствия интернета
            Image(systemName: "wifi.slash")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(accent)
                .frame(width: 150, height: 150)
                .background(
                    accent.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: 42)
                )
                .padding(.bottom, 36)

            // Заголовок
            Text("Нет подключения\nк интернету")
                .font(.custom(
                    "Montserrat-SemiBold",
                    size: 25,
                    relativeTo: .title2
                ))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(.bottom, 14)

            // Описание
            Text(
                "Не удалось загрузить информацию о фильме. " +
                "Проверьте соединение и попробуйте снова."
            )
            .font(.custom(
                "Montserrat-Regular",
                size: 14,
                relativeTo: .body
            ))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 36)

            // Повторная загрузка
            Button(action: onRetry) {
                Label("Повторить", systemImage: "arrow.clockwise")
                    .font(.custom(
                        "Montserrat-Medium",
                        size: 15
                    ))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .foregroundStyle(.white)
                    .background(
                        accent,
                        in: RoundedRectangle(cornerRadius: 18)
                    )
            }
            .buttonStyle(.plain)

            // Просмотр сохранённых фактов
            Button(action: onShowViewedFacts) {
                Label(
                    "Просмотренные факты",
                    systemImage: "clock.arrow.circlepath"
                )
                .font(.custom(
                    "Montserrat-Medium",
                    size: 15
                ))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .foregroundStyle(accent)
                .background(
                    accent.opacity(0.06),
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            accent.opacity(0.25),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 12)

            Text("Сохранённые факты доступны без интернета")
                .font(.custom(
                    "Montserrat-Regular",
                    size: 12
                ))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Spacer()
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
