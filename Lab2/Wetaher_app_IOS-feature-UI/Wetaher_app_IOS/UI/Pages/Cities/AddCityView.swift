//
//  AddCityView.swift
//  Wetaher_app_IOS
//
//  Created by Sergey Sergeev on 07.10.2026.
//

import SwiftUI

/// Экран поиска и добавления новых городов в избранное
public struct AddCityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery: String = ""
    @State private var internalState: CityListUIState?
    @State private var internalSearchResults: [City] = []
    @State private var searchTask: Task<Void, Never>?

    public var uiState: CityListUIState
    public var errorMessage: String?

    public var onSelectCity: ((City) -> Void)?
    public var onCityAdd: ((City) -> Void)?
    public var onCityDelete: ((City) -> Void)?
    public var isCitySaved: ((City) -> Bool)?
    public var onSearch: ((String) async -> [City])?

    private var effectiveUIState: CityListUIState {
        internalState ?? uiState
    }

    private var availableCities: [City] {
        var seen = Set<Int>()
        return City.avaliableCities.filter { seen.insert($0.id).inserted }
    }

    private var displayedResults: [City] {
        if internalSearchResults.isEmpty && !searchQuery.isEmpty {
            let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return availableCities.filter { city in
                city.name.lowercased().contains(trimmed) ||
                city.country.lowercased().contains(trimmed)
            }
        }
        return internalSearchResults
    }

    public init(
        uiState: CityListUIState = .Success,
        errorMessage: String? = nil,
        onSelectCity: ((City) -> Void)? = nil,
        onCityAdd: ((City) -> Void)? = nil,
        onCityDelete: ((City) -> Void)? = nil,
        isCitySaved: ((City) -> Bool)? = nil,
        onSearch: ((String) async -> [City])? = nil
    ) {
        self.uiState = uiState
        self.errorMessage = errorMessage
        self.onSelectCity = onSelectCity
        self.onCityAdd = onCityAdd
        self.onCityDelete = onCityDelete
        self.isCitySaved = isCitySaved
        self.onSearch = onSearch
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch effectiveUIState {
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
            .navigationTitle("Добавить город")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Поиск по городам"
            )
            .onChange(of: searchQuery) { _, newValue in
                performSearch(query: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }

    // MARK: - State Subviews

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Загрузка городов...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var failView: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "Ошибка поиска",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage ?? "Не удалось выполнить поиск городов. Попробуйте еще раз.")
            )

            Button {
                performSearch(query: searchQuery)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Повторить")
                }
                .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var searchStateView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Поиск городов...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

    // MARK: - Результаты поиска

    @ViewBuilder
    private var searchResultsSection: some View {
        if displayedResults.isEmpty {
            ContentUnavailableView.search(text: searchQuery)
        } else {
            Section("Результаты поиска") {
                ForEach(displayedResults) { city in
                    cityRow(for: city)
                }
            }
        }
    }

    // MARK: - Доступные города

    private var popularCitiesSection: some View {
        Section("Популярные города") {
            ForEach(availableCities) { city in
                cityRow(for: city)
            }
        }
    }

    // MARK: - Строка города

    private func cityRow(for city: City) -> some View {
        let saved = isCitySaved?(city) ?? false

        return HStack {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(city.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(city.country)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.secondary)
                        Text("В избранном")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.borderless)
            } else {
                Button {
                    onCityAdd?(city)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Логика поиска

    private func performSearch(query: String) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            self.internalSearchResults = []
            self.internalState = .Success
            return
        }

        self.internalState = .Search

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            if let onSearch = onSearch {
                let results = await onSearch(trimmed)
                guard !Task.isCancelled else { return }
                self.internalSearchResults = results
                self.internalState = .Success
            } else {
                let lowercased = trimmed.lowercased()
                let results = availableCities.filter { city in
                    city.name.lowercased().contains(lowercased) ||
                    city.country.lowercased().contains(lowercased)
                }
                guard !Task.isCancelled else { return }
                self.internalSearchResults = results
                self.internalState = .Success
            }
        }
    }
}
