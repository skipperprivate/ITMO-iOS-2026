//
//  MockRepositoryImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 22.10.2026.
//

import Foundation
@testable import Wetaher_app_IOS
import XCTest

public class MockWeatherRepositoryImpl: WeatherRepository {
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

        return .success(WeatherSnapshot(entity: currentForecast.toEntity(city: city), source: .cache))
    }

    public func DeleteWeatherForDeletedCity(cityID: Int) -> Bool {
        return true
    }
}
