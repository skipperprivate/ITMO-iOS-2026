import SwiftUI

struct ErrorMessage: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.body)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
