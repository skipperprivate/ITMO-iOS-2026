//
//  MockRepositoryFailImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 29.10.2026.
//

import Foundation
@testable import Wetaher_app_IOS
import XCTest

public class MockRepositoryFailResponseImpl: WeatherRepository {
    private var currentForecast: WeatherResponse

    public init(currentWeather: WeatherResponse = .moscowWeatherResp) {
            self.currentForecast = currentWeather
        }

    public func GetWeatherForSelectedCity(for city: Wetaher_app_IOS.City) async -> Result<Wetaher_app_IOS.WeatherResponse, Wetaher_app_IOS.WeatherErrorResponse> {
        
        try? await Task.sleep(nanoseconds: 100_000)

        return .failure(WeatherErrorResponse(errorCode: 67, errorDescription: "Trial error exception"))
    }

    public func LoadFavoriteCities() -> [Wetaher_app_IOS.City] {
        return City.defaultFavorites
    }

    public func SearchCities(query: String) async -> Result<[Wetaher_app_IOS.CityResponse], Wetaher_app_IOS.CityResponseError> {
        
        try? await Task.sleep(nanoseconds: 100_000)
        
        return .failure(
            CityResponseError(errorId: 69, errorDescription: "Trial error exception")
        )

    }

}
