//
//  WeatherSnapshot.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

/// Откуда взяты данные, которые показывает приложение.
public enum WeatherDataSource: String, Sendable {
    case network
    case cache
}

/// Результат загрузки погоды: сущность для отображения + источник данных.
public struct WeatherSnapshot {
    public let entity: WeatherEntity
    public let source: WeatherDataSource

    public var isFromCache: Bool {
        source == .cache
    }

    public var savedAt: Date {
        entity.savedAt
    }
}
