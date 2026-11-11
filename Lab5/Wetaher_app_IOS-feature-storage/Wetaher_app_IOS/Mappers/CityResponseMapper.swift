//
//  CityResponseMapper.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 17.10.2026.
//

extension CityResponse{
    func toEntity() -> CityEntity{
        CityEntity(
            id: id,
            name: name,
            country: country,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone
        )
    }
}
