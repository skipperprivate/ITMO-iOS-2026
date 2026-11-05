import PhotosUI
import SwiftData
import SwiftUI

struct RecipeEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecipeEditorViewModel
    @State private var photoItem: PhotosPickerItem?

    init(recipe: Recipe? = nil) {
        _viewModel = State(initialValue: RecipeEditorViewModel(recipe: recipe))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Название", text: $viewModel.title)
                    Picker("Категория", selection: $viewModel.category) {
                        ForEach(MealType.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Фото") {
                    if let data = viewModel.photo, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .accessibilityLabel("Фото рецепта")
                        Button("Удалить фото", systemImage: "trash", role: .destructive) {
                            viewModel.photo = nil
                            photoItem = nil
                        }
                        .disabled(viewModel.isLoadingPhoto)
                    }
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(viewModel.photo == nil ? "Выбрать фото" : "Заменить фото",
                              systemImage: "photo")
                    }
                    .disabled(viewModel.isLoadingPhoto)

                    TextField("Ссылка на фото (https://…)", text: $viewModel.photoAddress)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(viewModel.isLoadingPhoto)

                    Button("Загрузить по ссылке", systemImage: "link") {
                        Task {
                            await viewModel.loadPhotoFromURL()
                        }
                    }
                    .disabled(viewModel.photoAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                              || viewModel.isLoadingPhoto)

                    if viewModel.isLoadingPhoto {
                        ProgressView("Загрузка фото…")
                    }
                    Text("Вставьте прямую ссылку на изображение. Загруженное фото будет доступно без интернета.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Section("Продукты") {
                    ForEach($viewModel.ingredients) { $line in
                        TextField("Продукт", text: $line.text)
                    }
                    .onDelete(perform: viewModel.removeIngredients)
                    Button("Добавить продукт", systemImage: "plus", action: viewModel.addIngredient)
                }
                Section("Шаги") {
                    ForEach($viewModel.steps) { $line in
                        StepRow(line: $line)
                    }
                    .onDelete(perform: viewModel.removeSteps)
                    Button("Добавить шаг", systemImage: "plus", action: viewModel.addStep)
                }
            }
            .onChange(of: photoItem) {
                guard let selectedPhoto = photoItem else {
                    return
                }
                viewModel.isLoadingPhoto = true
                viewModel.photoError = nil
                Task {
                    defer { viewModel.isLoadingPhoto = false }
                    do {
                        let data = try await selectedPhoto.loadTransferable(type: Data.self)
                        if let data, UIImage(data: data) != nil {
                            viewModel.photo = data
                        } else {
                            viewModel.photoError = "Не удалось прочитать выбранное изображение."
                        }
                    } catch {
                        viewModel.photoError = error.localizedDescription
                    }
                }
            }
            .alert("Не удалось загрузить фото", isPresented: $viewModel.showPhotoError) {
                Button("OK") {}
            } message: {
                Text(viewModel.photoError ?? "")
            }
            .navigationTitle(viewModel.isEditing ? "Редактирование" : "Новый рецепт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        viewModel.save(context: context)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave || viewModel.isLoadingPhoto)
                }
            }
        }
    }
}

private struct StepRow: View {
    @Binding var line: EditableLine
    @State private var item: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Шаг", text: $line.text)
                PhotosPicker(selection: $item, matching: .images) {
                    Image(systemName: line.photo == nil ? "camera" : "camera.fill")
                        .accessibilityLabel("Выбрать фото шага")
                }
                .buttonStyle(.borderless)
            }
            if let data = line.photo, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityLabel("Фото шага")
                Button("Удалить фото", systemImage: "trash", role: .destructive) {
                    line.photo = nil
                    item = nil
                }
                .buttonStyle(.borderless)
            }
        }
        .onChange(of: item) {
            Task { line.photo = try? await item?.loadTransferable(type: Data.self) }
        }
    }
}
