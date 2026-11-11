//
//  WeatherErrorResponseMapper.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 18.10.2026.
//

extension WeatherErrorResponse{
    func toEntity() -> WeatherErrorEntity{
        WeatherErrorEntity(
            errorCode: errorCode,
            errorDescription: errorDescription
        )
    }
}
