@preconcurrency import CoreLocation
import Foundation
import Observation

struct ResolvedCity: Equatable {
    let name: String
    let country: String
    let countryCode: String

    var title: String { "\(name), \(country)" }
}

@MainActor
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var targetStore: LocationStore?

    private(set) var isLocating = false
    private(set) var isSearching = false
    var errorMessage: String?
    var proposedCity: ResolvedCity?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func useCurrentLocation(store: LocationStore) {
        errorMessage = nil
        proposedCity = nil
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "Службы геолокации отключены в настройках устройства."
            return
        }
        targetStore = store
        isLocating = true
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isLocating = false
            errorMessage = "Доступ к геолокации запрещён. Разрешите его в настройках iOS или выберите город вручную."
        @unknown default:
            isLocating = false
            errorMessage = "Неизвестный статус разрешения геолокации."
        }
    }

    func clearProposal() {
        proposedCity = nil
    }

    func findCity(_ query: String) async {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count >= 2 else {
            errorMessage = "Введите название города (минимум два символа)."
            return
        }
        errorMessage = nil
        proposedCity = nil
        isSearching = true
        defer { isSearching = false }
        do {
            let placemarks = try await geocoder.geocodeAddressString(cleaned)
            guard let place = placemarks.first,
                  let city = place.locality,
                  let country = place.country,
                  let countryCode = place.isoCountryCode else {
                errorMessage = "Город не найден. Уточните название и страну."
                return
            }
            try Task.checkCancellation()
            proposedCity = ResolvedCity(name: city, country: country, countryCode: countryCode)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Не удалось найти город. Проверьте интернет и название."
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            guard let self, self.isLocating else { return }
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.manager.requestLocation()
            case .denied, .restricted:
                self.isLocating = false
                self.errorMessage = "Доступ к геолокации запрещён. Выберите город вручную."
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let places = try await self.geocoder.reverseGeocodeLocation(location)
                guard let place = places.first,
                      let city = place.locality,
                      let code = place.isoCountryCode else {
                    self.errorMessage = "Не удалось определить город по координатам."
                    self.isLocating = false
                    return
                }
                self.targetStore?.select(city: city, countryCode: code)
                self.isLocating = false
            } catch {
                self.errorMessage = "Не удалось определить город. Попробуйте ручной ввод."
                self.isLocating = false
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            self?.errorMessage = "Не удалось получить геопозицию: \(error.localizedDescription)"
            self?.isLocating = false
        }
    }
}
