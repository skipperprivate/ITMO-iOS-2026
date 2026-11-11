import SwiftUI

struct ProductsLoading: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color(.curlyGreen))
            Text("Загрузка средств...")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(.curlyDarkGreen).opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}
