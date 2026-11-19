import SwiftUI

struct RecipeImportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = RecipeImportViewModel()
    @State private var query: String
    @State private var page = 1
    @State private var attempt = 0
    @State private var selection: VkusVillRecipe?

    private struct Request: Equatable {
        let query: String
        let page: Int
        let attempt: Int
    }

    init(query: String = "") {
        _query = State(initialValue: query)
    }

    var body: some View {
        let request = Request(query: query, page: page, attempt: attempt)
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Рецепты из каталога ВкусВилла")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)

                TextField("Например, сырники", text: $query)
                    .font(AppFonts.body)
                    .padding(12)
                    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))
                    .submitLabel(.search)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Найти в интернете")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть", systemImage: "xmark") { dismiss() }
                }
            }
        }
        .tint(AppColors.accent)
        .onChange(of: query) { _, _ in page = 1 }
        .task(id: request) { await viewModel.load(request.query, page: request.page) }
        .sheet(item: $selection) { recipe in
            RecipeEditorView(importing: recipe)
        }
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.recipes.isEmpty {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recipes) { recipe in
                        Button {
                            selection = recipe
                        } label: {
                            recipeRow(recipe)
                        }
                        .buttonStyle(.plain)
                    }
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.hasError {
                        Button("Повторить") { attempt += 1 }
                    } else if viewModel.hasMore {
                        Button("Показать ещё") { page += 1 }
                    }
                }
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
        } else if viewModel.isLoading {
            ProgressView("Ищем рецепты…")
        } else if viewModel.hasError {
            ContentUnavailableView {
                Label("Не удалось загрузить рецепты", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Повторить") { attempt += 1 }
            }
        } else if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ContentUnavailableView("Введи название блюда", systemImage: "magnifyingglass")
        } else {
            ContentUnavailableView.search(text: query)
        }
    }

    private func recipeRow(_ recipe: VkusVillRecipe) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: recipe.photoURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "fork.knife")
                    .foregroundStyle(AppColors.warm)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.warmSoft)
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(AppFonts.card)
                    .foregroundStyle(AppColors.primaryText)
                let portions = recipe.portions.map {
                    RecipeFormatting.count($0, one: "порция", few: "порции", many: "порций")
                }
                let details = [recipe.cookingTime?.name, portions].compactMap { $0 }.joined(separator: " · ")
                if !details.isEmpty {
                    Text(details)
                        .font(AppFonts.small)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "plus")
                .foregroundStyle(AppColors.accent)
        }
        .padding(12)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
    }
}
