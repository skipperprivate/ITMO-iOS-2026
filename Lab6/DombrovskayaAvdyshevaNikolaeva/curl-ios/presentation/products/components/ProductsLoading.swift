import SwiftUI

struct ProductsLoading: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Загрузка продуктов...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
