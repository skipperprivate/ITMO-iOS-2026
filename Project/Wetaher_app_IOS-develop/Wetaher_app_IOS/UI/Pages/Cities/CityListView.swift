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
    public var addCityUiState: AddCityUIState

    public var onSelectCity: (CityWeatherState) -> Void
    public var onDeleteCity: (City) -> Void
    public var onCityAdd: (City) -> Void
    public var isCitySaved: (City) -> Bool
    public var onRefresh: (() async -> Void)?
    public var onSearch: ((String) -> Void)?

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
        addCityUiState: AddCityUIState = .Success([]),
        onSelectCity: @escaping (CityWeatherState) -> Void,
        onDeleteCity: @escaping (City) -> Void,
        onCityAdd: @escaping (City) -> Void,
        isCitySaved: @escaping (City) -> Bool,
        onRefresh: (() async -> Void)? = nil,
        onSearch: ((String) -> Void)?
    ) {
        self.savedCities = savedCities
        self.savedCitiesWeather = savedCitiesWeather
        self.savedCitiesWeatherError = savedCitiesWeatherError
        self.cityListWeatherUIState = cityListWeatherUIState
        self.addCityUiState = addCityUiState
        self.onSelectCity = onSelectCity
        self.onDeleteCity = onDeleteCity
        self.onCityAdd = onCityAdd
        self.isCitySaved = isCitySaved
        self.onRefresh = onRefresh
        self.onSearch = onSearch
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
            .navigationTitle(BaseText.Cities.listTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(BaseText.Common.done) {
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .accessibilityIdentifier(AccessibilityIdentifiers.CityList.doneButton)
                }
            }
            .sheet(isPresented: $showAddCitySheet) {
                AddCityView(
                    uiState: addCityUiState,
                    onSelectCity: { city in
                        showAddCitySheet = false
                        onSelectCity(.NewCity(city))
                        dismiss()
                    },
                    onCityAdd: onCityAdd,
                    onCityDelete: onDeleteCity,
                    isCitySaved: isCitySaved,
                    onSearch: onSearch
                )
            }
        }
    }

    // Состояния экрана
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: BaseNumeral.sectionSpacing) {
            ProgressView()
                .controlSize(.large)
            Text(BaseText.Common.loadingData)
                .font(.subheadline)
                .foregroundStyle(Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var failView: some View {
        if citiesToDisplay.isEmpty {
            VStack(spacing: BaseNumeral.defaultSpacing) {
                ContentUnavailableView(
                    BaseText.Cities.loadErrorTitle,
                    systemImage: "exclamationmark.triangle",
                    description: Text(BaseText.Cities.loadErrorMessage)
                )

                if !savedCitiesWeatherError.isEmpty {
                    VStack(spacing: BaseNumeral.textSpacing) {
                        ForEach(Array(savedCitiesWeatherError.keys.sorted()), id: \.self) { cityName in
                            if let error = savedCitiesWeatherError[cityName] {
                                Text(BaseText.Cities.error(city: cityName, description: error.errorDescription))
                                    .font(.caption)
                                    .foregroundStyle(Colors.secondaryText)
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
                    HStack(spacing: BaseNumeral.smallSpacing) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Colors.errorIndicator)
                        Text(BaseText.Cities.refreshErrorMessage)
                            .font(.subheadline)
                            .foregroundStyle(Colors.secondaryText)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, BaseNumeral.textSpacing)
                }
                cityCards
            }
            .listStyle(.plain)
            .refreshable {
                await onRefresh?()
            }
        }
    }
    
    private var cityCards: some View{
        ForEach(citiesToDisplay, id: \.id) { city in
            let forecast = savedCitiesWeather.first(where: { $0.city.id == city.id || $0.city.name == city.name })
            let error = savedCitiesWeatherError[city.name]
            
            CityCard(city: city, forecast: forecast, error: error)
                .accessibilityIdentifier(AccessibilityIdentifiers.CityList.cityCard(city.name))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(
                    top: BaseNumeral.listRowVerticalInset,
                    leading: BaseNumeral.screenHorizontalPadding,
                    bottom: BaseNumeral.listRowVerticalInset,
                    trailing: BaseNumeral.screenHorizontalPadding
                ))
                .contentShape(Rectangle())
                .onTapGesture {
                    if forecast != nil {
                        onSelectCity(.CityWithWeather(forecast!))
                        dismiss()
                    }
                    
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if citiesToDisplay.count > 1 {
                        Button(role: .destructive) {
                            onDeleteCity(city)
                        } label: {
                            Label(BaseText.Common.delete, systemImage: "trash")
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var successView: some View {
        if citiesToDisplay.isEmpty { // Есть такая заготовка на всякий случай, хотя п-лю запрещено оставаться без избранных городов
            ContentUnavailableView(
                BaseText.Cities.emptyTitle,
                systemImage: "star.slash",
                description: Text(BaseText.Cities.emptyMessage)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                cityCards
            }
            .listStyle(.plain)
            .refreshable {
                await onRefresh?()
            }
        }
    }

    @ViewBuilder
    private var searchView: some View {
        VStack(spacing: BaseNumeral.defaultSpacing) {
            ProgressView()
            Text(BaseText.Common.searching)
                .font(.subheadline)
                .foregroundStyle(Colors.secondaryText)
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
                .foregroundStyle(Colors.onAccent)
                .frame(width: BaseNumeral.controlSize, height: BaseNumeral.controlSize)
                .background(Colors.accent)
                .clipShape(Circle())
                .shadow(
                    color: Colors.shadow,
                    radius: BaseNumeral.floatingButtonShadowRadius,
                    x: 0,
                    y: BaseNumeral.floatingButtonShadowY
                )
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.CityList.addButton)
        .padding(.bottom, BaseNumeral.bottomButtonPadding)
    }
}
