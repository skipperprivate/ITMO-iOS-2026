//
//  MockCityRepositoryImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 11.11.2026.
//

import Foundation
@testable import Wetaher_app_IOS
import XCTest

public class MockCityRepositoryImpl: CityRepository {
    private var currentForecast: WeatherResponse
    private let preferences: UserPreferencesStoring

    public init(
        currentWeather: WeatherResponse = .moscowWeatherResp,
        preferences: UserPreferencesStoring = MockUserPreferencesStore()
    ) {
            self.currentForecast = currentWeather
            self.preferences = preferences
    }

    public func SearchCities(query: String) async -> Result<[CityResponse], CityResponseError> {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return .failure(CityResponseError(errorId: 50, errorDescription: "Wrong city")) }

        let availableCities = City.availableCities.filter { city in
            city.name.lowercased().contains(trimmed) ||
            city.country.lowercased().contains(trimmed)
        }

        return .success(
            availableCities.map({city
                in city.toEntity().toResponse()
                }
            )
        )

    }
    
    public func LoadSavedCities() -> [CityEntity] {
        let storedCities = preferences.favoriteCities
        guard storedCities.isEmpty else { return storedCities }

        let defaultFavorites = CityEntity.defaultFavorites
        preferences.favoriteCities = defaultFavorites
        return defaultFavorites
    }

    public func AddFavoriteCity(_ city: City) {
        var favorites = LoadSavedCities()
        guard !favorites.contains(where: { $0.id == city.id }) else { return }

        favorites.append(city.toEntity())
        preferences.favoriteCities = favorites
    }

    public func RemoveFavoriteCity(cityID: Int) {
        var favorites = LoadSavedCities()
        guard favorites.count > 1 else { return }

        favorites.removeAll { $0.id == cityID }
        preferences.favoriteCities = favorites

        if preferences.activeCityID == cityID {
            preferences.activeCityID = favorites.first?.id
        }
    }

    public func LoadActiveCityID() -> Int? {
        preferences.activeCityID
    }

    public func SetActiveCity(_ cityID: Int) {
        preferences.activeCityID = cityID
    }

}
