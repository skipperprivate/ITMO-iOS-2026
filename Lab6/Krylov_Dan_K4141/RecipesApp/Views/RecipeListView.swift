import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var context
    @State private var viewModel = RecipeListViewModel()
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.sections(recipes)) { section in
                    Section {
                        ForEach(section.recipes) { recipe in
                            NavigationLink(recipe.title) {
                                RecipeDetailView(recipe: recipe)
                            }
                        }
                        .onDelete { offsets in
                            for i in offsets {
                                viewModel.delete(section.recipes[i], context: context)
                            }
                        }
                    } header: {
                        Label(section.type.title, systemImage: section.type.icon)
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if recipes.isEmpty {
                    ContentUnavailableView("Рецептов пока нет", systemImage: "book.closed")
                }
            }
            .navigationTitle("Рецепты")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Сортировка", systemImage: "arrow.up.arrow.down") {
                        Picker("Сортировка", selection: $viewModel.sortOption) {
                            ForEach(SortOption.allCases) { Text($0.title).tag($0) }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Загрузить", systemImage: "sparkles") {
                        Button("Случайный рецепт") {
                            Task { await viewModel.loadRandomRecipe(context: context) }
                        }
                        Button("По рецепту в каждую категорию") {
                            Task { await viewModel.loadOnePerCategory(context: context) }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Добавить", systemImage: "plus") { showEditor = true }
                }
            }
            .sheet(isPresented: $showEditor) {
                RecipeEditorView()
            }
            .alert("Ошибка", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
