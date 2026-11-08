import SwiftUI

struct CitySearchView: View {
    @EnvironmentObject private var weather: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: CitySearchViewModel
    @State private var searchText = ""
    @State private var retryID = UUID()
    @State private var selectionTask: Task<Void, Never>?
    let isRequired: Bool

    init(service: any CityService, isRequired: Bool = false) {
        _model = StateObject(wrappedValue: CitySearchViewModel(service: service))
        self.isRequired = isRequired
    }

    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var searchTaskID: String {
        "\(searchText)-\(retryID.uuidString)"
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
                        ProgressView("Поиск...")
                    } else if let message = model.errorMessage {
                        Text(message).foregroundStyle(.secondary)
                        Button("Повторить поиск") {
                            retryID = UUID()
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
                Section {
                    Text("Введите название города в строке поиска. Результаты загружаются из Open-Meteo.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Название города")
        .task(id: searchTaskID) { await model.search(searchText) }
        .onDisappear { selectionTask?.cancel() }
        .navigationTitle(isRequired ? "Выберите город" : "Выбор города")
        .overlay {
            if weather.isLoading { ProgressView("Загружаем погоду...") }
        }
    }

    private func cityButton(_ city: City) -> some View {
        Button {
            selectionTask?.cancel()
            selectionTask = Task {
                if await weather.selectCity(city), !isRequired { dismiss() }
            }
        } label: {
            CityRow(city: city, isSelected: city.id == weather.selectedCity?.id)
        }
        .disabled(weather.isLoading)
    }
}
