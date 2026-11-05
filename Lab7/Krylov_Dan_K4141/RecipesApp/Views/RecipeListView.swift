import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var context
    @State private var viewModel = RecipeListViewModel()
    @State private var showEditor = false

    var body: some View {
        let sections = viewModel.sections(recipes)

        NavigationStack {
            List {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.recipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe)
                            } label: {
                                HStack {
                                    Text(recipe.title)
                                    Spacer()
                                    if recipe.isFavorite {
                                        Image(systemName: "heart.fill").foregroundStyle(.orange)
                                    }
                                }
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                viewModel.delete(section.recipes[index], context: context)
                            }
                        }
                    } header: {
                        if viewModel.selectedCategory == nil {
                            Label(section.type.plural, systemImage: section.type.icon)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top) { categoryTabs }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if recipes.isEmpty {
                    ContentUnavailableView("Рецептов пока нет", systemImage: "book.closed",
                                           description: Text("Нажмите «+», чтобы добавить"))
                } else if sections.isEmpty {
                    ContentUnavailableView("Ничего не найдено", systemImage: "magnifyingglass")
                }
            }
            .navigationTitle("Рецепты")
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Название или продукт")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Фильтры", systemImage: "line.3.horizontal.decrease.circle") {
                        Toggle("Только избранное", isOn: $viewModel.favoritesOnly)
                        Section("Сортировка") {
                            Picker("Сортировка", selection: $viewModel.sortOption) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
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

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                tab("Все", type: nil)
                ForEach(MealType.allCases) { category in
                    tab(category.plural, type: category)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(.bar)
    }

    private func tab(_ title: String, type: MealType?) -> some View {
        let selected = viewModel.selectedCategory == type
        return Button {
            viewModel.selectedCategory = type
        } label: {
            Text(title)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(selected ? Color.orange : Color(.systemGray5), in: Capsule())
                .foregroundStyle(selected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
