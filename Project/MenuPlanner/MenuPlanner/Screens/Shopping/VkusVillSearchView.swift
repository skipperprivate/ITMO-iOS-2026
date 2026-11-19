import OSLog
import SwiftUI

@Observable
@MainActor
private final class VkusVillSearchViewModel {
    enum State {
        case idle, loading, results([VkusVillProduct]), failed
    }

    private(set) var state: State = .idle
    private(set) var suggestions: [VkusVillProduct] = []
    private let catalog = VkusVillCatalog()
    private let logger = Logger(subsystem: "FergeS.MenuPlanner", category: "VkusVillCatalog")

    func loadSuggestions(_ ids: [Int]) async {
        suggestions = []
        for id in ids.prefix(3) {
            guard !Task.isCancelled else { return }
            if let product = try? await catalog.product(id: id), !Task.isCancelled {
                suggestions.append(product)
            }
        }
    }

    func search(_ query: String) async {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !Task.isCancelled else { return }
        guard !query.isEmpty else {
            state = .idle
            return
        }
        state = .loading
        do {
            try await Task.sleep(for: .milliseconds(300))
            let products = try await catalog.search(query)
            try Task.checkCancellation()
            state = .results(products)
        } catch {
            guard !Task.isCancelled else { return }
            let failure = error as NSError
            logger.error("Ошибка запроса каталога: \(failure.domain, privacy: .public) (\(failure.code))")
            state = .failed
        }
    }
}

struct VkusVillSearchView: View {
    @State private var viewModel = VkusVillSearchViewModel()
    @State private var query: String
    @State private var attempt = 0
    @State private var saveFailed = false

    let onSelect: (VkusVillProduct) throws -> Void
    private let ingredientName: String
    private let suggestedProductIDs: [Int]

    private struct Request: Equatable {
        let query: String
        let attempt: Int
    }

    init(ingredientName: String, suggestedProductIDs: [Int] = [],
         onSelect: @escaping (VkusVillProduct) throws -> Void) {
        _query = State(initialValue: ingredientName)
        self.ingredientName = ingredientName
        self.suggestedProductIDs = suggestedProductIDs
        self.onSelect = onSelect
    }

    var body: some View {
        let request = Request(query: query, attempt: attempt)

        VStack(alignment: .leading, spacing: 12) {
            TextField("Название товара", text: $query)
                .font(AppFonts.body)
                .padding(12)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))

            results
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .background(AppColors.background.ignoresSafeArea())
        .tint(AppColors.accent)
        .task(id: request) { await viewModel.search(request.query) }
        .task(id: suggestedProductIDs) { await viewModel.loadSuggestions(suggestedProductIDs) }
        .alert("Не удалось сохранить выбранный товар", isPresented: $saveFailed) {
            Button("Понятно", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var results: some View {
        let suggestions = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare(ingredientName.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
            ? viewModel.suggestions : []
        if !suggestions.isEmpty {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Text("Товары из рецепта")
                        .font(AppFonts.smallStrong)
                        .foregroundStyle(AppColors.secondaryText)
                    ForEach(suggestions) { product in
                        selectionButton(product)
                    }
                    if case .results(let products) = viewModel.state {
                        let ids = Set(suggestions.map(\.id))
                        let others = products.filter { !ids.contains($0.id) }
                        if !others.isEmpty {
                            Text("Другие результаты")
                                .font(AppFonts.smallStrong)
                                .foregroundStyle(AppColors.secondaryText)
                            ForEach(others) { product in selectionButton(product) }
                        }
                    }
                }
                .padding(.bottom, 12)
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            searchResults
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView("Введи название товара", systemImage: "magnifyingglass")
        case .loading:
            ProgressView("Ищем товары…")
        case .failed:
            ContentUnavailableView {
                Label("Не удалось загрузить товары", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Повторить") { attempt += 1 }
                    .buttonStyle(.bordered)
            }
        case .results(let products):
            if products.isEmpty {
                ContentUnavailableView("Ничего не найдено", systemImage: "magnifyingglass",
                                       description: Text("Попробуй изменить запрос."))
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(products) { product in
                            selectionButton(product)
                        }
                    }
                    .padding(.bottom, 12)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    private func selectionButton(_ product: VkusVillProduct) -> some View {
        Button {
            do {
                try onSelect(product)
            } catch {
                saveFailed = true
            }
        } label: {
            productRow(product)
        }
        .buttonStyle(.plain)
    }

    private func productRow(_ product: VkusVillProduct) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: product.photoURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image("TabBag")
                    .renderingMode(.template)
                    .foregroundStyle(AppColors.accent)
            }
            .frame(width: 54, height: 54)
            .background(AppColors.accentSoft, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.primaryText)
                if let price = product.priceText {
                    Text("\(price) / \(product.cartUnit)")
                        .font(AppFonts.smallStrong)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "link.badge.plus")
                .foregroundStyle(AppColors.accent)
        }
        .padding(12)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
    }
}
