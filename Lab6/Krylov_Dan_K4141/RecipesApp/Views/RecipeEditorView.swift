import SwiftUI
import SwiftData

struct RecipeEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecipeEditorViewModel

    init(recipe: Recipe? = nil) {
        _viewModel = State(initialValue: RecipeEditorViewModel(recipe: recipe))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Название") {
                    TextField("Название", text: $viewModel.title)
                }
                Section("Категория") {
                    Picker("Категория", selection: $viewModel.category) {
                        ForEach(MealType.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Продукты") {
                    ForEach($viewModel.ingredients) { $line in
                        TextField("Продукт", text: $line.text)
                    }
                    .onDelete(perform: viewModel.removeIngredients)
                    Button("Добавить продукт", action: viewModel.addIngredient)
                }
                Section("Шаги") {
                    ForEach($viewModel.steps) { $line in
                        TextField("Шаг", text: $line.text)
                    }
                    .onDelete(perform: viewModel.removeSteps)
                    Button("Добавить шаг", action: viewModel.addStep)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Редактирование" : "Новый рецепт")
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
