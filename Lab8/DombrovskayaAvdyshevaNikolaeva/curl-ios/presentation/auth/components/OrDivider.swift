import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack {
            Divider().background(Color.curlyDarkGreen.opacity(0.3))
            Text("или")
                .padding(.horizontal, 16)
                .font(.subheadline)
                .foregroundStyle(Color.curlyDarkGreen.opacity(0.6))
            Divider().background(Color.curlyDarkGreen.opacity(0.3))
        }
    }
}
