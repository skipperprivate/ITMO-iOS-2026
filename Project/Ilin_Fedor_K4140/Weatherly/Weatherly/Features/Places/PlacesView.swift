//
//  PlacesView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct PlacesView: View {
    @State private var placesViewModel: PlacesViewModel
    @State private var searchViewModel: SearchViewModel
    private let onSelectFavorite: (City) -> Void

    @Environment(Router.self) private var router
    @Environment(SettingsStore.self) private var settingsStore
    @Environment(WeatherAmbience.self) private var ambience
    @Environment(ConnectivityMonitor.self) private var connectivity
    @FocusState private var isSearchFocused: Bool
    @State private var editMode: EditMode = .inactive

    init(placesViewModel: PlacesViewModel, searchViewModel: SearchViewModel, onSelectFavorite: @escaping (City) -> Void) {
        _placesViewModel = State(initialValue: placesViewModel)
        _searchViewModel = State(initialValue: searchViewModel)
        self.onSelectFavorite = onSelectFavorite
    }

    var body: some View {
        List {
            if searchViewModel.isActive {
                searchResults
            } else {
                favorites
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .safeAreaInset(edge: .top, spacing: 0) { searchField }
        .ambientBackground(ambience)
        .environment(\.editMode, $editMode)
        .weatherScreenStyle()
        .navigationTitle("Места")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.snappy, value: searchViewModel.isActive)
        .animation(.snappy, value: placesViewModel.weatherError)
        .animation(.snappy, value: placesViewModel.editError)
        // onAppear, not task: coming back from a city preview must pick up a newly starred place.
        .onAppear {
            Task { await placesViewModel.load() }
        }
        .refreshable { await placesViewModel.refreshWeather(policy: .reloadIgnoringCache) }
        .onChange(of: connectivity.isConnected) { _, isConnected in
            guard isConnected else { return }
            Task { await placesViewModel.recoverAfterReconnect() }
            if case .failed = searchViewModel.state { searchViewModel.retry() }
        }
    }

    // MARK: Search field

    private var searchField: some View {
        @Bindable var search = searchViewModel

        return HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.secondary)
            TextField("Что ищем?", text: $search.query)
                .accessibilityIdentifier("places.search")
                .font(.wxTitle2)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
            if searchViewModel.isActive {
                Button {
                    search.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Очистить")
                .accessibilityIdentifier("places.clearSearch")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(WeatherPalette.fieldFill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(WeatherPalette.hairline)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    // MARK: Favourites

    @ViewBuilder
    private var favorites: some View {
        Section {
            HStack {
                Text("Мои места")
                    .font(.wxTitle)
                Spacer()
                if !placesViewModel.cities.isEmpty {
                    Button(editMode.isEditing ? "Готово" : "Изменить") {
                        withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                    }
                    .font(.wxSubheadlineBold)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
            }
            .plainListRow(top: 12, bottom: 4)
            .moveDisabled(true)
            .deleteDisabled(true)

            if let error = placesViewModel.weatherError {
                StatusBanner(error: error) {
                    Task { await placesViewModel.refreshWeather() }
                }
                .frame(maxWidth: .infinity)
                .plainListRow(top: 2, bottom: 2)
                .moveDisabled(true)
                .deleteDisabled(true)
            }

            if let error = placesViewModel.editError {
                StatusBanner(error: error, retry: nil)
                    .frame(maxWidth: .infinity)
                    .plainListRow(top: 2, bottom: 2)
                    .moveDisabled(true)
                    .deleteDisabled(true)
            }

            ForEach(placesViewModel.cities) { city in
                PlaceCardView(
                    city: city,
                    weather: placesViewModel.weather(for: city),
                    unit: settingsStore.settings.temperatureUnit
                )
                .accessibilityIdentifier("places.favorite.\(city.id)")
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !editMode.isEditing else { return }
                    onSelectFavorite(city)
                }
                .plainListRow(top: 6, bottom: 6)
            }
            .onDelete(perform: placesViewModel.remove)
            .onMove(perform: placesViewModel.move)

            footer
                .plainListRow(top: 20, bottom: 20)
                .moveDisabled(true)
                .deleteDisabled(true)
        }
    }

    @ViewBuilder
    private var footer: some View {
        switch placesViewModel.state {
        case .loading:
            ProgressView().frame(maxWidth: .infinity)
        case .failed(let error):
            StateMessageView(error: error) {
                Task { await placesViewModel.load() }
            }
        case .loaded:
            Text(placesViewModel.cities.isEmpty
                 ? "Здесь пока пусто. Найдите город через поиск и нажмите ☆ на экране прогноза"
                 : "Чтобы добавить место, найдите его через поиск и нажмите ☆ на экране прогноза")
                .font(.wxSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: Search results

    // Results of the previous query stay while the next one loads, with a spinner above them;
    // anything else (empty, error, hint) gives way to the spinner, so it never contradicts the query.
    @ViewBuilder
    private var searchResults: some View {
        switch searchViewModel.state {
        case .results(let cities):
            if searchViewModel.isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .plainListRow(top: 4, bottom: 4)
            }
            resultRows(cities)
        case .idle, .tooShort, .empty, .failed:
            if searchViewModel.isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .plainListRow(top: 40, bottom: 0)
            } else {
                searchMessage
            }
        }
    }

    @ViewBuilder
    private var searchMessage: some View {
        switch searchViewModel.state {
        case .idle, .results:
            EmptyView()
        case .tooShort(let minimumLength):
            Text("Введите хотя бы \(WeatherFormatter.letters(minimumLength))")
                .font(.wxSubheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .plainListRow(top: 40, bottom: 0)
        case .empty:
            // Not ContentUnavailableView.search: its built-in text isn't localized in this app.
            StateMessageView(
                title: "Ничего не нашлось",
                message: "Проверьте написание или попробуйте другой город",
                systemImage: "magnifyingglass"
            )
            .plainListRow(top: 40, bottom: 0)
        case .failed(let error):
            StateMessageView(error: error) { searchViewModel.retry() }
                .plainListRow(top: 40, bottom: 0)
        }
    }

    private func resultRows(_ cities: [City]) -> some View {
        ForEach(cities) { city in
            Button {
                isSearchFocused = false
                router.push(.cityPreview(city))
            } label: {
                SearchResultRow(city: city)
            }
            .buttonStyle(PressableRowStyle())
            .accessibilityIdentifier("places.result.\(city.id)")
            .plainListRow(top: 4, bottom: 4)
        }
    }
}

private struct SearchResultRow: View {
    let city: City

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(WeatherPalette.precipitation)
            VStack(alignment: .leading, spacing: 1) {
                Text(city.name).font(.wxHeadline)
                Text(city.subtitle).font(.wxCaption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .glassCard(cornerRadius: 20, padding: 14)
    }
}

private extension View {
    func plainListRow(top: CGFloat, bottom: CGFloat) -> some View {
        self
            .listRowInsets(EdgeInsets(top: top, leading: 16, bottom: bottom, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

#if DEBUG
#Preview {
    PlacesView(
        placesViewModel: PlacesViewModel(
            favoritesRepository: PreviewSupport.container.favoritesRepository,
            weatherRepository: PreviewSupport.container.weatherRepository
        ),
        searchViewModel: SearchViewModel(geocodingRepository: PreviewSupport.container.geocodingRepository),
        onSelectFavorite: { _ in }
    )
    .previewEnvironment()
}
#endif
