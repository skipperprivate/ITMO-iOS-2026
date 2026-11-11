//
//  WeatherStorageError.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

/// Ошибка локального хранилища погоды.
///
/// Коды начинаются с 700, чтобы не пересекаться с сетевыми ошибками
/// (`WeatherErrorResponse`) и ошибками поиска (`CityResponseError`).
public struct WeatherStorageError: Error, Equatable {
    public let errorCode: Int
    public let errorDescription: String
}
