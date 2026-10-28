import SwiftUI

struct NewsStatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: NewsStatisticsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Статистика ленты") {
                    Text("Публикаций в ленте: \(viewModel.texts.count)")
                    Text("Считается полный текст новостей. Слово — последовательность символов между пробелами или переносами строк.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if viewModel.isRunning {
                        ProgressView(value: viewModel.fraction)
                        Button("Отменить расчёт", role: .cancel) { viewModel.cancel() }
                    } else {
                        Button(viewModel.hasStarted ? "Рассчитать повторно" : "Рассчитать в фоне") {
                            viewModel.start()
                        }
                    }
                    Text(viewModel.status)
                        .foregroundStyle(.secondary)
                }
                if let result = viewModel.result {
                    Section("Результат") {
                        LabeledContent("Публикации", value: "\(result.articles)")
                        LabeledContent("Слова", value: "\(result.words)")
                        LabeledContent("Символы с пробелами", value: "\(result.characters)")
                        LabeledContent("Обработка вне главного потока",
                                       value: result.ranInBackground ? "Да" : "Нет")
                    }
                }
                Section {
                    Button("Проверить отклик: \(viewModel.testCount)") {
                        viewModel.checkResponsiveness()
                    }
                    .disabled(!viewModel.isRunning)
                } footer: {
                    Text("Во время подсчёта нажимайте кнопку: счётчик должен увеличиваться. Для демонстрации добавлена задержка 3 секунды. Можно закрыть экран — расчёт продолжится.")
                }
            }
            .navigationTitle("Статистика новостей")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}
