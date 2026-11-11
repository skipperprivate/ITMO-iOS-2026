import SwiftUI

struct PasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {
        HStack {
            Group {
                if isVisible {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye" : "eye.slash")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.curlyDarkGreen.opacity(0.6))
            }
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.curlyDarkGreen, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
