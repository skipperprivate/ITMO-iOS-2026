import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 92, height: 92)
                    .background(AppTheme.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 26))

                Text("RecipeBook").font(.largeTitle.bold())
                Text("Коллекция идей для вкусного ужина.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Технологии").font(.title3.bold())
                    Label("Swift + SwiftUI", systemImage: "swift")
                    Label("URLSession + async/await", systemImage: "network")
                    Label("SwiftData", systemImage: "externaldrive")
                    Label("MVVM + Repository", systemImage: "square.stack.3d.up")
                    Label("XCTest", systemImage: "checkmark.seal")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Приложение получает рецепты из сети, сохраняет кеш и избранное локально и может показать ранее загруженные рецепты при временном отсутствии интернета.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("О приложении")
    }
}
