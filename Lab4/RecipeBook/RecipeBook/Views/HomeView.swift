import SwiftUI

struct HomeView: View {
    let repository: RecipeRepositoryProtocol
    @StateObject private var vm: HomeViewModel
    
    init(repository: RecipeRepositoryProtocol) {
        self.repository = repository
        _vm = StateObject(wrappedValue: HomeViewModel(repository: repository))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                search
                
                if !vm.featuredRecipes.isEmpty && vm.searchText.isEmpty {
                    featured
                }
                
                filters
                
                if vm.isLoading && vm.recipes.isEmpty {
                    ProgressView("Загружаем рецепты...")
                        .frame(maxWidth: .infinity).padding(.vertical, 70)
                } else if vm.filteredRecipes.isEmpty {
                    ContentUnavailableView(
                        "Ничего не найдено",
                        systemImage: "magnifyingglass",
                        description: Text("Попробуйте другой запрос или категорию.")
                    )
                    .frame(maxWidth: .infinity).padding(.vertical, 50)
                } else {
                    grid
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
        .refreshable { await vm.load() }
        .task { if vm.recipes.isEmpty { await vm.load() }
            await vm.testPostRequest()}
        .onAppear {vm.refreshSettings()}
        .alert("Ошибка", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("Закрыть", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("RecipeBook")
                    .font(.largeTitle.bold())
                
                Text("Что приготовим сегодня?")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .accessibilityLabel("Настройки")
        }
    }
    
    private var search: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Поиск рецептов", text: $vm.searchText)
            if !vm.searchText.isEmpty {
                Button { vm.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityIdentifier("searchField") 
    }
    
    private var featured: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Идеи на сегодня").font(.title2.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(vm.featuredRecipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(viewModel: RecipeDetailViewModel(
                                recipeID: recipe.id, repository: repository))
                        } label: {
                            ZStack(alignment: .bottomLeading) {
                                AsyncRecipeImage(url: recipe.image, height: 205)
                                LinearGradient(colors: [.clear, .black.opacity(0.75)],
                                               startPoint: .center, endPoint: .bottom)
                                VStack(alignment: .leading) {
                                    Text(recipe.name).font(.headline).foregroundStyle(.white)
                                    Text("\(recipe.cuisineText) • \(recipe.totalTime) мин")
                                        .font(.caption).foregroundStyle(.white.opacity(0.85))
                                }.padding(15)
                            }
                            .frame(width: 280, height: 205)
                            .clipShape(RoundedRectangle(cornerRadius: 23))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.cuisines, id: \.self) { cuisine in
                    Button(cuisine == "Все" ? "Все" : cuisine) {
                        vm.selectCuisine(cuisine)
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(vm.selectedCuisine == cuisine ? .white : .primary)
                    .padding(.horizontal, 16).padding(.vertical, 9)
                    .background(vm.selectedCuisine == cuisine ? AppTheme.accent : Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    private var grid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 15
        ) {
            ForEach(vm.filteredRecipes) { recipe in
                RecipeCard(
                    recipe: recipe,
                    isFavorite: vm.isFavorite(recipe),
                    onFavorite: {
                        vm.toggleFavorite(recipe)
                    }
                ) {
                    RecipeDetailView(
                        viewModel: RecipeDetailViewModel(
                            recipeID: recipe.id,
                            repository: repository
                        )
                    )
                }
            }
        }
    }
}
