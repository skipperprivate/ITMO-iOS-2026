import SwiftUI

struct ViewedFactsView: View {
    @StateObject private var viewModel: ViewedFactsViewModel
    
    init(
        viewModel: @autoclosure @escaping () -> ViewedFactsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        content
            .navigationTitle("Просмотренные факты")
            .task {
                await viewModel.load()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
            
        case .loaded(let facts):
            factsList(facts)
            
        case .error(let message):
            Text(message)
        }
    }
    
    private func factsList(
        _ facts: [ViewedFunFactModel]
    ) -> some View {
        List {
            ForEach(facts) { fact in
                factCard(fact)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .onDelete { offsets in
                Task {
                    await viewModel.deleteFacts(
                        at: offsets,    // индексы
                        from: facts
                    )
                }
            }
        }
        .listStyle(.plain)
    }
    
    
    private func factCard(
        _ fact: ViewedFunFactModel
    ) -> some View { let accent = Color(red:0.72, green:0.48, blue:0.57)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing:10) {
                Image(systemName:"sparkles")
                    .font(.system(size:14)).foregroundStyle(accent).padding(9).background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 10) )
            }
            Text(fact.filmTitle)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(fact.text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(
                fact.viewedAt.formatted(
                    date: .abbreviated,
                    time: .shortened
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}
