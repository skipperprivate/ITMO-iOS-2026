//
//  CityEntityMapper.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

extension CityEntity{
    /// Entity → UI.
    func toUI() -> City{
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
