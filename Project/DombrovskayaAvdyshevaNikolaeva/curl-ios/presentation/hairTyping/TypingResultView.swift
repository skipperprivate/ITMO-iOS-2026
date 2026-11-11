import SwiftUI

struct TypingResultView: View {
    enum Action {
        case save
        case skip
    }

    let resultTitle: String
    let onAction: (Action) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Ваш результат")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(.curlyDarkGreen))

            Text(resultTitle.capitalized)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(.curlyOrange))

            Spacer()

            Button("Сохранить результат") { onAction(.save) }
                .buttonStyle(PrimaryButtonStyle())

            Button("Не сохранять") { onAction(.skip) }
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding(24)
    }
}
