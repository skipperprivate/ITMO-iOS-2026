import SwiftUI

struct CityPreviewView: View {
    @State private var viewModel: CityPreviewViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: CityPreviewViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let current = viewModel.detail.snapshot?.current

        ZStack {
            WeatherBackgroundView(condition: current?.condition, isDaytime: current?.isDaytime ?? true)
            CityDetailView(viewModel: viewModel.detail)
        }
        .overlay(alignment: .top) {
            if let error = viewModel.favoriteError {
                StatusBanner(error: error, retry: nil)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: viewModel.favoriteError)
        .weatherScreenStyle()
        .navigationTitle(viewModel.city.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.toggleFavorite() }
                } label: {
                    Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(viewModel.isFavorite ? WeatherPalette.favorite : WeatherPalette.ink)
                        .contentTransition(.symbolEffect(.replace))
                }
                .disabled(viewModel.isUpdatingFavorite)
                .accessibilityLabel(viewModel.isFavorite ? "Убрать из избранного" : "Добавить в избранное")
                .accessibilityIdentifier("city.favorite")
                .sensoryFeedback(.success, trigger: viewModel.isFavorite)
            }
        }
        .task { await viewModel.loadFavoriteState() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await viewModel.detail.loadIfNeeded() }
        }
    }
}

#Preview {
    CityPreviewView(viewModel: CityPreviewViewModel(
        city: MockData.allCities[3],
        weatherRepository: PreviewSupport.container.weatherRepository,
        favoritesRepository: PreviewSupport.container.favoritesRepository
    ))
    .previewEnvironment()
}
