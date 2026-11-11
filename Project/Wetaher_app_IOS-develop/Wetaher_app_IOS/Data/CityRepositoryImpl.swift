//
//  CityRepositoryImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 11.11.2026.
//

import Foundation

@MainActor
public final class CityRepositoryImpl: CityRepository {

    private let networkClient: NetworkClient
    private let weatherStore: WeatherStore?
    private let preferences: UserPreferencesStoring

    public init(
        networkClient: NetworkClient = NetworkClient(),
        weatherStore: WeatherStore? = nil,
        preferences: UserPreferencesStoring = UserPreferencesStore()
    ) {
        self.networkClient = networkClient
        self.weatherStore = weatherStore ?? .shared
        self.preferences = preferences
    }

    public func SearchCities(query: String) async -> Result<[CityResponse], CityResponseError> {
        var trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return .failure(CityResponseError(errorId: 10, errorDescription: "Не введено значение для поиска города")) }

        let isOnlyLatinCharacters = trimmed.range(of: "\\P{Latin}", options: .regularExpression) == nil
        let isOnlyCyrillicCharacters = trimmed.range(of: "\\P{Cyrillic}", options: .regularExpression) == nil

        if (isOnlyLatinCharacters || isOnlyCyrillicCharacters){
            if(isOnlyCyrillicCharacters){
                trimmed = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                guard trimmed != "" else {return .failure(CityResponseError(errorId: 11, errorDescription: "Не получается конверитровать символы кириллицы"))}
            }

            let response = await networkClient.getCityLatLongByName(cityName: trimmed, isLatinName: isOnlyLatinCharacters)
            switch(response){
            case .success(let possibleCities):
                return .success(possibleCities.results)
            case .failure(var cityError):
                if (400...599).contains(cityError.errorId) {
                    cityError.reserveCities = cityError.reserveCities.filter { city in
                        city.name.lowercased().contains(trimmed) ||
                        city.country.lowercased().contains(trimmed)
                    }
                }
                return .failure(cityError)
            }
        }else{
            return .failure(CityResponseError(errorId: 12, errorDescription: "В строке содержатся недопустимые символы или смешано кириллическое и латинское написания"))
        }
    }

    public func LoadSavedCities() -> [CityEntity] {
        let storedCities = preferences.favoriteCities
        guard storedCities.isEmpty else { return storedCities }

        // Первый запуск: приложение не должно остаться без избранных городов
        let defaultFavorites = CityEntity.defaultFavorites
        preferences.favoriteCities = defaultFavorites
        return defaultFavorites
    }

    public func AddFavoriteCity(_ city: City) {
        var favorites = LoadSavedCities()
        guard !favorites.contains(where: { $0.id == city.id }) else { return }

        favorites.append(CityEntity(
            id: city.id,
            name: city.name,
            country: city.country,
            latitude: city.latitude,
            longitude: city.longitude,
            timezone: city.timezone
        ))
        preferences.favoriteCities = favorites
    }

    public func RemoveFavoriteCity(cityID: Int) {
        var favorites = LoadSavedCities()
        // Должен быть хотя бы 1 сохранённый город!
        guard favorites.count > 1 else { return }

        favorites.removeAll { $0.id == cityID }
        preferences.favoriteCities = favorites

        // Выбранным не может остаться удалённый город
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
