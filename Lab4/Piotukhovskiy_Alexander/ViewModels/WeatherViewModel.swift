import Foundation
import Combine

struct AppAlert: Identifiable {
    let id = UUID()
    let message: String
}

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published private(set) var selectedCity: City?
    @Published private(set) var forecast: WeatherForecast?
    @Published private(set) var history: [CityHistoryEntry] = []
    @Published private(set) var isLoading = false
    @Published var alert: AppAlert?
    @Published var useFahrenheit: Bool {
        didSet {
            if !isResettingSettings { settings.useFahrenheit = useFahrenheit }
        }
    }

    let storageError: String?
    let cityService: any CityService
    private let weatherService: any WeatherService
    private let repository: (any CityRepositoryProtocol)?
    private let settings: SettingsStore
    private var isResettingSettings = false

    init(repository: (any CityRepositoryProtocol)?,
         settings: SettingsStore,
         weatherService: (any WeatherService)? = nil,
         cityService: (any CityService)? = nil,
         storageError: String? = nil) {
        self.repository = repository
        self.settings = settings
        self.weatherService = weatherService ?? MockWeatherService()
        self.cityService = cityService ?? MockCityService()
        self.storageError = storageError
        settings.createDefaultsIfNeeded()
        useFahrenheit = settings.useFahrenheit
        guard let repository else { return }

        do {
            history = try repository.history()
            if let id = settings.selectedCityID {
                selectedCity = try repository.find(id: id)
                if selectedCity == nil { settings.selectedCityID = nil }
            }
        } catch {
            alert = AppAlert(message: "Не удалось прочитать сохранённые города")
        }
    }

    var recentCities: [CityHistoryEntry] {
        Array(history.prefix(max(0, AppConstants.recentCitiesLimit)))
    }

    var displayTimeZone: TimeZone {
        forecast?.displayTimeZone ?? selectedCity?.displayTimeZone ?? TimeZone(secondsFromGMT: 0)!
    }

    func loadInitialForecastIfNeeded() async {
        guard forecast == nil else { return }
        await loadForecast(reason: .initialLoad)
    }

    func selectCity(_ city: City) async -> Bool {
        guard !isLoading, let repository else { return false }
        do {
            try repository.saveSelection(city, at: Date())
            history = try repository.history()
        } catch {
            alert = AppAlert(message: "Не удалось сохранить выбранный город")
            return false
        }
        settings.selectedCityID = city.id
        selectedCity = city
        forecast = nil
        await loadForecast(reason: .initialLoad)
        return true
    }

    func refresh() async {
        await loadForecast(reason: .userRefresh)
    }

    private func loadForecast(reason: ForecastLoadReason) async {
        guard !isLoading, let city = selectedCity else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let newForecast = try await weatherService.forecast(for: city, reason: reason)
            try Task.checkCancellation()
            forecast = newForecast
        } catch is CancellationError {} catch {
            alert = AppAlert(message: "не удалось обновить погоду")
        }
    }

    func deleteFromHistory(cityID: Int) {
        guard !isLoading, let repository else { return }
        guard cityID != selectedCity?.id else {
            alert = AppAlert(message: "Сначала выберите другой город")
            return
        }
        do {
            try repository.delete(id: cityID)
            history = try repository.history()
        } catch {
            alert = AppAlert(message: "Не удалось удалить город из истории")
        }
    }

    func resetSettings() {
        guard !isLoading else { return }
        settings.reset()
        isResettingSettings = true
        useFahrenheit = false
        isResettingSettings = false
        selectedCity = nil
        forecast = nil
        alert = nil
    }

    func temperatureText(_ celsius: Double) -> String {
        let value = useFahrenheit ? celsius * 9 / 5 + 32 : celsius
        return "\(Int(value.rounded())) °\(useFahrenheit ? "F" : "C")"
    }

    func hourText(_ date: Date) -> String {
        formatted(date, pattern: "HH:mm")
    }

    func dayText(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = displayTimeZone
        if calendar.isDate(date, inSameDayAs: Date()) { return "Сегодня" }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
           calendar.isDate(date, inSameDayAs: tomorrow) { return "Завтра" }
        return formatted(date, pattern: "EEE, d MMM")
    }

    func updatedText(_ date: Date) -> String {
        "Обновлено: " + formatted(date, pattern: "d MMM, HH:mm:ss")
    }

    private func formatted(_ date: Date, pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = displayTimeZone
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }
}
