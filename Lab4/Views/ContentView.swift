import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        NavigationStack {
            List {
                Toggle(
                    "Только избранное",
                    isOn: $viewModel.showFavorites
                )

                if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                }

                if viewModel.visibleNews.isEmpty &&
                    !viewModel.isLoading {
                    Text("Новостей нет")
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.visibleNews) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.title)
                            .font(.headline)

                        Text(item.text)

                        Button {
                            viewModel.toggleFavorite(item)
                        } label: {
                            Text(
                                item.isFavorite
                                    ? "Убрать из избранного"
                                    : "В избранное"
                            )
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Новости")
            .task {
                await viewModel.refreshNews()
            }
            .refreshable {
                await viewModel.refreshNews()
            }
        }
    }
}

