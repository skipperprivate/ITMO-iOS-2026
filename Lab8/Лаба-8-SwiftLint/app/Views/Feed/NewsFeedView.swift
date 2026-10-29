import SwiftUI
import SwiftData

struct NewsFeedView: View {
    @Environment(SettingsViewModel.self) private var settings
    @State private var viewModel: NewsFeedViewModel
    @State private var refreshRequest = 0
    private let publisher: any NewsPublishing
    @State private var sheet: PresentedSheet?

    init(repository: NewsRepository, newsService: any NewsFetching = NewsAPIClient(),
         publisher: any NewsPublishing = NewsAPIClient()) {
        self.publisher = publisher
        _viewModel = State(initialValue: NewsFeedViewModel(repository: repository, newsService: newsService))
    }

    private enum PresentedSheet: Identifiable {
        case newArticle, settings
        case statistics
        case search([NewsSearchDocument])
        var id: String {
            switch self {
            case .newArticle: return "newArticle"
            case .settings: return "settings"
            case .statistics: return "statistics"
            case .search: return "search"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if viewModel.isRefreshing {
                        ProgressView("Загрузка новостей…")
                    } else if let message = viewModel.networkMessage {
                        Text(message).font(.footnote).foregroundStyle(.secondary)
                            .accessibilityIdentifier("network-message")
                        if viewModel.hasRefreshError {
                            Button("Повторить загрузку") { refreshRequest += 1 }
                                .accessibilityIdentifier("retry-loading")
                        }
                    }
                } footer: {
                    Text("Учебная лента DummyJSON · 30 публикаций с текстом. Потяните вниз для обновления.")
                }

                if viewModel.items.isEmpty && !viewModel.isRefreshing {
                    ContentUnavailableView("Публикаций пока нет", systemImage: "newspaper",
                                           description: Text("Обновите ленту или добавьте свою запись кнопкой плюс."))
                }
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        NewsDetailView(item: item, repository: viewModel.repository)
                    } label: {
                        NewsCardView(item: item, showDates: settings.showDates)
                    }
                    .accessibilityHint("Читать новость полностью")
                    .accessibilityIdentifier("article-\(item.remoteID ?? "local")")
                }
                .onDelete(perform: viewModel.delete)
            }
            .task { await viewModel.load() }
            .task(id: refreshRequest) {
                guard refreshRequest > 0 else { return }
                await viewModel.refresh()
            }
            .refreshable { await viewModel.refresh() }
            .navigationTitle("Лента новостей")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Поиск", systemImage: "magnifyingglass") {
                        sheet = .search(viewModel.searchDocuments())
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Статистика", systemImage: "chart.bar") {
                        // SwiftData читаем на главном потоке. В фон передаём копии строк.
                        viewModel.prepareStatistics()
                        sheet = .statistics
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Добавить новость", systemImage: "plus") {
                        sheet = .newArticle
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Настройки", systemImage: "gearshape") {
                        sheet = .settings
                    }
                }
#if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    EditButton().disabled(viewModel.items.isEmpty)
                }
#endif
            }
            .sheet(item: $sheet, onDismiss: viewModel.reload) { destination in
                switch destination {
                case .newArticle: NewsEditorView(item: nil, repository: viewModel.repository, publisher: publisher)
                case .settings: SettingsView()
                case .statistics: NewsStatisticsView(viewModel: viewModel.statistics)
                case .search(let documents): NewsSearchView(documents: documents)
                }
            }
            .alert("Ошибка работы с новостями", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("Понятно", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

}

#Preview {
    let container = try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    NewsFeedView(repository: NewsRepository(context: container.mainContext))
        .environment(SettingsViewModel(defaults: UserDefaults(suiteName: "NewsPreview")!))
        .modelContainer(container)
}
