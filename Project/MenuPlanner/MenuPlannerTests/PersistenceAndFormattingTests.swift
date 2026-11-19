import SwiftData
import XCTest
@testable import MenuPlanner

@MainActor
final class PersistenceAndFormattingTests: XCTestCase {
    func testRussianCountEndingsAtTeenAndDecadeBoundaries() {
        for value in [1, 21, 101] { XCTAssertEqual(count(value), "\(value) порция") }
        for value in [2, 3, 4, 22, 24, 102] { XCTAssertEqual(count(value), "\(value) порции") }
        for value in [0, 5, 10, 11, 12, 13, 14, 19, 20, 25, 111, 112, 114] {
            XCTAssertEqual(count(value), "\(value) порций")
        }
    }

    func testRecipeServingsClampToOneAndScaledQuantitiesDoNotModifyOriginal() {
        let recipe = makeRecipe()
        recipe.updateBaseServings(to: 0)
        XCTAssertEqual(recipe.baseServings, 1)
        recipe.updateBaseServings(to: -5)
        XCTAssertEqual(recipe.baseServings, 1)
        recipe.updateBaseServings(to: 2)
        let model = RecipeDetailViewModel(recipe: recipe)
        model.servings = 3
        XCTAssertEqual(model.quantity(for: recipe.ingredients[0], recipe: recipe), RecipeFormatting.quantity(150, unit: .gram))
        XCTAssertEqual(recipe.ingredients[0].quantity, 100)
        XCTAssertEqual(recipe.baseServings, 2)
    }

    func testFavoritePersistsInBothDirectionsAndRefreshResetsServings() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let recipe = makeRecipe()
        context.insert(recipe)
        try context.save()
        let model = RecipeDetailViewModel(recipe: recipe)
        model.toggleFavorite(recipe, in: context)
        XCTAssertEqual(try ModelContext(container).fetch(FetchDescriptor<Recipe>()).first?.isFavorite, true)
        model.toggleFavorite(recipe, in: context)
        XCTAssertEqual(try ModelContext(container).fetch(FetchDescriptor<Recipe>()).first?.isFavorite, false)
        model.servings = 10
        recipe.updateBaseServings(to: 4)
        try context.save()
        model.refresh(in: context)
        XCTAssertEqual(model.servings, 4)
        XCTAssertNil(model.errorMessage)
    }

    func testRefreshMissingRecipeKeepsCurrentStateWithoutError() throws {
        let container = try makeContainer()
        let model = RecipeDetailViewModel(recipe: makeRecipe())
        model.servings = 5
        model.refresh(in: container.mainContext)
        XCTAssertEqual(model.servings, 5)
        XCTAssertNil(model.errorMessage)
    }

    func testLoadingRecipesRemovesOnlyBuiltInExamplesAndTheirRows() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let example = makeRecipe()
        example.isBuiltIn = true
        let own = makeRecipe()
        context.insert(example)
        context.insert(own)
        try context.save()
        let model = RecipesViewModel()
        model.load(in: context)
        model.load(in: context)
        let reader = ModelContext(container)
        XCTAssertEqual(try reader.fetch(FetchDescriptor<Recipe>()).map(\.id), [own.id])
        XCTAssertEqual(try reader.fetchCount(FetchDescriptor<RecipeIngredient>()), 1)
        XCTAssertNil(model.errorMessage)
    }

    func testShoppingListsStaySeparateAcrossWeeksAndEmptyRebuildDeletesItems() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let model = WeekPlanViewModel()
        let recipe = makeRecipe()
        let week = PlanWeek.interval(containing: Date(timeIntervalSince1970: 1_795_000_000))
        let next = PlanWeek.interval(containing: week.end)
        let entry = MealPlanEntry(date: week.start, mealType: .dinner, recipe: recipe, servings: 2)
        context.insert(entry)
        XCTAssertTrue(model.collectShoppingList(from: [entry], for: week, in: context))
        XCTAssertTrue(model.collectShoppingList(from: [entry], for: next, in: context))
        XCTAssertTrue(model.collectShoppingList(from: [], for: week, in: context))
        let lists = try ModelContext(container).fetch(FetchDescriptor<ShoppingList>())
        XCTAssertEqual(lists.count, 2)
        XCTAssertEqual(lists.first { $0.weekStart == week.start }?.items.count, 0)
        XCTAssertEqual(lists.first { $0.weekStart == next.start }?.items.count, 1)
    }

    func testAttachingProductPersistsMetadataWithoutChangingIngredientName() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let ingredient = Ingredient(name: "Рис")
        context.insert(ingredient)
        try context.save()
        let product = VkusVillProduct(id: 42, name: "Рис 500 г", price: .init(current: 100), unit: "шт",
                                      weight: .init(value: 500, unit: "г"), url: nil, images: nil)
        try ShoppingViewModel().attach(product, to: ingredient, in: context)
        let stored = try XCTUnwrap(ModelContext(container).fetch(FetchDescriptor<Ingredient>()).first)
        XCTAssertEqual(stored.name, "Рис")
        XCTAssertEqual(stored.vkusVillProduct?.id, 42)
        XCTAssertEqual(stored.vkusVillProduct?.weight?.value, 500)
    }

    func testWeekTitlesAndDaysAcrossMonthYearAndLeapDay() {
        for components in [DateComponents(year: 2026, month: 11, day: 30),
                           DateComponents(year: 2027, month: 1, day: 1),
                           DateComponents(year: 2028, month: 2, day: 29)] {
            let model = WeekPlanViewModel()
            model.selectedDate = PlanWeek.calendar.date(from: components)!
            XCTAssertEqual(model.days.count, 7)
            XCTAssertEqual(Set(model.days).count, 7)
            XCTAssertEqual(PlanWeek.calendar.component(.weekday, from: model.days[0]), 2)
            XCTAssertTrue(model.week.contains(model.selectedDate))
            XCTAssertFalse(PlanWeek.title(for: model.week).isEmpty)
        }
        let date = PlanWeek.calendar.date(from: DateComponents(year: 2026, month: 11, day: 19))!
        let week = PlanWeek.interval(containing: date)
        XCTAssertEqual(PlanWeek.title(for: week), "16–22 ноября")
    }

    private func count(_ value: Int) -> String {
        RecipeFormatting.count(value, one: "порция", few: "порции", many: "порций")
    }

    private func makeRecipe() -> Recipe {
        Recipe(name: "Каша", recipeDescription: "", durationMinutes: 15, baseServings: 2,
               ingredients: [RecipeIngredient(ingredient: Ingredient(name: "Рис"), quantity: 100, unit: .gram)])
    }

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: Schema(AppSchema.models), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
}
