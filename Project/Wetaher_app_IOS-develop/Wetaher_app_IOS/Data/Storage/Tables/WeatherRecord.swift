//
//  WeatherRecord.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation
import SwiftData

// Таблица `weather`: сохранённый прогноз города
// Связана с городом (N:1), текущей погодой (1:1), почасовым и дневным прогнозом (1:N)
@Model
public final class WeatherRecord {
    var cityID: Int
    var savedAt: Date

    var city: CityRecord?

    @Relationship(deleteRule: .cascade, inverse: \CurrentWeatherRecord.weather)
    var current: CurrentWeatherRecord?

    @Relationship(deleteRule: .cascade, inverse: \HourlyWeatherRecord.weather)
    var hourly: [HourlyWeatherRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \DailyWeatherRecord.weather)
    var daily: [DailyWeatherRecord] = []

    init(cityID: Int, savedAt: Date = Date()) {
        self.cityID = cityID
        self.savedAt = savedAt
    }

    // Создаёт прогноз и вложенные записи. Город передаётся явно: связь
    // выставляется до вставки в контекст.
    convenience init(entity: WeatherEntity, city: CityRecord) {
        self.init(cityID: entity.cityID, savedAt: entity.savedAt)

        self.city = city
        current = CurrentWeatherRecord(entity: entity.current)
        hourly = entity.hourly.enumerated().map { index, item in
            HourlyWeatherRecord(entity: item, sortIndex: index)
        }
        daily = entity.daily.enumerated().map { index, item in
            DailyWeatherRecord(entity: item, sortIndex: index)
        }
    }

    // Заполняет связи готовыми записями
    // `WeatherRecord` и его дочерние записи должны принадлежать одному `ModelContext`
    func apply(_ entity: WeatherEntity) {
        savedAt = entity.savedAt
        current = CurrentWeatherRecord(entity: entity.current)
        hourly = entity.hourly.enumerated().map { index, item in
            HourlyWeatherRecord(entity: item, sortIndex: index)
        }
        daily = entity.daily.enumerated().map { index, item in
            DailyWeatherRecord(entity: item, sortIndex: index)
        }
    }
}

public extension WeatherRecord {
    // Record → Entity. Дочерние таблицы разворачиваются в массивы по `sortIndex`
    var weatherEntity: WeatherEntity {
        WeatherEntity(
            cityID: cityID,
            cityName: city?.name ?? "",
            country: city?.country ?? "",
            latitude: city?.latitude ?? 0,
            longitude: city?.longitude ?? 0,
            timezone: city?.timezone ?? "",
            savedAt: savedAt,
            current: current?.currentWeatherEntity ?? .empty,
            hourly: hourly
                .sorted { $0.sortIndex < $1.sortIndex }
                .map(\.hourlyWeatherEntity),
            daily: daily
                .sorted { $0.sortIndex < $1.sortIndex }
                .map(\.dailyWeatherEntity)
        )
    }
}
