//
//  CityEntity.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

/// Город в том виде, в котором он приходит из сети, до преобразования в UI-модель.
public struct CityEntity: Codable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let country: String
    public let latitude: Double
    public let longitude: Double
    public let timezone: String
}
