//
//  CityRecord.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation
import SwiftData

/// Таблица `city`: город, для которого сохраняются прогнозы
@Model
public final class CityRecord {
    @Attribute(.unique) var cityID: Int
    var name: String
    var country: String
    var latitude: Double
    var longitude: Double
    var timezone: String

    // Прогнозы этого города (1:N). При удалении города прогнозы удаляются каскадно
    @Relationship(deleteRule: .cascade, inverse: \WeatherRecord.city)
    var weathers: [WeatherRecord] = []

    init(
        cityID: Int,
        name: String,
        country: String,
        latitude: Double,
        longitude: Double,
        timezone: String
    ) {
        self.cityID = cityID
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
    }

    convenience init(entity: WeatherEntity) {
        self.init(
            cityID: entity.cityID,
            name: entity.cityName,
            country: entity.country,
            latitude: entity.latitude,
            longitude: entity.longitude,
            timezone: entity.timezone
        )
    }
}

public extension CityRecord {
    func apply(_ entity: WeatherEntity) {
        name = entity.cityName
        country = entity.country
        latitude = entity.latitude
        longitude = entity.longitude
        timezone = entity.timezone
    }
}
