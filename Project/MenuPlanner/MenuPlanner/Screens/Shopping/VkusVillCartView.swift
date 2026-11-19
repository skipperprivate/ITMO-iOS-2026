import SwiftData
import SwiftUI

struct VkusVillCartView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel: VkusVillCartViewModel
    @State private var submission = 0

    let shopping: ShoppingViewModel

    init(items: [ShoppingItem], shopping: ShoppingViewModel) {
        _viewModel = State(initialValue: VkusVillCartViewModel(items: items))
        self.shopping = shopping
    }

    var body: some View {
        NavigationStack {
            Group {
                if let line = viewModel.currentLine {
                    productPicker(for: line)
                } else {
                    review
                }
            }
            .navigationTitle("Корзина ВкусВилла")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть", systemImage: "xmark") { dismiss() }
                }
            }
        }
        .tint(AppColors.accent)
        .task(id: submission) {
            guard submission > 0 else { return }
            await viewModel.buildCart()
        }
    }

    private func productPicker(for line: VkusVillCartViewModel.Line) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(line.ingredient.name).font(AppFonts.section)
                Text("Нужно: \(line.requiredAmount)")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
                if !viewModel.pendingLines.isEmpty {
                    Text("Осталось подобрать: \(viewModel.pendingLines.count)")
                        .font(AppFonts.small)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            VkusVillSearchView(ingredientName: line.ingredient.name,
                               suggestedProductIDs: line.ingredient.suggestedVkusVillProductIDs ?? []) { product in
                try shopping.attach(product, to: line.ingredient, in: context)
                viewModel.use(product, for: line)
            }
            .id(line.id)

            Button(line.ingredient.vkusVillProduct == nil ? "Пропустить" : "Оставить текущий товар") {
                viewModel.skip(line)
            }
            .font(AppFonts.strong)
            .frame(maxWidth: .infinity)
            .padding(12)
        }
        .background(AppColors.background.ignoresSafeArea())
    }

    private var review: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Проверь количество")
                    .font(AppFonts.section)
                    .foregroundStyle(AppColors.primaryText)
                Text("После сборки открой корзину во ВкусВилле и проверь наличие по своему адресу.")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)

                ForEach(viewModel.lines) { line in
                    if let product = line.ingredient.vkusVillProduct, !viewModel.skipped.contains(line.id) {
                        reviewRow(line, product: product)
                    }
                }

                if !viewModel.skipped.isEmpty {
                    let names = viewModel.lines.filter { viewModel.skipped.contains($0.id) }
                        .map { $0.ingredient.name }.joined(separator: ", ")
                    Text("Без товара: \(names)")
                        .font(AppFonts.small)
                        .foregroundStyle(AppColors.secondaryText)
                    Button("Подобрать пропущенные") { viewModel.revisitSkipped() }
                        .disabled(viewModel.isLoading)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppFonts.small)
                        .foregroundStyle(.red)
                }

                if let url = viewModel.cartURL {
                    Link(destination: url) {
                        actionLabel("Открыть во ВкусВилле")
                    }
                } else {
                    Button {
                        submission += 1
                    } label: {
                        actionLabel(viewModel.isLoading ? "Собираем корзину…" : "Получить ссылку на корзину")
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading || viewModel.lines.allSatisfy { viewModel.skipped.contains($0.id) })
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background.ignoresSafeArea())
    }

    private func reviewRow(_ line: VkusVillCartViewModel.Line, product: VkusVillProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.displayName)
                .font(AppFonts.strong)
                .foregroundStyle(AppColors.primaryText)
            Text("\(line.ingredient.name) · нужно \(line.requiredAmount)")
                .font(AppFonts.small)
                .foregroundStyle(AppColors.secondaryText)
            HStack {
                TextField("Количество", text: Binding(
                    get: { viewModel.quantities[line.id, default: ""] },
                    set: { viewModel.setQuantity($0, for: line.id) }
                ))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
                Text(product.cartUnit)
                    .foregroundStyle(AppColors.secondaryText)
                Spacer()
                Button("Заменить") { viewModel.changeProduct(for: line) }
            }
            .disabled(viewModel.isLoading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func actionLabel(_ title: String) -> some View {
        Text(title)
            .font(AppFonts.strong)
            .foregroundStyle(AppColors.onAccent)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 16))
    }
}
