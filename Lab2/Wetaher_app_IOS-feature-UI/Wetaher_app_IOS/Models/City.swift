//
//  City.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation

public struct City: Equatable, Hashable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let country: String
    public let latitude: Double
    public let longitude: Double
    public let timeZoneID: String
}
