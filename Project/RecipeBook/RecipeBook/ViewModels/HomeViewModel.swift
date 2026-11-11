import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var recipes: [Recipe] = []
    @Published private(set) var favoriteIDs: Set<Int> = []
    @Published private(set) var isLoading = false

    @Published var searchText = ""
    @Published var selectedCuisine: String
    @Published var selectedSortOption: String

    @Published var errorMessage: String?

    private let repository: RecipeRepositoryProtocol
    private let settings = AppSettings.shared

    init(repository: RecipeRepositoryProtocol) {
        self.repository = repository
        self.selectedCuisine = settings.selectedCuisine
        self.selectedSortOption = settings.sortOption
    }

    func selectCuisine(_ cuisine: String) {
        selectedCuisine = cuisine
        settings.selectedCuisine = cuisine
    }

    func selectSortOption(_ option: String) {
        selectedSortOption = option
        settings.sortOption = option
    }

    var cuisines: [String] {
        let translatedCuisines = recipes.map { $0.cuisineText }

        return ["Все"] + Array(
            Set(translatedCuisines)
        ).sorted()
    }

    var filteredRecipes: [Recipe] {

        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let filtered = recipes.filter { recipe in

            let textOK =
                query.isEmpty ||
                recipe.name.localizedCaseInsensitiveContains(query) ||
                recipe.tags.contains {
                    $0.localizedCaseInsensitiveContains(query)
                }

            let cuisineOK =
                selectedCuisine == "Все" ||
                recipe.cuisineText == selectedCuisine

            return textOK && cuisineOK
        }

        switch selectedSortOption {

        case "Название":
            return filtered.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name)
                == .orderedAscending
            }

        case "Время приготовления":
            return filtered.sorted {
                $0.totalTime < $1.totalTime
            }

        case "Калорийность":
            return filtered.sorted {
                $0.caloriesPerServing < $1.caloriesPerServing
            }

        default:
            return filtered
        }
    }

    var featuredRecipes: [Recipe] {
        Array(filteredRecipes.prefix(5))
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let r = repository.fetchRecipes()
            async let f = repository.favoriteIDs()
            recipes = try await r
            favoriteIDs = try await f
            print("Load OK. Recipes: \(recipes.count), Favorites: \(favoriteIDs)")
        } catch {
            errorMessage = error.localizedDescription
            print("Load ERROR: \(error)")
            print("Load ERROR localized: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func toggleFavorite(_ recipe: Recipe) {
        do {
            try repository.toggleFavorite(recipe)
            favoriteIDs = (try? repository.favoriteIDs()) ?? []
            print("Favorite toggled. Now: \(favoriteIDs)")
        } catch {
            errorMessage = error.localizedDescription
            print("Toggle favorite error: \(error)")
        }
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        favoriteIDs.contains(recipe.id)
    }
    
    func refreshSettings() {
        selectedCuisine = settings.selectedCuisine
        selectedSortOption = settings.sortOption
    }
    
    func testPostRequest() async {
        let testRecipe = Recipe(
            id: 9999,
            name: "Тестовый POST рецепт",
            ingredients: ["Ингредиент 1", "Ингредиент 2"],
            instructions: ["Шаг 1", "Шаг 2"],
            prepTimeMinutes: 10,
            cookTimeMinutes: 20,
            servings: 2,
            difficulty: "easy",
            cuisine: "italian",
            caloriesPerServing: 300,
            image: "",
            tags: ["test"]
        )
        
        print("🚀 Начинаю POST запрос...")
        
        do {
            
            let api = RecipeAPI()
            let result = try await api.addRecipeToServer(testRecipe)
            print("POST Успешен! Сервер вернул ID: \(result.id), Имя: \(result.name)")
        } catch {
            print("POST Ошибка: \(error.localizedDescription)")
        }
    }
}
