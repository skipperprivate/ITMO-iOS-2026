//
//  WeatherRepositoryImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//
import Foundation

public class WeatherRepositoryImpl: WeatherRepository {

    // private var currentForecast: ForecastUI
    private var networkClient: NetworkClient
    // private var checker: Bool

    public init(networkClient: NetworkClient = NetworkClient()) { // currentWeather: ForecastUI = .moskowWeather,
        // self.currentForecast = currentWeather
        self.networkClient = networkClient
        // checker = true
    }

    public func GetWeatherForSelectedCity(for city: City) async -> Result<WeatherResponse, WeatherErrorResponse> {

        // Требуется заменить написания городов через тире на пробелы? т.к. API понимает только " " и "_"
        let cityInRightFormat = City(
            id: city.id,
            name: city.name.replacingOccurrences(of: "_", with: " "),
            country: city.country,
            latitude: city.latitude,
            longitude: city.longitude,
            timezone: city.timezone,
            localTime: city.localTime
        )

        let response  = await networkClient.getCityWeather(city: cityInRightFormat)
        switch response {
        case .success(let weatherResponse):
            return .success(weatherResponse)
            // print(weatherResponse)
        case .failure(let weatherErrorResponse):
            return .failure(weatherErrorResponse)

        }
    }

    public func LoadFavoriteCities() -> [City] {
        return City.defaultFavorites
    }

    public func SearchCities(query: String) async -> Result<[CityResponse], CityResponseError> {
        var trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return .failure(CityResponseError(errorId: 10, errorDescription: "Не введено значение для поиска города")) }

        let isOnlyLatinCharacters = trimmed.range(of: "\\P{Latin}", options: .regularExpression) == nil
        let isOnlyCyrillicCharacters = trimmed.range(of: "\\P{Cyrillic}", options: .regularExpression) == nil

        if isOnlyLatinCharacters || isOnlyCyrillicCharacters {
            // Do some stuff
            if isOnlyCyrillicCharacters {
                trimmed = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                guard trimmed != "" else {return .failure(CityResponseError(errorId: 11, errorDescription: "Не получается конверитровать символы кириллицы"))}
            }

            let response = await networkClient.getCityLatLongByName(cityName: trimmed, isLatinName: isOnlyLatinCharacters) // "Berlin"

            switch response {
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

        }else {
            return .failure(CityResponseError(errorId: 12, errorDescription: "В строке содержатся недопустимые символы или смешано кириллическое и латинское написания"))
        }
    }
}
