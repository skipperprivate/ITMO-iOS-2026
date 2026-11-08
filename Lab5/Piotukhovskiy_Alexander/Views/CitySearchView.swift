import SwiftUI

struct CitySearchView: View {
    @EnvironmentObject private var weather: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: CitySearchViewModel
    @State private var searchText = ""
    let isRequired: Bool

    init(service: any CityService, isRequired: Bool = false) {
        _model = StateObject(wrappedValue: CitySearchViewModel(service: service))
        self.isRequired = isRequired
    }

    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        List {
            if isRequired {
                Section {
                    Text("Выберите город, чтобы посмотреть погоду.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !trimmedQuery.isEmpty {
                Section("Результаты поиска") {
                    if trimmedQuery.count < 2 {
                        Text("Введите минимум 2 символа").foregroundStyle(.secondary)
                    } else if model.isSearching {
                        ProgressView("Поиск")
                    } else if let message = model.errorMessage {
                        Text(message).foregroundStyle(.secondary)
                        Button("Повторить поиск") {
                            Task { await model.search(searchText) }
                        }
                    } else if model.results.isEmpty {
                        Text("Город не найден").foregroundStyle(.secondary)
                    } else {
                        ForEach(model.results) { city in cityButton(city) }
                    }
                }
            } else {
                if !weather.recentCities.isEmpty {
                    Section("Последние города") {
                        ForEach(weather.recentCities) { entry in
                            cityButton(entry.city)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if entry.id != weather.selectedCity?.id {
                                        Button("Удалить", role: .destructive) {
                                            weather.deleteFromHistory(cityID: entry.id)
                                        }
                                        .disabled(weather.isLoading)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Название города")
        .task(id: searchText) { await model.search(searchText) }
        .navigationTitle(isRequired ? "Выберите город" : "Выбор города")
        .overlay {
            if weather.isLoading { ProgressView("Загружаем погоду...") }
        }
    }

    private func cityButton(_ city: City) -> some View {
        Button {
            Task {
                if await weather.selectCity(city), !isRequired { dismiss() }
            }
        } label: {
            CityRow(city: city, isSelected: city.id == weather.selectedCity?.id)
        }
        .disabled(weather.isLoading)
    }
}
