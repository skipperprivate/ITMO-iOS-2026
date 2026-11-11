//
//  AddCityView.swift
//  Wetaher_app_IOS
//
//  Created by Sergey Sergeev on 07.10.2026.
//

import SwiftUI

// Экран поиска и добавления новых городов в избранное
public struct AddCityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery: String = ""
    @State private var displayedResults: [City] = []

    private var addCityUiState: AddCityUIState
    @State private var errorMessage: String?

    public var onSelectCity: ((City) -> Void)?
    public var onCityAdd: ((City) -> Void)?
    public var onCityDelete: ((City) -> Void)?
    public var isCitySaved: ((City) -> Bool)?
    public var onSearch: ((String) -> Void)?

    private var availableCities: [City] {
        var seen = Set<Int>()
        return City.availableCities.filter { seen.insert($0.id).inserted }
    }

    public init(
        uiState: AddCityUIState = .Success([]),
        onSelectCity: ((City) -> Void)? = nil,
        onCityAdd: ((City) -> Void)? = nil,
        onCityDelete: ((City) -> Void)? = nil,
        isCitySaved: ((City) -> Bool)? = nil,
        onSearch: ((String) -> Void)? = nil
    ) {
        self.addCityUiState = uiState
        self.onSelectCity = onSelectCity
        self.onCityAdd = onCityAdd
        self.onCityDelete = onCityDelete
        self.isCitySaved = isCitySaved
        self.onSearch = onSearch
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch addCityUiState {
                case .Loading:
                    loadingView
                case .Fail:
                    failView
                case .Search:
                    searchStateView
                case .Success:
                    successView
                }
            }
            .navigationTitle(BaseText.Cities.addTitle)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: BaseText.Cities.searchPrompt
            )
            .onChange(of: searchQuery) { _, newValue in
                onSearch?(newValue)
                updateDisplayedResults()
            }
            .onChange(of: addCityUiState) { _, _ in
                //Результат поиска приходит из ViewModel уже после смены запроса
                updateDisplayedResults()
            }
            .onAppear {
                updateDisplayedResults()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(BaseText.Common.done) {
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .accessibilityIdentifier(AccessibilityIdentifiers.AddCity.doneButton)
                }
            }
        }
    }

    // Состояния экрана
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: BaseNumeral.sectionSpacing) {
            ProgressView()
                .controlSize(.large)
            Text(BaseText.Common.loadingCities)
                .font(.subheadline)
                .foregroundStyle(Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var failView: some View {
        if !searchQuery.isEmpty {
            VStack(spacing: BaseNumeral.sectionSpacing) {
                ContentUnavailableView(
                    BaseText.Cities.searchErrorTitle,
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage ?? BaseText.Cities.searchErrorMessage)
                )

                Button {
                    // performSearch(query: searchQuery)
                    onSearch?(searchQuery)
                    updateDisplayedResults()
                } label: {
                    HStack(spacing: BaseNumeral.smallSpacing) {
                        Image(systemName: "arrow.clockwise")
                        Text(BaseText.Common.retry)
                    }
                    .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        successView // Пусть резервные города выводятся даже если проблемы с сетью
    }

    @ViewBuilder
    private var searchStateView: some View {
        VStack(spacing: BaseNumeral.defaultSpacing) {
            ProgressView()
            Text(BaseText.Common.searchingCities)
                .font(.subheadline)
                .foregroundStyle(Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var successView: some View {
        List {
            if !searchQuery.isEmpty {
                searchResultsSection
            } else {
                popularCitiesSection
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private var searchResultsSection: some View {
        if displayedResults.isEmpty {
            ContentUnavailableView.search(text: searchQuery)
        } else {
            Section(
                (errorMessage != nil) ? BaseText.Cities.popular : BaseText.Cities.searchResults
                ) {
                ForEach(displayedResults) { city in
                    cityRow(for: city)
                }
            }
        }
    }

    private var popularCitiesSection: some View {
        Section(BaseText.Cities.popular) {
            ForEach(availableCities) { city in
                cityRow(for: city)
            }
        }
    }

    private func cityRow(for city: City) -> some View {
        let saved = isCitySaved?(city) ?? false

        return HStack {
            HStack {
                VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                    Text(city.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(Colors.primaryText)
                        .accessibilityIdentifier(AccessibilityIdentifiers.AddCity.resultRow(city.name))

                    Text(city.country)
                        .font(.caption)
                        .foregroundStyle(Colors.secondaryText)
                }

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !saved {
                    onCityAdd?(city)
                }
                onSelectCity?(city)
                dismiss()
            }

            if saved {
                Button {
                    onCityDelete?(city)
                } label: {
                    HStack(spacing: BaseNumeral.textSpacing) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Colors.secondaryText)
                        Text(BaseText.Cities.saved)
                            .font(.caption)
                            .foregroundStyle(Colors.secondaryText)
                    }
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier(AccessibilityIdentifiers.AddCity.toggleButton(city.name))
            } else {
                Button {
                    onCityAdd?(city)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Colors.accent)
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier(AccessibilityIdentifiers.AddCity.toggleButton(city.name))
            }
        }
        .padding(.vertical, BaseNumeral.textSpacing)
    }

    private func updateDisplayedResults() {
        switch addCityUiState {
            case .Fail(let cityError):
                displayedResults = cityError.reserveCities
                errorMessage = cityError.errorDescription

            case .Success(let searchedCities):
                displayedResults = searchedCities
                errorMessage = nil

            default:
                errorMessage = nil
        }
    }
}
