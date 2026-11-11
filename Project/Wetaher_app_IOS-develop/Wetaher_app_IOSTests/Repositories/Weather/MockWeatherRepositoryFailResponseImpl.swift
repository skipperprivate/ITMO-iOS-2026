//
//  MockRepositoryFailImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 29.10.2026.
//

import Foundation
@testable import Wetaher_app_IOS
import XCTest

public class MockWeatherRepositoryFailResponseImpl: WeatherRepository {
    private var currentForecast: WeatherResponse
    private let preferences: UserPreferencesStoring

    public init(
        currentWeather: WeatherResponse = .moscowWeatherResp,
        preferences: UserPreferencesStoring = MockUserPreferencesStore()
    ) {
            self.currentForecast = currentWeather
            self.preferences = preferences
        }

    public func GetWeatherForSelectedCity(for city: City) async -> Result<WeatherSnapshot, WeatherErrorResponse> {
        
        try? await Task.sleep(nanoseconds: 100_000)

        return .failure(WeatherErrorResponse(errorCode: 67, errorDescription: "Trial error exception"))
    }

    public func DeleteWeatherForDeletedCity(cityID: Int) -> Bool {
        return false
    }

}
