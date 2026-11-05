import SwiftUI
import SwiftData
import PhotosUI

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
                        Image(uiImage: image).resizable().scaledToFit()
                        Button("Удалить фото", systemImage: "trash", role: .destructive) {
                            viewModel.photo = nil
                            photoItem = nil
                        }
                    }
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(viewModel.photo == nil ? "Выбрать фото" : "Заменить фото",
                              systemImage: "photo")
                    }
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
                Task { viewModel.photo = try? await photoItem?.loadTransferable(type: Data.self) }
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
                    .disabled(!viewModel.canSave)
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
                }
                .buttonStyle(.borderless)
            }
            if let data = line.photo, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
