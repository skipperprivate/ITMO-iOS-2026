import SwiftUI

struct ErrorMessage: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(Color(.curlyError))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
