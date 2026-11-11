//
//  City.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation

public struct City: Equatable, Hashable, Sendable{
    let id: Int
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    let timeZoneID: String
}
