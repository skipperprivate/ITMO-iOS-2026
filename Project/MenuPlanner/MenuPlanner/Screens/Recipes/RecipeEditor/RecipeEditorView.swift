import PhotosUI
import SwiftData
import SwiftUI

struct RecipeEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecipeEditorViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var scrollPhase: ScrollPhase = .idle
    @FocusState private var focusedField: RecipeEditorField?

    init(recipe: Recipe? = nil) {
        _viewModel = State(initialValue: RecipeEditorViewModel(recipe: recipe))
    }

    init(importing recipe: VkusVillRecipe) {
        _viewModel = State(initialValue: RecipeEditorViewModel(importedRecipe: recipe))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        photoPicker
                        if let importedRecipe = viewModel.importedRecipe {
                            importInfo(importedRecipe)
                        }

                        section("Название") {
                            field(.name) {
                                TextField("Например, омлет с овощами", text: $viewModel.name)
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = viewModel.ingredients.first.map { .ingredientName($0.id) } }
                            }
                        }

                        section("Время и порции") {
                            field(.duration) {
                                RecipeStepper(title: "\(viewModel.durationMinutes) мин", value: $viewModel.durationMinutes, range: 1...1_440)
                            }
                            field(.servings) {
                                RecipeStepper(title: "Порций: \(viewModel.baseServings)", value: $viewModel.baseServings, range: 1...100)
                            }
                            if let importedRecipe = viewModel.importedRecipe {
                                let time = importedRecipe.cookingTime?.name ?? "не указано"
                                Text("Время в источнике: \(time). Проверь перед сохранением.")
                                    .font(AppFonts.small)
                                    .foregroundStyle(AppColors.secondaryText)
                                if !(1...100).contains(importedRecipe.portions ?? 0) {
                                    Text("Уточни количество порций: в источнике нет подходящего значения.")
                                        .font(AppFonts.small)
                                        .foregroundStyle(AppColors.secondaryText)
                                }
                            }
                        }

                        section("Ингредиенты") {
                            ForEach(viewModel.ingredients) { row in
                                RecipeIngredientEditorRow(row: row, showsErrors: viewModel.hasAttemptedSave, focus: $focusedField) {
                                    removeIngredient(id: row.id)
                                }
                                if row.id != viewModel.ingredients.last?.id { Divider() }
                            }

                            Button {
                                let row = RecipeIngredientDraft()
                                viewModel.ingredients.append(row)
                                focusedField = .ingredientName(row.id)
                            } label: {
                                Label("Добавить ингредиент", image: "RecipePlus")
                                    .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                                    .padding(.horizontal, 12)
                            }
                            .buttonStyle(RecipePressStyle())
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(viewModel.validationMessage(for: .ingredients) == nil ? Color.clear : Color.red, lineWidth: 1.5)
                            }
                            .id(RecipeEditorField.ingredients)
                            RecipeValidationMessage(error: viewModel.validationMessage(for: .ingredients))
                        }

                        section("Как готовить") {
                            field(.instructions) {
                                TextField("Добавить шаги приготовления…", text: $viewModel.instructions, axis: .vertical)
                                    .lineLimit(4...12)
                                    .focused($focusedField, equals: .instructions)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { focusedField = nil }
                    }
                }
                .safeAreaPadding(.bottom, 16)
                .scrollDismissesKeyboard(.interactively)
                .onScrollPhaseChange { _, phase in
                    scrollPhase = phase
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.visibleRect.height
                } action: { previousHeight, height in
                    guard height < previousHeight,
                          scrollPhase == .idle || scrollPhase == .animating,
                          let focusedField else { return }
                    Task { @MainActor in
                        guard self.focusedField == focusedField else { return }
                        withAnimation {
                            proxy.scrollTo(focusedField)
                        }
                    }
                }
                .onChange(of: focusedField) { _, field in
                    guard let field else { return }
                    Task { @MainActor in
                        guard focusedField == field else { return }
                        withAnimation {
                            proxy.scrollTo(field)
                        }
                    }
                }
                .background {
                    AppColors.background
                        .onTapGesture { focusedField = nil }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена", systemImage: "xmark") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Сохранить", systemImage: "checkmark") { save(using: proxy) }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.isLoadingPhoto)
                    }
                }
            }
            .font(AppFonts.body)
            .foregroundStyle(AppColors.primaryText)
            .background(AppColors.background)
            .navigationTitle(viewModel.recipe == nil ? "Новый рецепт" : "Редактировать рецепт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(AppColors.accent)
        }
        .background(AppColors.background.ignoresSafeArea())
        .task { await viewModel.loadImportedPhoto() }
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            viewModel.isLoadingPhoto = true
            defer { viewModel.isLoadingPhoto = false }
            do {
                guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else {
                    viewModel.errorMessage = "Не удалось загрузить фото. Попробуй выбрать другое."
                    return
                }
                try Task.checkCancellation()
                viewModel.photoData = data
            } catch is CancellationError {
            } catch {
                if !Task.isCancelled {
                    viewModel.errorMessage = "Не удалось загрузить фото. Попробуй выбрать другое."
                }
            }
        }
        .alert("Не удалось сохранить изменения", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Понятно", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func importInfo(_ recipe: VkusVillRecipe) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let url = recipe.sourceURL {
                Link("Оригинал рецепта во ВкусВилле", destination: url)
                    .font(AppFonts.smallStrong)
                    .foregroundStyle(AppColors.accent)
            }
            if viewModel.remotePhotoFailed, viewModel.photoData == nil {
                Text("Фото не загрузилось. Можно добавить своё или сохранить без фото.")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var photoPicker: some View {
        let photoData = viewModel.photoData
        let isLoadingPhoto = viewModel.isLoadingPhoto
        return PhotosPicker(selection: $selectedPhoto, matching: .images) {
            AppColors.warmSoft
                .frame(height: photoData == nil ? 112 : 180)
                .overlay {
                    if let photoData {
                        RecipeImageView(data: photoData)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "camera")
                                .font(.system(size: 28, weight: .regular))
                                .frame(width: 36, height: 32)
                            Text("Добавить фото блюда").font(AppFonts.smallStrong)
                        }
                        .foregroundStyle(AppColors.warm)
                    }
                }
                .overlay(alignment: .bottom) {
                    if photoData != nil {
                        Text(isLoadingPhoto ? "Загружаем фото…" : "Изменить фото")
                            .font(AppFonts.smallStrong)
                            .foregroundStyle(.white)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(.black.opacity(0.45))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay { if isLoadingPhoto { ProgressView().tint(AppColors.accent) } }
        }
        .buttonStyle(.plain)
        .disabled(isLoadingPhoto)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(AppFonts.strong)
            content()
        }
    }

    private func field<Content: View>(_ field: RecipeEditorField, @ViewBuilder content: () -> Content) -> some View {
        RecipeEditorFieldView(
            error: viewModel.validationMessage(for: field),
            reservesErrorSpace: field != .instructions,
            content: content
        )
        .id(field)
    }

    private func removeIngredient(id: UUID) {
        if focusedField == .ingredientName(id) || focusedField == .ingredientQuantity(id) {
            focusedField = nil
        }
        viewModel.removeIngredient(id: id)
    }

    private func save(using proxy: ScrollViewProxy) {
        focusedField = nil
        do {
            try viewModel.save(in: modelContext)
            dismiss()
        } catch is RecipeValidationError {
            guard let field = viewModel.firstInvalidField else { return }
            proxy.scrollTo(field)
        } catch {
            viewModel.errorMessage = "Не удалось сохранить рецепт. Попробуй ещё раз."
        }
    }
}

#Preview("Новый рецепт") {
    RecipeEditorView()
        .modelContainer(for: AppSchema.models, inMemory: true)
}
