//
//  CityResponseMapper.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 17.10.2026.
//

extension CityResponse {
    func toUI() -> City {
        City(
            id: id,
            name: name,
            country: country,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone,
            localTime: CityUIHelper.localTime(timeZone: timezone)
        )
    }
}
