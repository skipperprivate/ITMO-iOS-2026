//
//  WeatherRecord.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation
import SwiftData

/// SwiftData-модель, в которой лежит сериализованный снимок погоды.
@Model
final class WeatherRecord {
    @Attribute(.unique) var cityID: Int
    var payload: Data

    init(cityID: Int, payload: Data) {
        self.cityID = cityID
        self.payload = payload
    }
}
