import SwiftUI

@MainActor
struct NetworkExamplesView<Presenter: NetworkExamplesViewOutput>: View {
    @StateObject private var presenter: Presenter
    @State private var requestID = UUID()
    @State private var selectedExample: NetworkExample?

    init(presenter: @autoclosure @escaping () -> Presenter) {
        _presenter = StateObject(wrappedValue: presenter())
    }

    var body: some View {
        List {
            Section {
                ForEach(presenter.state.examples) { example in
                    Button {
                        selectedExample = example
                        requestID = UUID()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(presenter.state.title(for: example))
                                Text(presenter.state.endpoint(for: example))
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if presenter.state.activeExample == example {
                                ProgressView()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(presenter.state.activeExample != nil)
                    .accessibilityIdentifier("networkExamples.\(example.rawValue)")
                }
            } footer: {
                Text(
                    "Каждая кнопка отправляет настоящий POST на dummyjson.com. Для примеров ошибок сервер специально возвращает выбранный HTTP-код. Ошибка появится в тосте на 5 секунд."
                )
            }

            if let result = presenter.state.result {
                Section("Ответ сервера") {
                    Label(result, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("Проверка сети")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Назад", systemImage: "chevron.left", action: presenter.goBack)
            }
        }
        .errorToast(presenter.state.toast, onDismiss: presenter.dismissToast)
        .task(id: requestID) {
            guard let example = selectedExample else { return }
            selectedExample = nil
            await presenter.perform(example)
        }
    }
}
