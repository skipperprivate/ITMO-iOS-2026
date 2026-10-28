import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var viewModel: NewsViewModel

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-uiTesting") {
            let suiteName = "NewsFeed.UITests"
            let defaults = UserDefaults(suiteName: suiteName)!

            defaults.removePersistentDomain(forName: suiteName)

            let storage = MockNewsStorage(news: [
                News(
                    id: 1,
                    title: "Первая тестовая новость",
                    text: "Первый текст"
                ),
                News(
                    id: 2,
                    title: "Вторая тестовая новость",
                    text: "Второй текст"
                )
            ])

            _viewModel = StateObject(
                wrappedValue: NewsViewModel(
                    storage: storage,
                    defaults: defaults
                )
            )

            return
        }
        #endif

        _viewModel = StateObject(
            wrappedValue: NewsViewModel()
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Toggle(
                    "Только избранное",
                    isOn: $viewModel.showFavorites
                )
                .accessibilityIdentifier("favoritesToggle")

                if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                }

                if viewModel.visibleNews.isEmpty && !viewModel.isLoading {
                    Text("Новостей нет")
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("emptyNews")
                }

                ForEach(viewModel.visibleNews) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.title)
                            .font(.headline)
                            .accessibilityIdentifier("newsTitle_\(item.id)")

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
                        .accessibilityIdentifier("favoriteButton_\(item.id)")
                    }
                    .padding(.vertical, 8)
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentItem: item)
                    }
                    .onChange(of: viewModel.isLoading) { isLoading in
                        if !isLoading {
                            viewModel.loadMoreIfNeeded(currentItem: item)
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView("Загрузка...")
                }

                if viewModel.errorMessage != nil &&
                    viewModel.hasMorePosts &&
                    !viewModel.showFavorites {
                    Button("Повторить загрузку") {
                        Task {
                            await viewModel.loadNextChunk()
                        }
                    }
                }
            }
            .navigationTitle("Новости")
            .toolbar {
                NavigationLink("Создать пост") {
                    CreatePostView()
                }
            }
            .task {
                if !ProcessInfo.processInfo.arguments.contains("-uiTesting") {
                    await viewModel.refreshNews()
                }
            }
            .refreshable {
                if !ProcessInfo.processInfo.arguments.contains("-uiTesting") {
                    await viewModel.refreshNews()
                }
            }
        }
    }
}
