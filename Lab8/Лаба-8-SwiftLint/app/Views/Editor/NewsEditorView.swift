import SwiftUI

struct NewsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NewsEditorViewModel
    @State private var shouldSubmit = false
    @State private var showSubmissionConfirmation = false

    init(item: Item?, repository: NewsRepository, publisher: any NewsPublishing = NewsAPIClient()) {
        _viewModel = State(initialValue: NewsEditorViewModel(item: item, repository: repository, publisher: publisher))
    }

    var body: some View {
        NavigationStack {
            Form {
                Group {
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
                }
                .disabled(viewModel.fieldsAreLocked)

                if viewModel.item == nil {
                    Section {
                        if viewModel.isSubmitting {
                            ProgressView("Отправка публикации…")
                        }
                        Button(viewModel.acceptedPost == nil ? "Отправить на учебный сервер" : "Повторить сохранение на устройстве") {
                            shouldSubmit = true
                        }
                        .disabled(!viewModel.canSave || shouldSubmit || showSubmissionConfirmation)
                    } footer: {
                        Text("DummyJSON принимает заголовок и текст, но не хранит новые записи постоянно. После ответа сервера публикация сохраняется на устройстве. Источник и категория сохраняются только локально.")
                    }
                } else if let item = viewModel.item {
                    Section("Дата создания") {
                        Text(item.timestamp, format: .dateTime.day().month().year().hour().minute())
                    }
                    Section {
                        Text("Изменения сохраняются только на устройстве.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(viewModel.item == nil ? "Новая новость" : "Редактирование")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .disabled(viewModel.isSubmitting || shouldSubmit)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить локально") {
                        if viewModel.save() { dismiss() }
                    }
                    .disabled(!viewModel.canSave || viewModel.acceptedPost != nil || shouldSubmit)
                }
            }
            .interactiveDismissDisabled()
            // View запускает действие ViewModel. URL, HTTP и JSON здесь отсутствуют.
            .task(id: shouldSubmit) {
                guard shouldSubmit else { return }
                showSubmissionConfirmation = await viewModel.submit()
                shouldSubmit = false
            }
            .alert("Ошибка", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("Понятно", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Сервер принял публикацию", isPresented: $showSubmissionConfirmation) {
                Button("Готово") { dismiss() }
            } message: {
                Text("ID в ответе: \(viewModel.acceptedPost?.id ?? 0). Публикация сохранена на устройстве и появится в ленте. Учебный сервер не сохраняет её постоянно.")
            }
        }
    }
}
