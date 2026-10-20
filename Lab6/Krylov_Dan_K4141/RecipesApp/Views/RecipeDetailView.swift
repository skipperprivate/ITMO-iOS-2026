import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var viewModel = RecipeDetailViewModel()
    @State private var showEditor = false

    var body: some View {
        List {
            Label(recipe.category.title, systemImage: recipe.category.icon)
            Section("Продукты") {
                ForEach(recipe.ingredientList, id: \.self) { Text("• \($0)") }
            }
            Section("Шаги") {
                ForEach(Array(recipe.stepList.enumerated()), id: \.offset) { index, step in
                    Text("\(index + 1). \(step)")
                }
            }
        }
        .overlay {
            if viewModel.isUploading { ProgressView() }
        }
        .navigationTitle(recipe.title)
        .toolbar {
            Button("Отправить", systemImage: "icloud.and.arrow.up") {
                Task { await viewModel.upload(recipe) }
            }
            .disabled(viewModel.isUploading)
            Button("Изменить") { showEditor = true }
        }
        .sheet(isPresented: $showEditor) {
            RecipeEditorView(recipe: recipe)
        }
        .alert("Отправка на сервер", isPresented: $viewModel.showMessage) {
            Button("OK") {}
        } message: {
            Text(viewModel.message ?? "")
        }
    }
}
