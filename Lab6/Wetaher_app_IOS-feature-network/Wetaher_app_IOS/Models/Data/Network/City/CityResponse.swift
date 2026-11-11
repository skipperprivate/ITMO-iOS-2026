//
//  CityResponse.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 17.10.2026.
//

public struct CityResponse: Codable {
    public let id: Int
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let country: String
    public let timezone: String
    
    
}
