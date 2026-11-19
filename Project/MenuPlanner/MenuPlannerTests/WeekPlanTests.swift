import SwiftData
import XCTest
@testable import MenuPlanner

@MainActor
final class WeekPlanTests: XCTestCase {
    func testWeekStartsOnMondayAndContainsSevenDays() {
        let viewModel = WeekPlanViewModel()
        viewModel.selectedDate = date(2026, 11, 19)
        XCTAssertEqual(PlanWeek.calendar.component(.weekday, from: viewModel.week.start), 2)
        XCTAssertEqual(viewModel.days.count, 7)
        XCTAssertEqual(viewModel.days.first, date(2026, 11, 16))
        XCTAssertEqual(viewModel.days.last, date(2026, 11, 22))
        let originalDate = viewModel.selectedDate
        viewModel.moveWeek(by: 1)
        XCTAssertEqual(viewModel.selectedDate, date(2026, 11, 26))
        viewModel.moveWeek(by: -1)
        XCTAssertEqual(viewModel.selectedDate, originalDate)
    }

    func testWeekFilteringIncludesStartAndExcludesEnd() {
        let week = PlanWeek.interval(containing: date(2026, 11, 19))
        let recipe = makeRecipe()
        let start = MealPlanEntry(date: week.start, mealType: .breakfast, recipe: recipe, servings: 2)
        let end = MealPlanEntry(date: week.end, mealType: .breakfast, recipe: recipe, servings: 2)
        let before = MealPlanEntry(date: week.start.addingTimeInterval(-1), mealType: .dinner, recipe: recipe, servings: 2)
        XCTAssertEqual(WeekPlanViewModel().entries(in: week, from: [before, end, start]).map(\.id), [start.id])
    }

    func testSaveMealNormalizesDateAndUpdatesExistingEntryWithoutDuplicate() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let recipe = makeRecipe()
        context.insert(recipe)
        let viewModel = WeekPlanViewModel()
        let noon = date(2026, 11, 19).addingTimeInterval(12 * 3_600)
        XCTAssertTrue(viewModel.saveMeal(.lunch, date: noon, existing: nil, recipe: recipe, servings: 3, in: context))
        let entry = try XCTUnwrap(context.fetch(FetchDescriptor<MealPlanEntry>()).first)
        XCTAssertEqual(entry.date, date(2026, 11, 19))
        XCTAssertEqual(entry.mealType, .lunch)
        XCTAssertTrue(viewModel.saveMeal(.lunch, date: noon, existing: entry, recipe: recipe, servings: 4, in: context))
        let persisted = try ModelContext(container).fetch(FetchDescriptor<MealPlanEntry>())
        XCTAssertEqual(persisted.count, 1)
        XCTAssertEqual(persisted.first?.servings, 4)
        XCTAssertTrue(viewModel.removeMeal(entry, in: context))
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<MealPlanEntry>()), 0)
    }

    func testRebuildingShoppingListPreservesFlagsOnlyForUnchangedQuantities() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let recipe = makeRecipe()
        let entry = MealPlanEntry(date: date(2026, 11, 19), mealType: .lunch, recipe: recipe, servings: 2)
        context.insert(entry)
        try context.save()
        let viewModel = WeekPlanViewModel()
        let week = PlanWeek.interval(containing: entry.date)
        XCTAssertTrue(viewModel.collectShoppingList(from: [entry], for: week, in: context))
        let list = try XCTUnwrap(context.fetch(FetchDescriptor<ShoppingList>()).first)
        list.items[0].isPurchased = true
        list.items[0].isAtHome = true
        try context.save()
        XCTAssertTrue(viewModel.collectShoppingList(from: [entry], for: week, in: context))
        XCTAssertTrue(list.items[0].isPurchased)
        XCTAssertTrue(list.items[0].isAtHome)
        entry.servings = 4
        XCTAssertTrue(viewModel.collectShoppingList(from: [entry], for: week, in: context))
        let reader = ModelContext(container)
        let lists = try reader.fetch(FetchDescriptor<ShoppingList>())
        XCTAssertEqual(lists.count, 1)
        let item = try XCTUnwrap(lists.first?.items.first)
        XCTAssertEqual(item.quantity, 200)
        XCTAssertFalse(item.isPurchased)
        XCTAssertTrue(item.isAtHome)
        XCTAssertEqual(try reader.fetchCount(FetchDescriptor<ShoppingItem>()), 1, "Old list rows must be deleted")
    }

    func testInvalidPlanDoesNotReplaceExistingShoppingList() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let entry = MealPlanEntry(date: date(2026, 11, 19), mealType: .lunch, recipe: makeRecipe(), servings: 2)
        context.insert(entry)
        let week = PlanWeek.interval(containing: entry.date)
        let viewModel = WeekPlanViewModel()
        XCTAssertTrue(viewModel.collectShoppingList(from: [entry], for: week, in: context))
        let list = try XCTUnwrap(context.fetch(FetchDescriptor<ShoppingList>()).first)
        let originalItemID = list.items[0].id
        entry.servings = 0
        XCTAssertFalse(viewModel.collectShoppingList(from: [entry], for: week, in: context))
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(list.items[0].id, originalItemID)
        XCTAssertEqual(list.items[0].quantity, 100)
    }

    func testMovingItemHomeClearsPurchasedStatusAndPersistsChange() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let item = ShoppingItem(ingredient: Ingredient(name: "Рис"), quantity: 100, unit: .gram)
        context.insert(ShoppingList(weekStart: date(2026, 11, 16), items: [item]))
        try context.save()
        let viewModel = ShoppingViewModel()
        viewModel.togglePurchased(item, in: context)
        XCTAssertTrue(item.isPurchased)
        viewModel.toggleAtHome(item, in: context)
        let stored = try XCTUnwrap(ModelContext(container).fetch(FetchDescriptor<ShoppingItem>()).first)
        XCTAssertTrue(stored.isAtHome)
        XCTAssertFalse(stored.isPurchased)
        XCTAssertFalse(viewModel.saveFailed)
        viewModel.toggleAtHome(item, in: context)
        XCTAssertFalse(item.isAtHome)
        XCTAssertFalse(item.isPurchased)
    }

    func testDeletingRecipeRemovesItsPlanEntriesAndRetainsOtherRecipes() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let recipe = makeRecipe()
        let other = makeRecipe()
        context.insert(MealPlanEntry(date: .now, mealType: .dinner, recipe: recipe, servings: 2))
        context.insert(MealPlanEntry(date: .now, mealType: .lunch, recipe: other, servings: 2))
        try context.save()
        XCTAssertTrue(RecipeDetailViewModel(recipe: recipe).delete(recipe, in: context))
        let reader = ModelContext(container)
        XCTAssertEqual(try reader.fetch(FetchDescriptor<Recipe>()).map(\.id), [other.id])
        XCTAssertEqual(try reader.fetch(FetchDescriptor<MealPlanEntry>()).map { $0.recipe.id }, [other.id])
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        PlanWeek.calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func makeRecipe() -> Recipe {
        Recipe(name: "Каша", recipeDescription: "", durationMinutes: 15, baseServings: 2,
               ingredients: [RecipeIngredient(ingredient: Ingredient(name: "Рис"), quantity: 100, unit: .gram)])
    }

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: Schema(AppSchema.models),
                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
}
