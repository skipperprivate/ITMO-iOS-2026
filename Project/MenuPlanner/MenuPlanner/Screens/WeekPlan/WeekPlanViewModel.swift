import Foundation
import Observation
import SwiftData

enum PlanWeek {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }

    static func interval(containing date: Date) -> DateInterval {
        calendar.dateInterval(of: .weekOfYear, for: date)!
    }

    static func title(for week: DateInterval) -> String {
        let end = calendar.date(byAdding: .day, value: -1, to: week.end)!
        let format = Date.FormatStyle().locale(Locale(identifier: "ru_RU"))
        if calendar.isDate(week.start, equalTo: end, toGranularity: .month) {
            return "\(calendar.component(.day, from: week.start))–\(end.formatted(format.day().month(.wide)))"
        }
        return "\(week.start.formatted(format.day().month(.wide))) — \(end.formatted(format.day().month(.wide)))"
    }
}

@MainActor
@Observable
final class WeekPlanViewModel {
    var selectedDate = Date.now
    var errorMessage: String?

    var week: DateInterval { PlanWeek.interval(containing: selectedDate) }
    var days: [Date] {
        (0..<7).compactMap { PlanWeek.calendar.date(byAdding: .day, value: $0, to: week.start) }
    }

    func moveWeek(by offset: Int) {
        selectedDate = PlanWeek.calendar.date(byAdding: .weekOfYear, value: offset, to: selectedDate) ?? selectedDate
    }

    func entries(in week: DateInterval, from entries: [MealPlanEntry]) -> [MealPlanEntry] {
        entries.filter { $0.date >= week.start && $0.date < week.end }
    }

    func saveMeal(_ mealType: MealType, date: Date, existing: MealPlanEntry?, recipe: Recipe,
                  servings: Int, in context: ModelContext) -> Bool {
        if let existing {
            existing.recipe = recipe
            existing.servings = servings
        } else {
            context.insert(MealPlanEntry(date: PlanWeek.calendar.startOfDay(for: date),
                                         mealType: mealType, recipe: recipe, servings: servings))
        }
        return save(in: context)
    }

    func removeMeal(_ entry: MealPlanEntry, in context: ModelContext) -> Bool {
        context.delete(entry)
        return save(in: context)
    }

    func collectShoppingList(from entries: [MealPlanEntry], for week: DateInterval,
                             in context: ModelContext) -> Bool {
        do {
            let start = week.start
            let list = try context.fetch(FetchDescriptor<ShoppingList>(
                predicate: #Predicate { $0.weekStart == start }
            )).first
            let newItems = try ShoppingListBuilder().build(from: entries)

            if let list {
                let oldItems = list.items
                for item in newItems {
                    guard let previous = oldItems.first(where: {
                        $0.ingredient.id == item.ingredient.id && $0.unit == item.unit
                    }) else { continue }
                    item.isAtHome = previous.isAtHome
                    item.isPurchased = previous.isPurchased && abs(previous.quantity - item.quantity) < 0.000_001
                }
                list.items = newItems
                oldItems.forEach { context.delete($0) }
            } else {
                context.insert(ShoppingList(weekStart: start, items: newItems))
            }
            try context.save()
            return true
        } catch {
            context.rollback()
            errorMessage = "Не удалось собрать список покупок. Попробуй ещё раз."
            return false
        }
    }

    private func save(in context: ModelContext) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            errorMessage = "Не удалось сохранить меню. Попробуй ещё раз."
            return false
        }
    }
}
