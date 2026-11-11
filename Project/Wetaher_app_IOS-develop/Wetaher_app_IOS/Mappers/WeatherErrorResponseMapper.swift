//
//  WeatherErrorResponseMapper.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 18.10.2026.
//

extension WeatherErrorResponse {
    func toUI() -> WeatherErrorUI {
        WeatherErrorUI(
            errorCode: errorCode,
            errorDescription: errorDescription
        )
    }
}
