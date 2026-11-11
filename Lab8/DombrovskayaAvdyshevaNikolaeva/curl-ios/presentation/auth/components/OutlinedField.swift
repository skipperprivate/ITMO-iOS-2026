import SwiftUI

struct OutlinedField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.curlyDarkGreen, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
