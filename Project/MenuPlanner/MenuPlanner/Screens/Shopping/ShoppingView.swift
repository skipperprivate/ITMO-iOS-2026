import SwiftData
import SwiftUI

struct ShoppingView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.bottomBarInset) private var bottomBarInset
    @Query private var lists: [ShoppingList]
    @Query private var meals: [MealPlanEntry]
    @State private var viewModel = ShoppingViewModel()
    @State private var searchingIngredient: Ingredient?
    @State private var showsVkusVillCart = false

    let weekStart: Date
    let onOpenMenu: () -> Void

    var body: some View {
        @Bindable var viewModel = viewModel
        let week = PlanWeek.interval(containing: weekStart)
        let list = lists.first { $0.weekStart == week.start }
        let items = list?.items ?? []
        let toBuy = items.filter { !$0.isAtHome }
        let pendingPurchase = toBuy.filter { !$0.isPurchased }
        let atHome = items.filter(\.isAtHome)
        let mealCount = meals.count { $0.date >= week.start && $0.date < week.end }
        let visible = viewModel.showsAtHome ? atHome : toBuy

        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                heading(week: week, items: toBuy)

                if list != nil {
                    progress(items: toBuy, mealCount: mealCount)
                    HStack(spacing: 8) {
                        filter("Купить · \(toBuy.count)", atHome: false)
                        filter("Есть дома · \(atHome.count)", atHome: true)
                    }
                    if !viewModel.showsAtHome, !pendingPurchase.isEmpty {
                        Button {
                            showsVkusVillCart = true
                        } label: {
                            Label("Собрать корзину во ВкусВилле", systemImage: "cart")
                                .font(AppFonts.strong)
                                .foregroundStyle(AppColors.onAccent)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                    if visible.isEmpty {
                        Text(viewModel.showsAtHome ? "Пока ничего не отмечено" : "Всё необходимое есть дома")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .padding(.vertical, 16)
                    } else {
                        itemSections(visible)
                    }

                    if !viewModel.showsAtHome, !atHome.isEmpty {
                        let names = Set(atHome.map { $0.ingredient.name }).sorted().joined(separator: ", ")
                        Label {
                            Text("Уже дома: \(names)")
                                .font(AppFonts.small)
                                .foregroundStyle(AppColors.secondaryText)
                        } icon: {
                            Image("ShoppingHomeCheck").renderingMode(.template)
                                .foregroundStyle(AppColors.accent)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    ContentUnavailableView {
                        Label("Список пока пуст", systemImage: "basket")
                    } description: {
                        Text("Добавь блюда в меню и собери список покупок.")
                    } actions: {
                        Button("Открыть меню", action: onOpenMenu)
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .contentMargins(.bottom, bottomBarInset, for: .scrollContent)
        .contentMargins(.bottom, bottomBarInset, for: .scrollIndicators)
        .foregroundStyle(AppColors.primaryText)
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar, .tabBar)
        .tint(AppColors.accent)
        .sheet(item: $searchingIngredient) { ingredient in
            NavigationStack {
                VkusVillSearchView(ingredientName: ingredient.name,
                                   suggestedProductIDs: ingredient.suggestedVkusVillProductIDs ?? []) { product in
                    try viewModel.attach(product, to: ingredient, in: context)
                    searchingIngredient = nil
                }
                .navigationTitle("Найти во ВкусВилле")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Закрыть", systemImage: "xmark") { searchingIngredient = nil }
                    }
                }
            }
        }
        .sheet(isPresented: $showsVkusVillCart) {
            VkusVillCartView(items: pendingPurchase, shopping: viewModel)
        }
        .alert("Не удалось обновить список", isPresented: $viewModel.saveFailed) {
            Button("Понятно", role: .cancel) {}
        }
    }

    private func heading(week: DateInterval, items: [ShoppingItem]) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Покупки")
                    .font(AppFonts.title)
                Text(PlanWeek.title(for: week))
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
            }
            Spacer()
            if !items.isEmpty {
                ShareLink(item: shareText(items)) {
                    Image("ShoppingShare").renderingMode(.template)
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 40, height: 40)
                        .background(AppColors.surface, in: Circle())
                }
            }
        }
    }

    private func progress(items: [ShoppingItem], mealCount: Int) -> some View {
        let purchased = items.count(where: \.isPurchased)
        let dishes = RecipeFormatting.count(mealCount, one: "блюда", few: "блюд", many: "блюд")
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Список готов").font(AppFonts.strong)
                Spacer()
                Text("Куплено \(purchased) из \(items.count)").font(AppFonts.smallStrong)
            }
            ProgressView(value: Double(purchased), total: Double(max(1, items.count)))
                .tint(AppColors.accent)
            if mealCount > 0 {
                Text("Продукты из \(dishes) объединены").font(AppFonts.micro)
            }
        }
        .foregroundStyle(AppColors.accent)
        .padding(12)
        .background(AppColors.accentSoft, in: RoundedRectangle(cornerRadius: 20))
    }

    private func filter(_ title: String, atHome: Bool) -> some View {
        let selected = viewModel.showsAtHome == atHome
        return Button {
            viewModel.showsAtHome = atHome
        } label: {
            Text(title)
                .font(AppFonts.smallStrong)
                .foregroundStyle(selected ? AppColors.onAccent : AppColors.secondaryText)
                .padding(.horizontal, 20)
                .frame(minHeight: 36)
                .background(selected ? AppColors.accent : AppColors.surface, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func itemSections(_ items: [ShoppingItem]) -> some View {
        let groups = Dictionary(grouping: items) { $0.ingredient.category }
        return LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(IngredientCategory.allCases.filter { groups[$0] != nil }, id: \.self) { category in
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.title.uppercased())
                        .font(AppFonts.smallStrong)
                        .foregroundStyle(AppColors.secondaryText)
                        .padding(.bottom, 4)

                    ForEach((groups[category] ?? []).sorted(by: byName)) { item in
                        itemRow(item)
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    private func itemRow(_ item: ShoppingItem) -> some View {
        let product = item.ingredient.vkusVillProduct
        return HStack(spacing: 12) {
            Button {
                if item.isAtHome {
                    viewModel.toggleAtHome(item, in: context)
                } else {
                    viewModel.togglePurchased(item, in: context)
                }
            } label: {
                let checked = item.isPurchased || item.isAtHome
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(checked ? AppColors.accent : AppColors.border, lineWidth: 1.5)
                        .background(checked ? AppColors.accent : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                        .frame(width: 24, height: 24)
                        .overlay {
                            if checked {
                                Image("ShoppingCheck").renderingMode(.template)
                                    .foregroundStyle(AppColors.onAccent)
                            }
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.ingredient.name)
                            .font(AppFonts.body)
                            .foregroundStyle(checked ? AppColors.secondaryText : AppColors.primaryText)
                        if let product {
                            Text(product.displayName)
                                .font(AppFonts.small)
                                .foregroundStyle(AppColors.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(quantity(for: item))
                        .font(AppFonts.smallStrong)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .frame(minHeight: 40)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Menu {
                if let url = product?.pageURL {
                    Link(destination: url) {
                        Label("Открыть во ВкусВилле", systemImage: "arrow.up.right")
                    }
                }
                Button(product == nil ? "Найти во ВкусВилле" : "Выбрать другой товар",
                       systemImage: "magnifyingglass") {
                    searchingIngredient = item.ingredient
                }
                Button(item.isAtHome ? "Вернуть в покупки" : "Есть дома", systemImage: "house") {
                    viewModel.toggleAtHome(item, in: context)
                }
            } label: {
                Image(systemName: product == nil ? "ellipsis" : "link")
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
        }
    }

    private func quantity(for item: ShoppingItem) -> String {
        if item.unit == .gram, item.quantity >= 1000 {
            return RecipeFormatting.quantity(item.quantity / 1000, unit: .kilogram)
        }
        if item.unit == .milliliter, item.quantity >= 1000 {
            return RecipeFormatting.quantity(item.quantity / 1000, unit: .liter)
        }
        return RecipeFormatting.quantity(item.quantity, unit: item.unit)
    }

    private func shareText(_ items: [ShoppingItem]) -> String {
        items.sorted(by: byName).map {
            "\($0.isPurchased ? "✓" : "•") \($0.ingredient.name) — \(quantity(for: $0))"
        }.joined(separator: "\n")
    }

    private func byName(_ lhs: ShoppingItem, _ rhs: ShoppingItem) -> Bool {
        lhs.ingredient.name.localizedStandardCompare(rhs.ingredient.name) == .orderedAscending
    }
}
