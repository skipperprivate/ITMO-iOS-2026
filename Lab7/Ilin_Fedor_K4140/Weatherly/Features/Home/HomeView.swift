import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @Environment(Router.self) private var router
    @Environment(WeatherAmbience.self) private var ambience
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            WeatherBackgroundView(
                condition: backdrop?.condition ?? ambience.condition,
                isDaytime: backdrop?.isDaytime ?? ambience.isDaytime
            )
            content
        }
        .weatherScreenStyle()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .onAppear {
            Task { await viewModel.loadFavorites() }
        }
        .onChange(of: backdrop, initial: true) { _, current in
            ambience.update(with: current)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await viewModel.refreshSelectedIfStale() }
        }
    }

    private var backdrop: CurrentWeather? {
        viewModel.selectedSnapshot?.current
    }

    private var currentIndex: Int {
        viewModel.favoriteCities.firstIndex { $0.id == viewModel.selectedCityID } ?? 0
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.favoriteCities.isEmpty {
            switch viewModel.state {
            case .loading:
                ProgressView().controlSize(.large)
            case .failed(let error):
                StateMessageView(error: error) {
                    Task { await viewModel.loadFavorites() }
                }
            case .loaded:
                emptyState
            }
        } else {
            TabView(selection: $viewModel.selectedCityID) {
                ForEach(viewModel.favoriteCities) { city in
                    CityDetailView(viewModel: viewModel.detailViewModel(for: city))
                        .tag(Optional(city.id))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
            .task { await viewModel.pagerDidAppear() }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Пока нет городов", systemImage: "mappin.and.ellipse")
        } description: {
            Text("Найдите город, чтобы видеть его погоду здесь")
        } actions: {
            Button("Найти город") { router.push(.places) }
                .buttonStyle(.bordered)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                router.push(.settings)
            } label: {
                Image(systemName: "gearshape.fill")
            }
            .accessibilityLabel("Настройки")
        }
        ToolbarItem(placement: .principal) {
            VStack(spacing: 4) {
                Button {
                    router.push(.places)
                } label: {
                    LocationPill(title: viewModel.selectedCity?.name ?? "Мои места")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.places")
                .accessibilityHint("Открыть список мест и поиск")

                if viewModel.favoriteCities.count > 1 {
                    PageIndicator(count: viewModel.favoriteCities.count, currentIndex: currentIndex)
                }
            }
        }
    }
}

private struct LocationPill: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(.wxHeadline)
                .lineLimit(1)
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .bold))
                .opacity(0.6)
        }
        .foregroundStyle(WeatherPalette.ink)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

#Preview {
    RootView(container: PreviewSupport.container)
}
