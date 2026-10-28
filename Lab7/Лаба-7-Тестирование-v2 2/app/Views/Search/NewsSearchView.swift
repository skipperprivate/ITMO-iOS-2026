import SwiftUI

struct NewsSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NewsSearchViewModel

    init(documents: [NewsSearchDocument]) {
        _viewModel = State(initialValue: NewsSearchViewModel(documents: documents))
    }

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isSearching {
                    ProgressView("Поиск…")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                } else if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Введите слово из заголовка или текста новости.")
                        .foregroundStyle(.secondary)
                } else if viewModel.matches.isEmpty {
                    Text("Ничего не найдено")
                        .foregroundStyle(.secondary)
                } else {
                    Section("Найдено: \(viewModel.matches.count)") {
                        ForEach(viewModel.matches, id: \.self) { index in
                            NavigationLink {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(viewModel.documents[index].title).font(.title.bold())
                                        Text(viewModel.documents[index].text).textSelection(.enabled)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                }
                                .navigationTitle("Публикация")
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(viewModel.documents[index].title).font(.headline)
                                    Text(viewModel.documents[index].text)
                                        .lineLimit(2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Поиск новостей")
            .searchable(text: $viewModel.query, prompt: "Заголовок или текст")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            // SwiftUI отменяет предыдущую задачу при смене запроса и закрытии.
            .task(id: viewModel.query) { await viewModel.search(viewModel.query) }
        }
    }

}
