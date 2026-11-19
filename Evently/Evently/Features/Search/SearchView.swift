import SwiftUI

struct SearchView: View {
    @State private var viewModel: SearchViewModel
    let locationStore: LocationStore

    init(
        viewModel: SearchViewModel,
        locationStore: LocationStore
    ) {
        self.locationStore = locationStore
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                SearchField(text: $viewModel.searchText)
                content
                Spacer(minLength: 0)
            }
            .padding(.top, 8)
        }
        .onChange(of: viewModel.searchText) { viewModel.search() }
        .onChange(of: locationStore.selectionKey) { viewModel.search() }
        .onAppear {
            if !viewModel.isSearchEmpty {
                viewModel.search()
            }
        }
        .onDisappear { viewModel.cancel() }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isSearchEmpty {
            SearchEmptyStateView(
                title: "search.start_typing",
                description: String(localized: "search.start_typing.description")
            )
        } else if viewModel.isLoading {
            ProgressView("Ищем мероприятия...")
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
        } else if let error = viewModel.errorMessage {
            VStack(spacing: 12) {
                Text("Не удалось выполнить поиск")
                Text(error).font(.caption).foregroundStyle(.secondary)
                Button("Повторить") { viewModel.retry() }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else if viewModel.filteredEvents.isEmpty {
            SearchEmptyStateView(
                title: "search.no_results",
                description: viewModel.searchText
            )
        } else {
            VStack(spacing: 8) {
                SearchResultsView(events: viewModel.filteredEvents) {
                    viewModel.requestNextPage()
                }
                if viewModel.isLoadingMore {
                    ProgressView("Загружаем ещё...").padding(12)
                }
                if let error = viewModel.paginationError {
                    VStack(spacing: 8) {
                        Text(error).font(.caption).foregroundStyle(.secondary)
                        Button("Повторить") {
                            viewModel.requestNextPage()
                        }
                    }
                }
            }
        }
    }
}
