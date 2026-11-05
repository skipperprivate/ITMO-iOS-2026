import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var viewModel = RecipeDetailViewModel()
    @State private var showEditor = false

    var body: some View {
        List {
            if let data = recipe.photo, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                    .listRowInsets(EdgeInsets())
            }
            Label(recipe.category.title, systemImage: recipe.category.icon)
            if !recipe.ingredientList.isEmpty {
                Section("Продукты") {
                    ForEach(recipe.ingredientList, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                    }
                }
            }
            if !recipe.stepList.isEmpty {
                Section("Шаги") {
                    ForEach(Array(recipe.stepList.enumerated()), id: \.offset) { index, step in
                        VStack(alignment: .leading) {
                            Text("\(index + 1). \(step)")
                            if let data = recipe.stepPhoto(at: index),
                               let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            if viewModel.isUploading { ProgressView() }
        }
        .navigationTitle(recipe.title)
        .toolbar {
            Button("Избранное", systemImage: recipe.isFavorite ? "heart.fill" : "heart") {
                viewModel.toggleFavorite(recipe)
            }
            Button("Отправить", systemImage: "square.and.arrow.up") {
                Task { await viewModel.upload(recipe) }
            }
            .disabled(viewModel.isUploading)
            Button("Изменить", systemImage: "pencil") { showEditor = true }
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
