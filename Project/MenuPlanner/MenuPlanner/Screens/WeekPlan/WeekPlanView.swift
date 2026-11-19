import SwiftData
import SwiftUI

struct WeekPlanView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.bottomBarInset) private var bottomBarInset
    @Query private var entries: [MealPlanEntry]
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @AppStorage("defaultMealServings") private var defaultServings = 2
    @State private var viewModel = WeekPlanViewModel()
    @State private var editingSlot: Slot?
    @State private var showsServings = false

    let onCollect: (Date) -> Void

    private let mealTypes: [MealType] = [.breakfast, .lunch, .dinner]

    private struct Slot: Identifiable {
        let date: Date
        let type: MealType
        let entry: MealPlanEntry?
        var id: MealType { type }
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        let week = viewModel.week
        let weekEntries = viewModel.entries(in: week, from: entries)
        let dayEntries = weekEntries.filter {
            PlanWeek.calendar.isDate($0.date, inSameDayAs: viewModel.selectedDate)
        }

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heading
                weekNavigation(week)
                weekCalendar(weekEntries)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(viewModel.selectedDate.formatted(
                            Date.FormatStyle().weekday(.wide).day().month(.wide).locale(Locale(identifier: "ru_RU"))
                        ).capitalizedFirstLetter)
                            .font(AppFonts.strong)
                        Spacer()
                        Text("\(dayEntries.count) из \(mealTypes.count) блюд")
                            .font(AppFonts.small)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .padding(.bottom, 12)

                    ForEach(mealTypes, id: \.self) { type in
                        let entry = dayEntries.first { $0.mealType == type }
                        Button {
                            editingSlot = Slot(date: viewModel.selectedDate, type: type, entry: entry)
                        } label: {
                            if let entry {
                                plannedMeal(entry)
                            } else {
                                emptyMeal(type)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    if viewModel.collectShoppingList(from: weekEntries, for: week, in: context) {
                        onCollect(week.start)
                    }
                } label: {
                    Text("Собрать список покупок")
                        .font(AppFonts.strong)
                        .foregroundStyle(AppColors.onAccent)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 16))
                        .opacity(weekEntries.isEmpty ? 0.5 : 1)
                }
                .buttonStyle(.plain)
                .disabled(weekEntries.isEmpty)

                let count = RecipeFormatting.count(weekEntries.count, one: "блюдо", few: "блюда", many: "блюд")
                Text("\(count) на неделю")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .contentMargins(.bottom, bottomBarInset, for: .scrollContent)
        .contentMargins(.bottom, bottomBarInset, for: .scrollIndicators)
        .foregroundStyle(AppColors.primaryText)
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar, .tabBar)
        .sheet(item: $editingSlot) { slot in
            MealSlotEditor(
                type: slot.type,
                recipes: recipes.filter { !$0.isBuiltIn },
                entry: slot.entry,
                defaultServings: defaultServings,
                onSave: { recipe, servings in
                    viewModel.saveMeal(slot.type, date: slot.date, existing: slot.entry, recipe: recipe,
                                       servings: servings, in: context)
                },
                onRemove: { viewModel.removeMeal($0, in: context) }
            )
        }
        .sheet(isPresented: $showsServings) {
            NavigationStack {
                Form {
                    Stepper("Порций: \(defaultServings)", value: $defaultServings, in: 1...100)
                }
                .navigationTitle("Порции по умолчанию")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Готово") { showsServings = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Не удалось обновить меню", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Понятно", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var heading: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ПО ПОРЦИЯМ")
                    .font(AppFonts.micro)
                    .foregroundStyle(AppColors.accent)
                Text("Моя неделя")
                    .font(AppFonts.title)
            }
            Spacer()
            Button {
                showsServings = true
            } label: {
                Image("WeekPeople").renderingMode(.template)
                    .frame(width: 40, height: 40)
                    .background(AppColors.surface, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private func weekNavigation(_ week: DateInterval) -> some View {
        HStack {
            weekButton("WeekBack", by: -1)
            Spacer()
            Text(PlanWeek.title(for: week))
                .font(AppFonts.strong)
            Spacer()
            weekButton("WeekChevron", by: 1)
        }
    }

    private func weekButton(_ icon: String, by offset: Int) -> some View {
        Button {
            viewModel.moveWeek(by: offset)
        } label: {
            Image(icon).renderingMode(.template)
                .foregroundStyle(AppColors.secondaryText)
                .frame(width: 32, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func weekCalendar(_ entries: [MealPlanEntry]) -> some View {
        HStack(spacing: 4) {
            ForEach(viewModel.days, id: \.self) { date in
                let selected = PlanWeek.calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
                let planned = entries.contains { PlanWeek.calendar.isDate($0.date, inSameDayAs: date) }
                Button {
                    viewModel.selectedDate = date
                } label: {
                    VStack(spacing: 4) {
                        Text(date.formatted(Date.FormatStyle().weekday(.short).locale(Locale(identifier: "ru_RU"))).uppercased())
                            .font(AppFonts.micro)
                            .foregroundStyle(selected ? AppColors.onAccent : AppColors.secondaryText)
                        Text(PlanWeek.calendar.component(.day, from: date).formatted())
                            .font(AppFonts.strong)
                        Image(selected ? "WeekDotSelected" : "WeekDot")
                            .renderingMode(.template)
                            .foregroundStyle(selected ? AppColors.onAccent : planned ? AppColors.accent : AppColors.border)
                    }
                    .foregroundStyle(selected ? AppColors.onAccent : AppColors.primaryText)
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .background(selected ? AppColors.accent : Color.clear, in: RoundedRectangle(cornerRadius: 16))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func plannedMeal(_ entry: MealPlanEntry) -> some View {
        HStack(spacing: 12) {
            AppColors.warmSoft
                .frame(width: 76, height: 76)
                .overlay { RecipeImageView(data: entry.recipe.photoData) }
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mealType.title.uppercased())
                    .font(AppFonts.micro)
                    .foregroundStyle(AppColors.warm)
                Text(entry.recipe.name)
                    .font(AppFonts.card)
                let portions = RecipeFormatting.count(entry.servings, one: "порция", few: "порции", many: "порций")
                Text("\(entry.recipe.durationMinutes) мин · \(portions)")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image("WeekRowChevron").renderingMode(.template)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(12)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 20))
        .contentShape(Rectangle())
    }

    private func emptyMeal(_ type: MealType) -> some View {
        HStack(spacing: 12) {
            Image("WeekPlus").renderingMode(.template)
                .foregroundStyle(AppColors.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Что на \(type.title.lowercased())?")
                    .font(AppFonts.strong)
                    .foregroundStyle(AppColors.accent)
                Text("Выбрать блюдо")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
            }
            Spacer()
        }
        .padding(12)
        .background(AppColors.accentSoft, in: RoundedRectangle(cornerRadius: 20))
        .contentShape(Rectangle())
    }
}

private struct MealSlotEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recipe: Recipe?
    @State private var servings: Int
    @State private var saveFailed = false

    let type: MealType
    let recipes: [Recipe]
    let entry: MealPlanEntry?
    let onSave: (Recipe, Int) -> Bool
    let onRemove: (MealPlanEntry) -> Bool

    init(type: MealType, recipes: [Recipe], entry: MealPlanEntry?, defaultServings: Int,
         onSave: @escaping (Recipe, Int) -> Bool, onRemove: @escaping (MealPlanEntry) -> Bool) {
        self.type = type
        self.recipes = recipes
        self.entry = entry
        self.onSave = onSave
        self.onRemove = onRemove
        _recipe = State(initialValue: entry?.recipe ?? recipes.first)
        _servings = State(initialValue: entry?.servings ?? defaultServings)
    }

    var body: some View {
        NavigationStack {
            if recipes.isEmpty {
                ContentUnavailableView("Пока нет рецептов", systemImage: "book",
                                       description: Text("Добавь блюдо на вкладке «Рецепты»."))
                    .navigationTitle(type.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Закрыть") { dismiss() }
                        }
                    }
            } else {
                Form {
                    Picker("Блюдо", selection: $recipe) {
                        ForEach(recipes) { recipe in
                            Text(recipe.name).tag(Optional(recipe))
                        }
                    }
                    Stepper("Порций: \(servings)", value: $servings, in: 1...100)
                    if let entry {
                        Button("Убрать из меню", role: .destructive) {
                            if onRemove(entry) { dismiss() } else { saveFailed = true }
                        }
                    }
                    Button {
                        guard let recipe else { return }
                        if onSave(recipe, servings) { dismiss() } else { saveFailed = true }
                    } label: {
                        Text(entry == nil ? "Добавить в меню" : "Сохранить")
                            .font(AppFonts.strong)
                            .foregroundStyle(AppColors.onAccent)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .disabled(recipe == nil)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(AppColors.background)
                .navigationTitle(type.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") { dismiss() }
                    }
                }
            }
        }
        .tint(AppColors.accent)
        .alert("Не удалось сохранить меню", isPresented: $saveFailed) {
            Button("Понятно", role: .cancel) {}
        }
    }
}

private extension String {
    var capitalizedFirstLetter: String { prefix(1).uppercased() + dropFirst() }
}
