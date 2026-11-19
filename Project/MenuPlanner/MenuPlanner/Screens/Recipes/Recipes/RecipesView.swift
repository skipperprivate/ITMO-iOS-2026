import SwiftData
import SwiftUI

struct RecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.bottomBarInset) private var bottomBarInset
    @Query private var recipes: [Recipe]
    @State private var viewModel = RecipesViewModel()
    @State private var showsRecipeImport = false
    @FocusState private var isSearching: Bool

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12, alignment: .top)]

    var body: some View {
        @Bindable var viewModel = viewModel
        let visibleRecipes = viewModel.visibleRecipes(from: recipes)

        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                heading
                searchField
                Button {
                    isSearching = false
                    showsRecipeImport = true
                } label: {
                    Label("Найти в интернете", systemImage: "globe")
                        .font(AppFonts.smallStrong)
                        .foregroundStyle(AppColors.accent)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(AppColors.accentSoft, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                filters
                sectionHeader(count: visibleRecipes.count)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            ScrollView {
                Group {
                    if visibleRecipes.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                            ForEach(visibleRecipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe)
                                } label: {
                                    RecipeCardView(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { isSearching = false }
                }
            }
            .contentMargins(.bottom, bottomBarInset, for: .scrollContent)
            .contentMargins(.bottom, bottomBarInset, for: .scrollIndicators)
            .scrollDismissesKeyboard(.interactively)
        }
        .background {
            AppColors.background.ignoresSafeArea()
                .onTapGesture { isSearching = false }
        }
        .toolbar(.hidden, for: .navigationBar, .tabBar)
        .task { viewModel.load(in: modelContext) }
        .onDisappear { isSearching = false }
        .onChange(of: viewModel.isPresentingEditor) { _, isPresented in
            if isPresented { isSearching = false }
        }
        .sheet(isPresented: $viewModel.isPresentingEditor) {
            RecipeEditorView()
        }
        .sheet(isPresented: $showsRecipeImport) {
            RecipeImportView(query: viewModel.searchText)
        }
        .alert("Не удалось загрузить рецепты", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Понятно", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var searchField: some View {
        @Bindable var viewModel = viewModel
        return HStack(spacing: 12) {
            Image("RecipeSearch")
                .renderingMode(.template)
                .foregroundStyle(AppColors.secondaryText)
            TextField("Найти блюдо или ингредиент", text: $viewModel.searchText,
                      prompt: Text("Найти блюдо или ингредиент").foregroundStyle(AppColors.secondaryText))
                .font(AppFonts.body)
                .foregroundStyle(AppColors.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isSearching)
                .onSubmit { isSearching = false }
        }
        .padding(12)
        .frame(minHeight: 46)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func sectionHeader(count: Int) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                sectionTitle
                Spacer(minLength: 8)
                recipeCount(count)
            }
            VStack(alignment: .leading, spacing: 4) {
                sectionTitle
                recipeCount(count)
            }
        }
    }

    private var heading: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Рецепты")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.primaryText)
                Text("Выбирай блюда на каждый день")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                viewModel.isPresentingEditor = true
            } label: {
                Image("RecipePlus")
                    .renderingMode(.template)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 44, height: 44)
                    .background(AppColors.surface, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var filters: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RecipeFilter.allCases) { filter in
                        Button {
                            viewModel.filter = filter
                        } label: {
                            Text(filter.rawValue)
                                .font(AppFonts.smallStrong)
                                .foregroundStyle(viewModel.filter == filter ? AppColors.onAccent : AppColors.secondaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(minHeight: 36)
                                .background(viewModel.filter == filter ? AppColors.accent : AppColors.surface, in: Capsule())
                                .frame(minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Menu {
                Picker("Сортировка", selection: $viewModel.sort) {
                    ForEach(RecipeSort.allCases) { sort in
                        Text(sort.rawValue).tag(sort)
                    }
                }
                Toggle("Только избранные", isOn: $viewModel.favoritesOnly)
            } label: {
                Image("RecipeSort")
                    .renderingMode(.template)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private var sectionTitle: some View {
        Text("Твои будущие ужины")
            .font(AppFonts.section)
            .foregroundStyle(AppColors.primaryText)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func recipeCount(_ count: Int) -> some View {
        Text(RecipeFormatting.count(count, one: "рецепт", few: "рецепта", many: "рецептов"))
            .font(AppFonts.small)
            .foregroundStyle(AppColors.secondaryText)
            .fixedSize()
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipes.isEmpty ? "Пока нет рецептов" : "Рецепты не найдены")
                .font(AppFonts.section)
            Text("Добавь своё блюдо или измени поиск и фильтры.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.secondaryText)
            Button("Добавить рецепт") { viewModel.isPresentingEditor = true }
                .font(AppFonts.strong)
                .foregroundStyle(AppColors.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 20))
        .foregroundStyle(AppColors.primaryText)
    }
}

#Preview("Рецепты") {
    let container = try! ModelContainer(
        for: Recipe.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    NavigationStack { RecipesView() }
        .modelContainer(container)
}
