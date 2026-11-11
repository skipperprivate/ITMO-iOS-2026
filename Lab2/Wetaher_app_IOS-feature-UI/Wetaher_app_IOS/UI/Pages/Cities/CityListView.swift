//
//  CityListView.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

/// Экран списка избранных городов
public struct CityListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddCitySheet: Bool = false

    public var savedCities: [City]
    public var savedCitiesWeather: [ForecastUI]
    public var savedCitiesWeatherError: [String: WeatherErrorUI]
    public var cityListWeatherUIState: CityListUIState
    public var searchQuery: String
    public var searchResults: [City]

    public var onSelectCity: (City) -> Void
    public var onDeleteCity: (City) -> Void
    public var onCityAdd: (City) -> Void
    public var isCitySaved: (City) -> Bool
    public var onRefresh: (() async -> Void)?

    private var citiesToDisplay: [City] {
        if !savedCities.isEmpty {
            return savedCities
        }
        return savedCitiesWeather.map { $0.city }
    }

    public init(
        savedCities: [City] = [],
        savedCitiesWeather: [ForecastUI] = [],
        savedCitiesWeatherError: [String: WeatherErrorUI] = [:],
        cityListWeatherUIState: CityListUIState = .Success,
        searchQuery: String = "",
        searchResults: [City] = [],
        onSelectCity: @escaping (City) -> Void,
        onDeleteCity: @escaping (City) -> Void,
        onCityAdd: @escaping (City) -> Void,
        isCitySaved: @escaping (City) -> Bool,
        onRefresh: (() async -> Void)? = nil
    ) {
        self.savedCities = savedCities
        self.savedCitiesWeather = savedCitiesWeather
        self.savedCitiesWeatherError = savedCitiesWeatherError
        self.cityListWeatherUIState = cityListWeatherUIState
        self.searchQuery = searchQuery
        self.searchResults = searchResults
        self.onSelectCity = onSelectCity
        self.onDeleteCity = onDeleteCity
        self.onCityAdd = onCityAdd
        self.isCitySaved = isCitySaved
        self.onRefresh = onRefresh
    }


    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                switch cityListWeatherUIState {
                case .Loading:
                    loadingView

                case .Fail:
                        failView

                case .Success:
                    successView

                case .Search:
                    searchView
                }

                if cityListWeatherUIState != .Loading {
                    addCityButton
                }
            }
            .navigationTitle("Избранные города")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showAddCitySheet) {
                AddCityView(
                    onSelectCity: { city in
                        showAddCitySheet = false
                        onSelectCity(city)
                        dismiss()
                    },
                    onCityAdd: onCityAdd,
                    onCityDelete: onDeleteCity,
                    isCitySaved: isCitySaved
                )
            }
        }
    }

    // MARK: - State Subviews

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Загрузка данных...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var failView: some View {
        if citiesToDisplay.isEmpty {
            VStack(spacing: 12) {
                ContentUnavailableView(
                    "Ошибка загрузки",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Не удалось загрузить данные о погоде для сохранённых городов.")
                )

                if !savedCitiesWeatherError.isEmpty {
                    VStack(spacing: 4) {
                        ForEach(Array(savedCitiesWeatherError.keys.sorted()), id: \.self) { cityName in
                            if let error = savedCitiesWeatherError[cityName] {
                                Text("\(cityName): \(error.errorDescription)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Не удалось обновить данные о погоде")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
                }

                ForEach(citiesToDisplay, id: \.id) { city in
                    let forecast = savedCitiesWeather.first(where: { $0.city.id == city.id || $0.city.name == city.name })
                    let error = savedCitiesWeatherError[city.name]

                    CityCard(city: city, forecast: forecast, error: error)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelectCity(city)
                            dismiss()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                onDeleteCity(city)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await onRefresh?()
            }
        }
    }

    @ViewBuilder
    private var successView: some View {
        if citiesToDisplay.isEmpty {
            ContentUnavailableView(
                "Нет избранных городов",
                systemImage: "star.slash",
                description: Text("Нажмите на кнопку «+» внизу, чтобы найти и добавить города.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(citiesToDisplay, id: \.id) { city in
                    let forecast = savedCitiesWeather.first(where: { $0.city.id == city.id || $0.city.name == city.name })
                    let error = savedCitiesWeatherError[city.name]

                    CityCard(city: city, forecast: forecast, error: error)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelectCity(city)
                            dismiss()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                onDeleteCity(city)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await onRefresh?()
            }
        }
    }

    @ViewBuilder
    private var searchView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Поиск...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addCityButton: some View {
        Button {
            showAddCitySheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(.bottom, 16)
    }
}
