//
//  MockRepositoryImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 22.10.2026.
//

import Foundation
@testable import Wetaher_app_IOS
import XCTest

public class MockRepositoryImpl: WeatherRepository {
    private var currentForecast: WeatherResponse

    public init(currentWeather: WeatherResponse = .moscowWeatherResp) {
            self.currentForecast = currentWeather
        }

    public func GetWeatherForSelectedCity(for city: Wetaher_app_IOS.City) async -> Result<Wetaher_app_IOS.WeatherResponse, Wetaher_app_IOS.WeatherErrorResponse> {

        try? await Task.sleep(nanoseconds: 100_000)

        currentForecast =
            switch city {
            case .moscow: .moscowWeatherResp
                case .saintPetersburg: .saintPetersburgWeatherResp
                case .kazan: .kazanWeatherResp
                case .krasnoyarsk: .krasnoyarskWeatherResp
                case .nizhnyNovgorod: .nizhnyNovgorodWeatherResp
                case .novosibirsk: .novosibirskWeatherResp
                case .kaliningrad: .kaliningradWeatherResp
                case .samara: .samaraWeatherResp
                case .vladivostok: .vladivostokWeatherResp
                case .yekaterinburg: .yekaterinburgWeatherResp
                case .malmo: .malmoWeatherResp
                case .hong_Kong: .hongKongWeatherResp
            default: .moscowWeatherResp
            }

        return .success(currentForecast)
    }

    public func LoadFavoriteCities() -> [Wetaher_app_IOS.City] {
        return City.defaultFavorites
    }

    public func SearchCities(query: String) async -> Result<[Wetaher_app_IOS.CityResponse], Wetaher_app_IOS.CityResponseError> {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return .failure(CityResponseError(errorId: 50, errorDescription: "Wrong city")) }

        let avaliableCities = City.avaliableCities.filter { city in
            city.name.lowercased().contains(trimmed) ||
            city.country.lowercased().contains(trimmed)
        }

        return .success(
            avaliableCities.map({city
                    in city.ToResponse()
                }
            )
        )

    }

}
