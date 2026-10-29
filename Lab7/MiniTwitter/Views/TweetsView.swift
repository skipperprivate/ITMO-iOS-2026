import SwiftUI
import SwiftData

struct TweetsView: View {
    let title: String
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var repositoryProvider: TweetRepositoryProvider
    @StateObject private var viewModel = TweetsViewModel()
    @State private var editor: TweetEditorMode?
    @State private var loadRequest = 0
    @State private var requestTask: Task<Void, Never>?

    var body: some View {
        List {
            Section {
                Picker("Фильтр ленты", selection: $viewModel.filter) {
                    ForEach(FeedFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("feed.filter")

                if viewModel.isLoading {
                    ProgressView("Чтение сохранённой ленты…")
                } else if !viewModel.isReady {
                    Button("Повторить загрузку") { loadRequest += 1 }
                }

                if viewModel.isRefreshing {
                    ProgressView("Загрузка с сервера…")
                }
                if viewModel.isSaving {
                    ProgressView("Сохранение…")
                }
                if let date = viewModel.lastServerSync {
                    Text("Обновлено с сервера: \(date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if let date = viewModel.lastCacheUpdate {
                    Text("Локальные данные: \(date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let message = viewModel.networkError {
                Section {
                    Label(message, systemImage: "wifi.exclamationmark")
                        .font(.callout)
                    Button("Повторить запрос") {
                        requestTask = Task { await viewModel.retry() }
                    }
                    .disabled(viewModel.isRefreshing)
                }
            }

            Section {
                if viewModel.isReady && !viewModel.isRefreshing && viewModel.visibleTweets.isEmpty {
                    Text(viewModel.filter == .favorites
                         ? "В избранном пока нет твитов. Нажмите закладку рядом с твитом."
                         : "Пока нет твитов. Обновите ленту или добавьте локальный твит.")
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("feed.empty")
                }
                ForEach(viewModel.visibleTweets) { tweet in
                    TweetRow(
                        tweet: tweet,
                        likes: viewModel.displayedLikes(tweet),
                        isLiked: viewModel.isLiked(tweet),
                        canEdit: viewModel.canEdit,
                        onLike: { Task { await viewModel.like(tweet) } },
                        onFavorite: { Task { await viewModel.toggleFavorite(id: tweet.id) } }
                    )
                    .swipeActions(edge: .leading) {
                        if tweet.serverID == nil {
                            Button("Изменить", systemImage: "pencil") { editor = .edit(tweet) }
                                .tint(.orange)
                                .disabled(!viewModel.canEdit)
                        }
                    }
                    .swipeActions {
                        if tweet.serverID == nil {
                            Button("Удалить", systemImage: "trash", role: .destructive) {
                                Task { await viewModel.delete(id: tweet.id) }
                            }
                            .disabled(!viewModel.canEdit)
                        }
                    }
                }
            }

            if viewModel.canLoadMore {
                Button("Загрузить ещё") {
                    requestTask = Task { await viewModel.loadMore() }
                }
                .disabled(viewModel.isRefreshing)
            }
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Добавить локальный твит", systemImage: "square.and.pencil") {
                    editor = .create
                }
                .accessibilityIdentifier("feed.compose")
                .disabled(!viewModel.canEdit)
            }
        }
        .task(id: loadRequest) {
            await viewModel.loadCache(using: modelContext.container, provider: repositoryProvider)
        }
        .refreshable { await viewModel.refresh() }
        .onDisappear { requestTask?.cancel() }
        .sheet(item: $editor) { mode in
            switch mode {
            case .create:
                TweetEditorView(title: "Новый локальный твит") { text in
                    try await viewModel.createTweet(text: text)
                }
            case .edit(let tweet):
                TweetEditorView(title: "Изменить твит", initialText: tweet.text) { text in
                    try await viewModel.update(id: tweet.id, text: text)
                }
            }
        }
        .alert("Ошибка", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct TweetRow: View {
    let tweet: TweetDTO
    let likes: Int
    let isLiked: Bool
    let canEdit: Bool
    let onLike: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(avatarColor)
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(tweet.name.prefix(1)))
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(tweet.name)
                    .fontWeight(.semibold)
                Text("\(tweet.username) · \(tweet.relativeTime)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(tweet.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("tweet.text.\((tweet.serverID ?? tweet.id).uuidString)")

                HStack {
                    if tweet.serverID != nil {
                        Button(action: onLike) {
                            Label(String(likes), systemImage: isLiked ? "heart.fill" : "heart")
                                .foregroundStyle(isLiked ? Color.pink : Color.secondary)
                        }
                        .accessibilityLabel(isLiked ? "Лайк отправлен. Лайков: \(likes)" : "Поставить лайк. Лайков: \(likes)")
                        .disabled(!canEdit || isLiked)
                    } else {
                        Text("Локальный твит")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: onFavorite) {
                        Image(systemName: tweet.isFavorite ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(tweet.isFavorite ? Color.blue : Color.secondary)
                            .padding(8)
                    }
                    .accessibilityLabel(tweet.isFavorite ? "Убрать из избранного" : "В избранное")
                    .accessibilityIdentifier("tweet.favorite.\((tweet.serverID ?? tweet.id).uuidString)")
                    .accessibilityValue(tweet.isFavorite ? "selected" : "unselected")
                    .disabled(!canEdit)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 8)
    }

    private var avatarColor: Color {
        switch tweet.avatarColor {
        case "pink": .pink
        case "orange": .orange
        case "purple": .purple
        case "green": .green
        default: .blue
        }
    }
}

private enum TweetEditorMode: Identifiable {
    case create
    case edit(TweetDTO)

    var id: String {
        switch self {
        case .create:
            "create"
        case .edit(let tweet):
            tweet.id.uuidString
        }
    }
}

private struct TweetEditorView: View {
    let title: String
    let onSave: @MainActor (String) async throws -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(title: String, initialText: String = "",
         onSave: @escaping @MainActor (String) async throws -> Void) {
        self.title = title
        self.onSave = onSave
        _text = State(initialValue: initialText)
    }

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .accessibilityIdentifier("editor.text")
                .disabled(isSaving)
                .padding()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") {
                            dismiss()
                        }
                        .disabled(isSaving)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(isSaving ? "Сохранение…" : "Сохранить") {
                            isSaving = true
                            Task {
                                defer { isSaving = false }
                                do {
                                    try await onSave(text.trimmingCharacters(in: .whitespacesAndNewlines))
                                    dismiss()
                                } catch is CancellationError {
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .disabled(isSaving || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("editor.save")
                    }
                }
        }
        .interactiveDismissDisabled(isSaving)
        .alert("Не удалось сохранить твит", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

struct TweetsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TweetsView(title: "Главная лента")
        }
        .modelContainer(for: Tweet.self, inMemory: true)
        .environmentObject(TweetRepositoryProvider(metadataSuite: "MiniTwitter.TweetsPreview", api: MockTweetsAPI()))
    }
}
