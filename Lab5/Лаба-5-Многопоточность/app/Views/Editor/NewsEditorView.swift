import SwiftUI

struct NewsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NewsEditorViewModel

    init(item: Item?, repository: NewsRepository) {
        _viewModel = State(initialValue: NewsEditorViewModel(item: item, repository: repository))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Заголовок") {
                    TextField("Заголовок новости", text: $viewModel.title)
                }
                Section("Публикация") {
                    TextField("Источник", text: $viewModel.source)
                    Picker("Категория", selection: $viewModel.category) {
                        ForEach(["Общее", "Технологии", "Наука", "Культура", "Спорт"], id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                }
                Section("Текст новости") {
                    TextEditor(text: $viewModel.text)
                        .frame(minHeight: 180)
                        .accessibilityLabel("Текст новости")
                }
                if let item = viewModel.item {
                    Section("Дата публикации") {
                        Text(item.timestamp, format: .dateTime.day().month().year().hour().minute())
                    }
                }
            }
            .navigationTitle(viewModel.item == nil ? "Новая новость" : "Редактирование")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        if viewModel.save() { dismiss() }
                    }
                        .disabled(!viewModel.canSave)
                }
            }
            .interactiveDismissDisabled()
            .alert("Не удалось сохранить новость", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("Понятно", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

}
