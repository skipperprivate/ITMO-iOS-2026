//
//  WeatherErrorEntity.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

public struct WeatherErrorEntity: Error, Equatable, Hashable {
    public let errorCode: Int
    public let errorDescription: String
}
