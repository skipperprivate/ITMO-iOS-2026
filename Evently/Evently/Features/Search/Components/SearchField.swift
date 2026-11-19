import SwiftUI

struct SearchField: View {

    @Binding var text: String

    @FocusState
    private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(
                    size: 18,
                    weight: .medium
                ))
                .foregroundStyle(.secondary)

            TextField(
                "search.placeholder",
                text: $text
            )
            .focused($isFocused)
            .foregroundStyle(.white)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                    isFocused = true
                } label: {
                    Image(
                        systemName: "xmark.circle.fill"
                    )
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            Color.white.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 17
            )
        )
        .padding(.horizontal, 20)
        .task {
            try? await Task.sleep(
                for: .milliseconds(300)
            )

            isFocused = true
        }
    }
}
