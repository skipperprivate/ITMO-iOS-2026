import SwiftUI

@MainActor
struct RecipeListView<Presenter: RecipeListViewOutput>: View {
    @StateObject private var presenter: Presenter
    @State private var section = Section.recommendations

    private enum Section: String, CaseIterable {
        case recommendations = "Для вас"
        case all = "Все"
        case favorites = "Избранное"
    }

    init(presenter: @autoclosure @escaping () -> Presenter) {
        _presenter = StateObject(wrappedValue: presenter())
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Рецепты", selection: $section) {
                ForEach(Section.allCases, id: \.self) { section in
                    Text(section.rawValue).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            if presenter.state.isLoadingRemote {
                ProgressView("Загружаем рецепты…").padding(8)
            }
            if let error = presenter.state.remoteError {
                VStack(spacing: 6) {
                    Text(error).font(.caption).foregroundStyle(.secondary)
                    Button("Повторить загрузку") {
                        Task { await presenter.loadRemote(force: true) }
                    }
                }
                .padding(.horizontal)
            }

            switch section {
                case .recommendations:
                    RecipeDeckView(
                        state: presenter.state,
                        onOpen: presenter.showRecipe,
                        onFavorite: presenter.toggleFavorite,
                        onSkip: presenter.skip,
                        onRestart: presenter.restartDeck,
                        onRefresh: refresh
                    )
                case .all:
                    recipeList(presenter.state.recipes, emptyTitle: "Пока нет рецептов")
                case .favorites:
                    recipeList(presenter.state.favorites, emptyTitle: "Здесь будут любимые рецепты")
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(section == .recommendations ? "Рекомендации Gastro" : section.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Add recipe", systemImage: "plus", action: presenter.showNewRecipe)
                .accessibilityIdentifier("recipes.add")
        }
        .onAppear(perform: presenter.load)
        .task { await presenter.loadRemote(force: false) }
        .alert(
            "Error",
            isPresented: Binding(
                get: { presenter.state.error != nil },
                set: { if !$0 { presenter.clearError() } }
            )
        ) {
            Button("OK", role: .cancel, action: presenter.clearError)
        } message: {
            Text(presenter.state.error ?? "")
        }
    }

    @ViewBuilder
    private func recipeList(_ recipes: [RecipeRowState], emptyTitle: String) -> some View {
        if recipes.isEmpty {
            ContentUnavailableView(
                emptyTitle,
                systemImage: section == .favorites ? "heart" : "book.closed",
                description: Text("Добавьте рецепт или выберите карточку в рекомендациях")
            )
        } else {
            List(recipes) { recipe in
                RecipeListRow(
                    recipe: recipe,
                    isFavorite: presenter.state.favorites.contains { $0.id == recipe.id },
                    onOpen: { presenter.showRecipe(id: recipe.id) },
                    onToggleFavorite: { presenter.toggleFavorite(recipe) }
                )
                .swipeActions {
                    if case .local(let id) = recipe.id {
                        Button("Delete", role: .destructive) { presenter.delete(id: id) }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .refreshable {
                await refresh()
            }
        }
    }
    private func refresh() async {
        presenter.load()
        await presenter.loadRemote(force: true)
    }
}
